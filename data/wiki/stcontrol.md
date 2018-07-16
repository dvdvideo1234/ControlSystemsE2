### What is this thing designed for ?
The `STcontrol` class consists of fast preforming controller object oriented
instance that is designed to be `@persist`and initialized in expression
`first() || dupefinished()`. That way you create the controller instance once
and you can use it as many times you need, without creating a new one.

### How to create an instance then ?
You can create controller object by calling one of the dedicated factories `newStControl` below 
either with an argument of sampling time to make the sampling time static or without
parameter to make it take the value dynamically as something other may slow down the E2.
Then you must activate the instance `setIsActive(1)` to enable it calculate the control signal,
apply the current state values `setState` and retrieve the control signal afterwards by calling
`getControl%`.

### Do you have an example by any chance ?
The internal type of the class is `xsc` and internal expression type `stcontrol`, so to create 
an instance you can take a [look at the example](https://github.com/dvdvideo1234/ControlSystemsE2/blob/master/data/Expression2/e2_code_test_stcontrol.txt).

### Can you show me the methods of the class ?
The description of the API is provided in the table below.

| Instance creator | Description |
|---|---|
| copyStControl(xsc:) | Returns state control object copy instance |
| newStControl() | Returns state control object with dynamic sampling time |
| newStControl(n) | Returns state control object with static sampling time |
| noStControl() | Returns invalid state control object |

| Method/Function | Description |
|---|---|
| dumpConsole(xsc:s) | Dumps state control internal parameters into the console |
| getBias(xsc:) | Returns state control control bias |
| getControl(xsc:) | Returns state control automated control signal signal |
| getControlTerm(xsc:) | Returns state control automated control term signal |
| getControlTermD(xsc:) | Returns state control derivative automated control term signal |
| getControlTermI(xsc:) | Returns state control integral automated control term signal |
| getControlTermP(xsc:) | Returns state control proportional automated control term signal |
| getErrorDelta(xsc:) | Returns state control process error delta |
| getErrorNow(xsc:) | Returns state control process current error |
| getErrorOld(xsc:) | Returns state control process passed error |
| getGain(xsc:) | Returns state control proportional term gain, integral term gain and derivative term gain |
| getGainD(xsc:) | Returns state control derivative term gain |
| getGainI(xsc:) | Returns state control integral term gain |
| getGainID(xsc:) | Returns state control integral term gain and derivative term gain |
| getGainP(xsc:) | Returns state control proportional term gain |
| getGainPD(xsc:) | Returns state control proportional term gain and derivative term gain |
| getGainPI(xsc:) | Returns state control proportional term gain and integral term gain |
| getManual(xsc:) | Returns state control manual control signal value |
| getPower(xsc:) | Returns state control proportional term power, integral term power and derivative term power |
| getPowerD(xsc:) | Returns state control derivative term power |
| getPowerI(xsc:) | Returns state control integral term power |
| getPowerID(xsc:) | Returns state control integral term power and derivative term power |
| getPowerP(xsc:) | Returns state control proportional term power |
| getPowerPD(xsc:) | Returns state control proportional term power and derivative term power |
| getPowerPI(xsc:) | Returns state control proportional term power and integral term power |
| getTimeBench(xsc:) | Returns state control process benchmark time |
| getTimeDelta(xsc:) | Returns state control dymamic process time delta |
| getTimeNow(xsc:) | Returns state control process current time |
| getTimeOld(xsc:) | Returns state control process passed time |
| getTimeRatio(xsc:) | Returns state control process time ratio |
| getTimeSample(xsc:) | Returns state control static process time delta |
| getType(xsc:) | Returns state control control type |
| getWindup(xsc:) | Returns state control windup lower bound and windup upper bound |
| getWindupD(xsc:) | Returns state control windup lower bound |
| getWindupU(xsc:) | Returns state control windup upper bound |
| isActive(xsc:) | Checks state control activated working flag |
| isCombined(xsc:) | Checks state control combined flag spreading proportional term gain across others |
| isIntegrating(xsc:) | Checks integral enabled flag |
| isInverted(xsc:) | Checks state control inverted feedback flag of the reference and setpoint |
| isManual(xsc:) | Checks state control manual control flag |
| remGain(xsc:) | Removes state control proportional term gain, integral term gain and derivative term gain |
| remGainD(xsc:) | Removes state control derivative term gain |
| remGainI(xsc:) | Removes state control integral term gain |
| remGainID(xsc:) | Removes state control integral term gain and derivative term gain |
| remGainP(xsc:) | Removes state control proportional term gain |
| remGainPD(xsc:) | Removes state control proportional term gain and derivative term gain |
| remGainPI(xsc:) | Removes state control proportional term gain and integral term gain |
| remTimeSample(xsc:) | Removes state control static process time delta |
| remWindup(xsc:) | Removes state control windup lower bound and windup upper bound |
| remWindupD(xsc:) | Removes state control windup lower bound |
| remWindupU(xsc:) | Removes state control windup upper bound |
| resState(xsc:) | Resets state control automated internal parameters |
| setBias(xsc:n) | Updates state control control bias |
| setGain(xsc:nnn) | Updates state control proportional term gain, integral term gain and derivative term gain |
| setGain(xsc:r) | Updates state control proportional term gain, integral term gain and derivative term gain |
| setGain(xsc:v) | Updates state control proportional term gain, integral term gain and derivative term gain |
| setGainD(xsc:n) | Updates state control derivative term gain |
| setGainI(xsc:n) | Updates state control integral term gain |
| setGainID(xsc:nn) | Updates state control integral term gain and derivative term gain |
| setGainID(xsc:r) | Updates state control integral term gain and derivative term gain |
| setGainID(xsc:xv2) | Updates state control derivative term gain and derivative term gain |
| setGainP(xsc:n) | Updates state control proportional term gain |
| setGainPD(xsc:nn) | Updates state control proportional term gain and derivative term gain |
| setGainPD(xsc:r) | Updates state control proportional term gain and derivative term gain |
| setGainPD(xsc:xv2) | Updates state control proportional term gain and derivative term gain |
| setGainPI(xsc:nn) | Updates state control proportional term gain and integral term gain |
| setGainPI(xsc:r) | Updates state control proportional term gain and integral term gain |
| setGainPI(xsc:xv2) | Updates state control proportional term gain and integral term gain |
| setIsActive(xsc:n) | Updates state control activated working flag |
| setIsCombined(xsc:n) | Updates combined flag spreading proportional term gain across others |
| setIsIntegrating(xsc:n) | Updates integral enabled flag |
| setIsInverted(xsc:n) | Updates state control inverted feedback flag of the reference and setpoint |
| setIsManual(xsc:n) | Updates state control manual control signal value |
| setPower(xsc:nnn) | Updates state control proportional term power, integral term power and derivative term power |
| setPower(xsc:r) | Updates state control proportional term power, integral term power and derivative term power |
| setPower(xsc:v) | Updates state control proportional term power, integral term power and derivative term power |
| setPowerD(xsc:n) | Updates state control derivative term power |
| setPowerI(xsc:n) | Updates state control integral term power |
| setPowerID(xsc:nn) | Updates state control integral term power and derivative term power |
| setPowerID(xsc:r) | Updates state control integral term power and derivative term power |
| setPowerID(xsc:xv2) | Updates state control derivative term power and derivative term power |
| setPowerP(xsc:n) | Updates state control proportional term power |
| setPowerPD(xsc:nn) | Updates state control proportional term power and derivative term power |
| setPowerPD(xsc:r) | Updates state control proportional term power and derivative term power |
| setPowerPD(xsc:xv2) | Updates state control proportional term power and derivative term power |
| setPowerPI(xsc:nn) | Updates state control proportional term power and integral term power |
| setPowerPI(xsc:r) | Updates state control proportional term power and integral term power |
| setPowerPI(xsc:xv2) | Updates state control proportional term power and integral term power |
| setState(xsc:nn) | Works state control automated internal parameters |
| setTimeSample(xsc:) | Updates state control static process time delta |
| setWindup(xsc:nn) | Updates state control windup lower bound and windup upper bound |
| setWindup(xsc:r) | Updates state control windup lower bound and windup upper bound |
| setWindup(xsc:xv2) | Updates state control windup lower bound and windup upper bound |
| setWindupD(xsc:n) | Updates state control windup lower bound |
| setWindupU(xsc:n) | Updates state control windup upper bound |