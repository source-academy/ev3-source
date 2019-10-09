var ev3dev = require('../ev3dev-lang/bin/index.js');


/**
 * Hello world!
 *
 * @alias ev3_hello
 */
exports.hello = function() {
  console.log("Hello there! Welcome to LEGO ev3 (adapted by CS1101S)!");
};

/**
 * Checks if the peripheral is connected.
 *
 * @param {peripheral} obj - The peripheral to check.
 * @returns {boolean} true if the peripheral is connected, false otherwise
 * @alias ev3_connected
 */
exports.connected = function(obj) {
  return (typeof obj.connected === 'boolean') && obj.connected;
};

/**
 * Gets the motor connected to port A.
 *
 * @returns {peripheral} The motor connected to port A.
 * @alias ev3_motorA
 */
exports.motorA = function() {
  var motor = new ev3dev.Motor(ev3dev.OUTPUT_A);
  return motor;
};

/**
 * Gets the motor connected to port B.
 *
 * @returns {peripheral} The motor connected to port B.
 * @alias ev3_motorB
 */
exports.motorB = function() {
  var motor = new ev3dev.Motor(ev3dev.OUTPUT_B);
  return motor;
};

/**
 * Gets the motor connected to port C.
 *
 * @returns {peripheral} The motor connected to port C.
 * @alias ev3_motorC
 */
exports.motorC = function() {
  var motor = new ev3dev.Motor(ev3dev.OUTPUT_C);
  return motor;
};

/**
 * Gets the motor connected to port D.
 *
 * @returns {peripheral} The motor connected to port D.
 * @alias ev3_motorD
 */
exports.motorD = function() {
  var motor = new ev3dev.Motor(ev3dev.OUTPUT_D);
  return motor;
};

/**
 * Causes the motor to rotate for a specified number of rotations at the specified speed.
 *
 * Note: this works by sending instructions to the motors. This will return almost immediately, without waiting for the motor to actually run for the specified distance. If you wish to wait, use {@link ev3_pause}.
 *
 * @param {peripheral} motor - The motor
 * @param {number} rotations - The number of rotations to turn, in motor-specific units
 * @param {number} speed - The speed to run at, in motor-specific units
 * @alias ev3_runForDistance
 */
exports.runForDistance = function(motor, rotations, speed) {
  motor.runForDistance(rotations, speed);
};

/**
 * Causes the motor to rotate for a specified duration at the specified speed.
 *
* Note: this works by sending instructions to the motors. This will return almost immediately, without waiting for the motor to actually run for the specified duration. If you wish to wait, use {@link ev3_pause}.
 *
 * @param {peripheral} - The motor
 * @param {number} - The duration to turn, in milliseconds
 * @param {number} - The speed to run at, in motor-specific units
 * @alias ev3_runForTime
 */
exports.runForTime = function(motor, time, speed) {
  motor.runForTime(time, speed);
};

/**
 * Causes the motor to stop.
 *
 * @param {peripheral} motor - The motor
 * @alias ev3_stop
 */
exports.stop = function(motor) {
  motor.stop();
};

/**
 * Gets the colour sensor connected any of ports 1, 2, 3 or 4.
 *
 * @returns {peripheral} The colour sensor.
 * @alias ev3_colorSensor
 */
exports.colorSensor = function() {
  var colorSensor = new ev3dev.ColorSensor();
  return colorSensor;
};

/**
 * Gets the amount of red seen by the colour sensor.
 *
 * @param {peripheral} colorSensor - The colour sensor.
 * @returns {number} The amount of red, in sensor-specific units.
 * @alias ev3_colorSensorRed
 */
exports.colorSensorRed = function(colorSensor) {
  return colorSensor.red;
}

/**
 * Gets the amount of green seen by the colour sensor.
 *
 * @param {peripheral} colorSensor - The colour sensor.
 * @returns {number} The amount of green, in sensor-specific units.
 * @alias ev3_colorSensorGreen
 */
exports.colorSensorGreen = function(colorSensor) {
  return colorSensor.green;
}

/**
 * Gets the amount of blue seen by the colour sensor.
 *
 * @param {peripheral} colorSensor - The colour sensor.
 * @returns {number} The amount of blue, in sensor-specific units.
 * @alias ev3_colorSensorBlue
 */
exports.colorSensorBlue = function(colorSensor) {
  return colorSensor.blue;
}

/**
 * Gets the reflected light intensity seen by the colour sensor.
 *
 * @param {peripheral} colorSensor - The colour sensor.
 * @returns {number} The reflected light intensity, as a percentage from 0 to 100.
 * @alias ev3_reflectedLightIntensity
 */
exports.reflectedLightIntensity = function(colorSensor) {
  return colorSensor.reflectedLightIntensity;
};

/**
 * Gets the ambient light intensity seen by the colour sensor.
 *
 * @param {peripheral} colorSensor - The colour sensor.
 * @returns {number} The ambient light intensity, as a percentage from 0 to 100.
 * @alias ev3_ambientLightIntensity
 */
exports.ambientLightIntensity = function(colorSensor) {
  return colorSensor.ambientLightIntensity;
};

/**
 * Gets the touch sensor connected to port 1.
 *
 * @returns {peripheral} The touch sensor.
 * @alias ev3_touchSensor1
 */
exports.touchSensor1 = function() {
  var touchSensor = new ev3dev.TouchSensor(ev3dev.INPUT_1);
  return touchSensor;
};

/**
 * Gets the touch sensor connected to port 2.
 *
 * @returns {peripheral} The touch sensor.
 * @alias ev3_touchSensor2
 */
exports.touchSensor2 = function() {
  var touchSensor = new ev3dev.TouchSensor(ev3dev.INPUT_2);
  return touchSensor;
};

/**
 * Gets whether the touch sensor is pressed.
 *
 * @param {peripheral} touchSensor - The touch sensor.
 * @returns {number} A value based on the amount of pressure detected by the touch sensor.
 * @alias ev3_touchSensorPressed
 */
exports.touchSensorPressed = function(touchSensor) {
  return touchSensor.getValue(0);
};

/**
 * Gets the ultrasonic sensor connected any of ports 1, 2, 3 or 4.
 *
 * @returns {peripheral} The ultrasonic sensor.
 * @alias ev3_ultrasonicSensor
 */
exports.ultrasonicSensor = function() {
  var ultrasonicSensor = new ev3dev.UltrasonicSensor();
  return ultrasonicSensor;
};

/**
 * Gets the distance read by the ultrasonic sensor in centimeters.
 *
 * @param {peripheral} ultrasonicSensor - The ultrasonic sensor.
 * @returns {number} The distance, in centimeters.
 * @alias ev3_ultrasonicSensorDistance
 */
exports.ultrasonicSensorDistance = function(ultrasonicSensor) {
  return ultrasonicSensor.distanceCentimeters;
};

/**
 * Gets the gyro sensor connected any of ports 1, 2, 3 or 4.
 *
 * @returns {peripheral} The gyro sensor.
 * @alias ev3_gyroSensor
 */
exports.gyroSensor = function() {
  var gyroSensor = new ev3dev.GyroSensor();
  return gyroSensor;
};

/**
 * Gets the rate of rotation detected by the gyro sensor.
 *
 * @param {peripheral} gyroSensor - The gyro sensor.
 * @returns {number} The rate of rotation, in degrees per second.
 * @alias ev3_gyroSensorRate
 */
exports.gyroSensorRate = function(gyroSensor) {
  return gyroSensor.rate;
};

/**
 * Gets the absolute angle detected by the gyro sensor, relative to
 * a fixed but undefined starting point.
 *
 * @param {peripheral} gyroSensor - The gyro sensor.
 * @returns {number} The angle, in degrees.
 * @alias ev3_gyroSensorAngle
 */
exports.gyroSensorAngle = function(gyroSensor) {
  return gyroSensor.angle;
};

/**
 * Pauses for a period of time.
 *
 * @param {number} time - The time to wait, in milliseconds.
 * @alias ev3_pause
 */
exports.pause = function(time) {
  var start = (new Date()).getTime();
  while ((new Date()).getTime() - start < time) {}
};

/**
 * Runs task() until terminateCondition() is true.
 *
 * @param {function} terminateCondition
 * @param {function} task
 * @alias ev3_runUntil
 */
exports.runUntil = function(terminateCondition, task) {
  while (!terminateCondition()) {
    task();
  }
};