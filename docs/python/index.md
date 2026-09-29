---
title: EV3-Source OS Guide (Python)
layout: default
---

<!-- markdownlint-disable-next-line blanks-around-headers -->
# EV3-Source OS Guide (Python)
{: .no_toc}

Welcome to the world of LEGO Mindstorms EV3! Work together with your teammates to create the best robot and impress everyone.

> This is the **Python** version of this guide. Looking for Source (JavaScript)? See [the original guide](../).

|              Quick Links              |
|:-------------------------------------:|
| [EV3 library documentation][ev3-docs] |
| [Latest EV3-Source image][latest-img] |

<!-- markdownlint-disable-next-line blanks-around-headers -->
## Table of Contents
{: .no_toc}

1. toc
{:toc}

## Setting up

### Background

#### Hardware setup

Instructions for a default robot design are included in the manual, which can be found in the robot kit. Try that out if you don't know where to start. You are, however, encouraged to come up with your own design!

For the mission, it must be a robot that your Studio has built. Sharing of the same robot for grading, no matter using the same program or different programs, is strictly **NOT** allowed.

#### Software setup

The environment that we have installed in the microSD card is a customised version of a Linux distribution from a project called [ev3dev](http://www.ev3dev.org/). You can find out more about it from [the official website](http://www.ev3dev.org/).

When you press "Run" in the Source Academy, your Python program is compiled in the browser to PVM bytecode by [py-slang](https://github.com/source-academy/py-slang), sent to the robot through the internet, and run there by [Pynter](https://github.com/source-academy/pynter), a virtual machine built specifically for running Python programs on embedded devices like the EV3.

### Installing EV3-Source on your robot

#### Windows, macOS, Linux

1. Download the [Source Academy's customised ev3dev image][latest-img].

1. Use an image burner (we recommend [Etcher](https://etcher.balena.io/)) to install the image onto the microSD card issued. You will require a microSD card reader for this.

   You may follow this guide (_"Flash the SD card"_ section) [from the ev3dev site](https://www.ev3dev.org/docs/getting-started/#step-2-flash-the-sd-card) to do so.

   **Note: Download the [customised EV3-Source image][latest-img], not the ev3dev release image.**

   File Explorer (Windows)/Finder (macOS) may say that it is unable to read the card, or the card needs to be formatted. This is **normal** and can be ignored. Etcher will be able to flash the card.

   If this does not work, try the [alternative flashing instructions on the main guide](../#alternative-flashing-instructions) — the flashing process itself is identical regardless of language.

1. Once the image has been flashed onto the microSD card, insert it into the EV3, but do not power it on yet.

1. Plug in the WiFi dongle into the USB port of the EV3 (if your EV3 doesn't have built-in WiFi).

### Starting up the EV3

1. Power on the EV3 by pressing the center button and wait for the main menu to appear. The first time you do this, it may take longer.

   > **This is expected, intentional behaviour — not a bug or a broken flash.** On the very first boot of a freshly flashed card, you will likely see the main menu appear, then **the screen goes back to boot logs and it restarts on its own**, with the status light **blinking orange** while this happens. It may cycle through this more than once before settling. This is the device automatically finishing first-time setup in the background (disabling SSH by default, generating a fresh random password, and a few other one-time steps) — it deliberately reboots itself once this is done, regardless of whether WiFi is connected yet.
   >
   > Do not press any buttons, remove the card, or power it off during this. It will stabilise on its own — a **solid green** light (not blinking) means it's actually settled and ready. The whole process usually takes around 10 minutes — leave it alone, grab a coffee, and come back later. This only ever happens once per card, the very first time it boots.

1. Once the EV3 is fully booted up, you should see the following screen:

   ![](../images/ev3/file_browser.png)

   This means you are ready to proceed to the next step to connect to WiFi.

   _**Tip:** the number you see at the top-right of the screen is the battery voltage in volts. A fully charged battery should read somewhere around 8.3 V, and below 6 V, your battery will be running flat soon._

   _**Troubleshooting:** if you don't see the screen above, chances are your microSD card was not inserted properly, and thus the EV3 boots to its default OS instead. Try to power off the EV3 (top-left button), and removing and re-inserting the microSD card, making sure that it is not loose._

## Connecting the EV3 to Source Academy

### Introduction

Our customised EV3-Source image is integrated with the Source Academy. You can simply register your device with the Source Academy, write your programs in the playground in remote execution mode with **Python** selected as your language, and click "Run" as per normal to run your programs on the robot.

### Connecting the EV3 to WiFi

The preferred method of connecting the EV3 to the internet is via WiFi.

#### Connecting to a personal hotspot

1. From the main menu, select 'Wireless and Networks'
1. Select 'Wi-Fi' and ensure it is powered on
1. Select your network and connect to it. If your network is secured with a password, the EV3 will prompt you for one when you press 'Connect'

**Your computer and the EV3 do not need to be on the same network.** Pairing and running code both go through Source Academy's own server as a relay, not a direct connection between your browser and the robot — your laptop can be on a completely different network to the EV3 and everything still works. (The only exception is SSH — see the [Advanced](#advanced) section.)

> **Troubleshooting**
>
> If connecting to WiFi does not work for some reason, please **ask for help in the forum**.
>
> Alternatively, the EV3 can also connect to your computer/phone over USB or Bluetooth. (The benefit of Bluetooth is, of course, that it is wireless, but it may be slightly less reliable.)
>
> * To connect your EV3 to the Internet via Bluetooth, follow [these instructions](https://www.ev3dev.org/docs/tutorials/connecting-to-the-internet-via-bluetooth/).
>
>   _Note: Bluetooth connection sharing no longer works with Windows 10 onwards. It remains working for macOS and Android. If you cannot use Bluetooth connection sharing, please use an alternative method._
>
> * To connect your EV3 via the USB wire provided, follow [these instructions](https://www.ev3dev.org/docs/tutorials/connecting-to-the-internet-via-usb/).

Once you have connected successfully, you should see your EV3's local IP address on the top left-hand corner of the EV3's screen. This means you are connected.

![](../images/ev3/ip.png)

### Registering your EV3 with Source Academy

Everyone on the team will have to **individually** link their team's EV3 with their own Source Academy account.

There are two methods to register the EV3:

#### Method 1: Scanning a QR code

On a computer/mobile device (the latter is preferred because of a better camera):

1. Go to the [Source Academy Playground](https://sourceacademy.nus.edu.sg/playground) and select the "Remote Execution" tab (the one with the satellite icon)

   ![](../images/sa1.png)

1. Click on "Add new device..."

1. Enter a name for you to identify your device, and select **Lego Mindstorms EV3** as the type

   ![](../images/sa2.png)

1. Click the button on the right side of the "Secret" field to open a QR code scanner. You may need to grant Source Academy access to your camera in the browser

1. You are now ready to scan the QR code on the EV3!

Then, on the EV3 device:

1. Go to the file browser and select "Show QR Code". A QR code will be shown on the screen (the following is only a sample, yours will be different):

   ![](../images/ev3/qr.png)

   **Note:** There is a bug at the moment in that the first time you run "Show QR Code", the QR code may not be shown properly on the screen. Simply wait for it to disappear, run it again and it should work.

1. Place the EV3 such that the QR code is visible in the computer/phone's camera view in order to scan the QR code

After 10 seconds, the QR code will automatically disappear. If you need more time, simply select "Show QR Code" again. After scanning the code on your computer/phone, click the add button. You have successfully linked the EV3 to your account!

> **Note:** unlike the Source version of this guide, there is currently no browser/webserver-based method (`http://<ev3's local IP>/`) for registering a Python device — that page only ever shows the Source pipeline's secret, not Python's. Use "Show QR Code" (above) instead.

---

Click on the new entry that is created. Once you see "Connected to _\<your_device_name\>_.", you should be able to run programs on the EV3!

![](../images/sa3.png)

If you are stuck on "Connecting..." for a while, try selecting the device again to attempt a re-connection.

### Some things to take note

If you discover any bugs, please let us know in the forum.

## Python language

The language for this mission is Python, plus the special [EV3 library][ev3-docs] — every `ev3_*` function has the same name, arguments, and behaviour as its Source counterpart, so the same library reference applies to both.

Part of the fun is learning how to troubleshoot. If you have difficulties, start by Googling your problems. For debugging, use `print()` in your programs the same way you would in any other Python code — the output will appear in the Playground.

### Examples

#### Example 1: checking peripherals are connected

```python
motorA = ev3_motorA()
motorB = ev3_motorB()

print("A connected" if ev3_connected(motorA) else "A not connected")
print("B connected" if ev3_connected(motorB) else "B not connected")

ev3_runToRelativePosition(motorA, 3000, 100)
ev3_runToRelativePosition(motorB, -2000, 100)
ev3_pause(1000)
```

#### Example 2: reading a sensor

```python
color = ev3_colorSensor()
if ev3_reflectedLightIntensity(color) > 20:
    pass  # Do something
else:
    pass  # Do something else
```

#### Example 3: a simple line follower

Mount a light/colour sensor near one edge of a black line on a white floor, with drive motors on ports A and B:

```python
BASE_SPEED = 200
KP = 4          # steering aggressiveness - tune this
TARGET = 50     # reflected-light value at the line's edge - tune to your floor/line contrast

left = ev3_motorA()
right = ev3_motorB()
sensor = ev3_colorSensor()

ev3_motorStart(left)
ev3_motorStart(right)

while True:
    light = ev3_reflectedLightIntensity(sensor)
    error = light - TARGET
    turn = KP * error

    ev3_motorSetSpeed(left, BASE_SPEED + turn)
    ev3_motorSetSpeed(right, BASE_SPEED - turn)

    ev3_pause(10)
```

> **Note on timing:** `ev3_motorStart`/`ev3_motorStop` are both non-blocking — they just tell the motor to start or stop and return immediately. A program that calls `ev3_motorStart` immediately followed by `ev3_motorStop`, with nothing in between, will not visibly move the motor at all: on-device code runs as fast as the interpreter can execute it, so "stop" arrives before the motor has had any real time to move. Use `ev3_pause(ms)`, or a loop with real work in it like the example above, to give the motor actual wall-clock time to move.

### Tips

* At any time, if you feel that the device secret has been compromised, you can invalidate and generate a new one using "Invalidate Bot Token" under [Source Academy Settings](#source-academy-settings). Afterwards, everyone will need to re-register their device on Source Academy using the new secret.
* Multiple users can connect to the same device at the same time. If one user clicks "Run", all users will see the device run and the device's output.
* You can use this feature with the collaborative editing feature so that all members of your Studio can work on the program together. You can also use it with the Google Drive integration to save different programs that you write.

#### Troubleshooting

For macOS users, and connect using USB, you might not see 'CDC Composite Gadget' in the interfaces list under network configuration. Try to connect via Bluetooth instead.

## Advanced

### Source Academy Settings

Source Academy Settings is a one-stop app to manage some of the customizations that are present on the EV3 image. Select "Source Academy Settings" from the file browser to launch it.

You can navigate the UI by using the up and down arrow keys on the EV3, and select an option by pressing the center button. There are the following available options.

|                        Option                        | Description                                                                                                                                                                                                        |
|:----------------------------------------------------:|:-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| ![Invalidate Bot Token](../images/ev3/sa_settings1.png) | Invalidates the device secret and generates a new one. Note that you still need to run the "Show QR Code" app separately in order to regenerate the QR code image.                                                 |
|      ![Enable SSH](../images/ev3/sa_settings2.png)      | Toggles SSH on/off. Off by default. Note that the UI may seem to freeze for a few seconds after pressing this button. This is normal; please do not spam the button or press other buttons while it is processing. |
|  ![Reset SSH Password](../images/ev3/sa_settings3.png)  | Generates a new password for SSH login.                                                                                                                                                                            |
|   ![Enable Webserver](../images/ev3/sa_settings4.png)   | Toggles whether to display the secret in the web server located at the EV3's IP address.                                                                                                                           |

### SSH-ing to the EV3

> **Note:** SSH is disabled by default. You need to enable SSH via [Source Academy Settings](#source-academy-settings) in order to use this feature. Unlike everything else in this guide, SSH requires your computer and the EV3 to be on the **same network** — it's a direct connection, not something that goes through Source Academy's server.

The EV3 can also be accessed via SSH to get a full command line, for advanced debugging — you will not need this for normal coursework. To SSH to the EV3, run

```bash
ssh robot@192.168.0.1
```

where `192.168.0.1` is the address shown at the top-left of the EV3.

Enter your password when prompted. The default password is a random string, thus **you will need to generate a password first**. In [Source Academy Settings](#source-academy-settings), click "Reset SSH Password". You will see a pop up with the new password. Take note of this, as this is the only time you will be able to see it. If you ever forget the password, you can generate a new one using this same way.

If you are on Linux or macOS, you should have an SSH client already installed. Windows 10 includes an SSH client from version 1803 onwards. On older versions of Windows, you can use other SSH clients like [PuTTY](http://www.putty.org/). The username is `robot`, and the hostname is the IP address shown on the top-left of the EV3 screen.

> **⚠️ If you're using a phone as a WiFi hotspot for SSH:** check that "AP isolation" / "Client isolation" is turned off in the hotspot's settings. Many phones enable this by default, which blocks devices on the same hotspot from reaching each other directly — including your laptop reaching the EV3 over SSH — even though both show as "connected" to the same network. There's no error message for this; SSH just times out, which is confusing without knowing to look here. This has no effect on pairing or running code, since those don't need a direct connection at all.

## Appendix

### Alternative flashing instructions

See [the main guide's appendix](../#alternative-flashing-instructions) — the flashing process is identical regardless of language.

[latest-img]: https://github.com/source-academy/ev3-source/releases/latest/download/ev3-source.img.zip
[ev3-docs]: https://docs.sourceacademy.org/EV3/
