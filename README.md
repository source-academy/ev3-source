# Build scripts for the EV3 Source image

This repository contains scripts used to build a customised EV3 image containing Sling, Sinter, and Pynter (Python support).

If you want to know exactly how the build process works, read the [GitHub workflow](.github/workflows/build.yml).

In a nutshell:

- [`build_control_panel.sh`](./build_control_panel.sh): Cross-compiles the `service_control` binary to manage Source-Academy related services and settings directly from the EV3
- [`build_sling.sh`](./build_sling.sh): Cross-compiles Sling and Sinter for ARM using ev3dev's cross-compilation Docker image `ev3dev/debian-stretch-cross`, with some additional dependencies added in [`Dockerfile.sling`](./Dockerfile.sling)
- [`build_qrcode.sh`](./build_qrcode.sh): Cross-compiles the `show_qrcode` binary to display the QR code of the device secret on the EV3 screen
- [`build_uuidtob62.sh`](./build_uuidtob62.sh): Cross-compiles the `uuidtob62` CLI utility to represent the device secret in a more compact format
- [`build_pynter.sh`](./build_pynter.sh): Cross-compiles `pynter-ev3`, the Python interpreter binary, by delegating to [`pynter`](https://github.com/source-academy/pynter)'s own self-contained `devices/ev3/build.sh`
- [`build_image.sh`](./build_image.sh): Builds the EV3 root filesystem using [`image/Dockerfile`](image/Dockerfile) and [`image/bootstrap.sh`](image/bootstrap.sh), and then uses [Brickstrap](https://github.com/ev3dev/brickstrap) to build the final image

To run this locally:

- You must be on Linux.
- You need a static build of QEMU configured for user-mode ARM emulation. It must be registered to handle ARM ELF files using `binfmt_misc`.
- You need libguestfs tools.
- To satisfy the above dependencies:
  - On Ubuntu, install `libguestfs-tools qemu-user-static binfmt-support`.
  - On Arch, install `binfmt-qemu-static qemu-user-static-bin libguestfs`. (Note, the first two are AUR packages.)

`brickstrap.sh` is vendored at the repo root rather than downloaded fresh from upstream each time - see its own comment for why (a real ext4-feature/e2fsck version-skew fix that a plain re-download would silently drop).

## TLDR

To build the image from the source code, make sure you are the the root of the repository, then run the following commands in order:

```bash
./build_control_panel.sh
./build_sling.sh
./build_qrcode.sh
./build_uuidtob62.sh
./build_pynter.sh
./build_image.sh
```

## Architecture: how a student's code ends up moving a physical motor

This section exists because bringing up real hardware against this repo for the first time means re-deriving all of the following from scratch, across five separate repositories, with no single place any of it is written down. If you're the next person doing that, start here.

### The full pipeline, end to end

```
Browser (frontend)
  │  student writes Python, hits Run
  ▼
py-slang (EV3Engine.ts)
  │  compiles Python -> PVML bytecode (never interprets it locally for EV3 -
  │  the compiled blob is what gets shipped to the device)
  ▼
Backend (api.sourceacademy.nus.edu.sg or api.stg.*)
  │  device pairing / auth: given a device's secret, hands back MQTT
  │  connection info + a signed cert/key for that specific device
  ▼
AWS IoT Core (MQTT broker - one per backend, prod and stg are entirely
  │  separate: separate device databases, separate brokers)
  │  browser and EV3 both connect here independently; this is the relay,
  │  not a direct connection between them
  ▼
sling (persistent process on the physical EV3, `sling.service`/`sling-python.service`)
  │  holds the MQTT connection, receives the bytecode blob, writes it to
  │  disk, then fork()+exec()s an interpreter binary as a child process to
  │  actually run it, and relays that child's output back over MQTT
  ▼
sinter_host (Source pipeline) OR pynter-ev3 (Python pipeline)
  │  the actual interpreter for the compiled bytecode. Two independent,
  │  parallel pipelines with the same shape (see below)
  ▼
ev3_functions.c (inside pynter's `devices/ev3/`, or sinter's equivalent)
  │  the primitives (ev3_motorA(), ev3_colorSensor(), ...) that actually
  │  read/write ev3dev's sysfs device files
  ▼
Physical hardware
```

### Two independent, structurally identical pipelines

This device has always run **two completely separate interpreters side by side**, each with its own systemd service, its own on-disk secret/identity, and its own registration with the backend - they don't share state or interfere with each other:

| | Source-language pipeline | Python pipeline |
|---|---|---|
| Compiler | js-slang (in the frontend) | py-slang's `EV3Engine.ts` |
| Bytecode format | SVML | PVML |
| systemd service | `sling.service` | `sling-python.service` |
| Secret/identity dir | `/var/lib/sling` | `/var/lib/sling-python` |
| Interpreter binary | `sinter_host` (from [`sling`](https://github.com/source-academy/sling)'s `deps/sinter`) | `pynter-ev3` (from [`pynter`](https://github.com/source-academy/pynter)) |

`sling` itself is transport-only and doesn't know or care which language it's relaying bytecode for - it just spawns whatever `SINTER_HOST_PATH` points at. This is why `pynter-ev3` had to independently learn a lesson `sinter_host` already knew (see below): they're siblings, not the same code, and a fix in one doesn't automatically apply to the other.

### The sling IPC channel between `sling` and the interpreter it spawns

`sling` invokes the interpreter as `<binary> --from-sling <program_path>` (see `sling/linux/src/main.c`'s `begin_run_program`), after first setting up a `SOCK_DGRAM` **socketpair** and `dup2`-ing one end onto fd 998 in the child. A socketpair is bidirectional by construction - this is not a one-way pipe. `sling`'s own protocol (`sling/common/sling_message.h`) defines structured messages both ways, including an `input` topic for feeding typed user input back into a running program (e.g. Python's `input()`).

The interpreter uses this same fd to send `print()`/`display()` output back to `sling`, which relays it over MQTT to the browser as a `display` topic message. `sinter_host` has always done this correctly. `pynter-ev3`, however, is built from a generic CLI-testing tool (`pynter`'s `runner/src/runner.c`) whose print callbacks were plain `printf` to whatever stdout the process happened to inherit - which, under `sling`, just vanished, discarded rather than actually being one-directional. This has since been fixed (see "Known repos and pending work" below) by porting `sinter_host`'s exact relay logic into `pynter`.

### Why devices must be paired separately per backend

Production (`sourceacademy.nus.edu.sg`, backend `api.sourceacademy.nus.edu.sg`) and staging (`stg.sourceacademy.nus.edu.sg`, backend `api.stg.sourceacademy.nus.edu.sg`) are **entirely separate deployments** - separate device databases, separate AWS IoT brokers. Pairing a device's secret against one backend does nothing for the other; a device paired only on stg will never show as connected on prod, and vice versa. `image/start-sling.sh`/`image/start-sling-python.sh` accept a backend host as an argument for exactly this reason, and each backend now gets its own persistent service (`sling.service`/`sling-stg.service`, `sling-python.service`/`sling-python-stg.service`) so a device holds a genuinely live connection to both at once, regardless of which frontend a user happens to be testing from.

### Device secrets: how they're generated, and how the connection is actually authenticated

Each device generates its own secret independently, per pipeline, the first time that pipeline's service ever runs (see `image/start-sling.sh`/`image/start-sling-python.sh`):

```bash
uuidgen -r > secret          # a cryptographically random (v4) UUID
uuidtob62 secret > secret_b62  # re-encoded as base62 - shorter, URL-safe, same entropy
```

Nothing about the secret is derived from the device's hardware, and it isn't shared between the two pipelines on the same physical EV3 - the Source secret and the Python secret are two independent random values, generated independently, the first time each pipeline's own service happens to run.

**The secret itself is never an MQTT credential.** Its only job is as a one-time bootstrapping token against the backend's HTTP API:

1. The device calls `GET /v2/devices/<secret>/mqtt_endpoint` and `/client_id` over HTTPS. The backend only answers if that secret has actually been **claimed** - i.e. a user registered it via the frontend's "Add new device" flow, which is the action that actually provisions a real device identity (an AWS IoT "Thing") behind the scenes. An unclaimed secret 404s on these endpoints (this is exactly what a device stuck in `sling(-python)?(-stg)?.service`'s restart loop looks like - see "Known repos and pending work" below for the bug this surfaced).
2. Once claimed, the device also calls `/key` and `/cert`, which hand back a real **X.509 client certificate and private key** specific to that Thing.
3. The actual MQTT connection to AWS IoT Core authenticates via **mutual TLS using that certificate** - not the secret string. AWS IoT validates the certificate against its own device registry, and that Thing's IoT policy scopes exactly which MQTT topics it may publish/subscribe to, so one device's certificate can't impersonate or snoop on another device's topics.
4. The browser goes through the same claim step (it's the one doing the claiming) and receives its own separate, similarly-scoped connection credentials for the same device's topic namespace, letting it publish "run" commands and subscribe to that device's `display`/`status` output.

So the secret's actual role is narrow and short-lived: it's what you type or scan once to prove "I own this physical device" to the backend, which then hands out real, properly-scoped TLS credentials for the actual data channel - the secret itself never touches AWS IoT directly. "Invalidate Bot Token" (in the on-device Source Academy Settings app) works by discarding that claim and generating a fresh random secret in its place - it does not touch or rotate the underlying certificate machinery, it just means the old secret (and whatever it was claimed as) no longer corresponds to anything.

### Known repos and pending work (accurate as of this PR)

| Fix | Repo | PR |
|---|---|---|
| Boot-reliability fixes (fstab timeout, connman deadlock, udev UDC tagging, ext4/e2fsck version-skew) + dual prod/stg connectivity + CI Python build | `ev3-source` | [#21](https://github.com/source-academy/ev3-source/pull/21) |
| EV3 Python conductor UI, device pairing flow, REPL support during remote execution | `frontend` | [#4025](https://github.com/source-academy/frontend/pull/4025) |
| Python -> PVML compiler, `ev3_*` stdlib bindings | `py-slang` | [#461](https://github.com/source-academy/py-slang/pull/461) |
| `runner`'s `--from-sling` argv parsing + print() output relay over the sling IPC channel | `pynter` | [#41](https://github.com/source-academy/pynter/pull/41) |

If you're reading this after some of these have merged, treat the PR links as historical context for *why* the surrounding code looks the way it does, not as an up-to-date "still pending" list.
