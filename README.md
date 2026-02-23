# Agilent34405A — MATLAB Instrument Driver

A MATLAB class for controlling the **Agilent 34405A bench multimeter** over USB/VISA. Provides a clean, object-oriented interface for all major measurement modes, configuration, and instrument lifecycle management.

---

## Requirements

- MATLAB with the **Instrument Control Toolbox**
- **NI-VISA** driver installed
- `Agilent34405AStates` enumeration class (companion file)

---

## Installation

1. Clone or download this repository.
2. Add the folder to your MATLAB path:
   ```matlab
   addpath('/path/to/Agilent34405A');
   ```
3. Ensure the multimeter is connected via USB and recognized by NI-VISA.

---

## Quick Start

```matlab
% Instantiate — automatically finds the instrument via USB
dmm = Agilent34405A();

% Read DC voltage
v = dmm.readDCV();

% Read AC current
i = dmm.readACI();

% Read temperature
t = dmm.readTemp();

% Clean up when done
dmm.deInit();
```

---

## Supported Measurement Modes

| Method | Description |
|---|---|
| `readDCV()` | DC Voltage |
| `readACV()` | AC Voltage |
| `readDCI()` | DC Current |
| `readACI()` | AC Current |
| `readTemp()` | Temperature |
| `read2WRes()` | 2-Wire Resistance |
| `readCont()` | Continuity |
| `readDiode()` | Diode Test |
| `readCapacitance()` | Capacitance |
| `readFrequency()` | Frequency |
| `readPeriod()` | Period |
| `scan()` | Scan mode |

All measurement methods automatically switch the instrument to the correct mode if it isn't already configured.

---

## Configuration & Utilities

### Set Measurement Scale
```matlab
% obj.setScale(state_string, [resolution, range])
dmm.setScale('VOLT:DC', [0.001, 10]);
```

### Trigger & Sample Settings
```matlab
dmm.sampleCount  = 20;   % Number of samples (default: 10)
dmm.triggerCount = 4;    % Trigger count (default: 1)

dmm.setSampleCount();    % Apply sample count to instrument
dmm.setTriggerCount();   % Apply trigger count to instrument
dmm.setTriggerSource('BUS');  % Set trigger source
```

### Send Arbitrary SCPI Command
```matlab
% Automatically reads response if command contains '?'
response = dmm.sendCommand('VOLT:DC:RANG?');
dmm.sendCommand('DISP:TEXT "Hello"');
```

### Other Utilities

```matlab
dmm.getConfig()       % Query current instrument configuration
dmm.selfTest()        % Run built-in self-test and print result
dmm.reset()           % Send *RST to instrument
dmm.setBeep(true)     % Enable/disable beeper
dmm.setLocal()        % Return front-panel control to user
dmm.approxTime(state) % Benchmark acquisition time for a given state
dmm.deInit()          % Cleanly close and release the VISA connection
```

---

## Properties

| Property | Default | Description |
|---|---|---|
| `visaAddress` | *(auto-detected)* | USB/VISA address of the instrument |
| `state` | `DCV` | Current measurement mode |
| `numSamples` | `512` | Internal sample buffer size |
| `sampleCount` | `10` | Samples per trigger sent to instrument |
| `triggerCount` | `8` | Number of triggers |

---

## Notes

- The constructor **automatically detects** the instrument address using `instrhwinfo('visa','ni')` — no manual address configuration needed.
- The beeper is **silenced on startup** by default.
- `deInit()` should always be called when finished to cleanly release the VISA resource.

---

## License

MIT License — see [LICENSE](LICENSE) for details.
