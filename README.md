# SlipStream

SlipStream is a phone-to-PC controller platform that turns a smartphone into a gaming controller for Windows.

The primary goal is to provide a driving controller using the phone as a steering wheel, with accelerator, brake, gears, and additional controls. The Windows application receives these inputs and exposes them to games and simulators.

## Current Status

🚧 **Early Development**

At the moment, SlipStream is **not yet a functional controller**.

The project is currently in the **planning and initial development stage**. The phone-to-Windows Bluetooth communication, controller input system, and Windows virtual-controller integration are still being developed.

### Currently Planned

* Phone application
* Windows application
* Bluetooth communication
* Steering input
* Accelerator and brake
* Gear controls
* Xbox-style controls
* Virtual controller output

### Not Implemented Yet

* Working phone controller
* Phone ↔ Windows Bluetooth communication
* Virtual Xbox controller
* Game/simulator integration
* Gamepad mode
* Custom controller layouts
* Wi-Fi / USB connectivity

## Core Concept

```text
Phone
  │
  │ Bluetooth
  ▼
SlipStream Windows
  │
  ▼
Virtual Controller
  │
  ▼
Game / Simulator
```

The phone will handle the controls and sensors, while the Windows application will act as the bridge between the phone and the game.

## Primary Controller — Driving

The first controller mode will focus on driving games.

The phone is intended to provide:

* Steering wheel
* Accelerator
* Brake
* Gear controls
* Handbrake
* Horn
* Indicators
* Headlights
* Other configurable controls

Steering may use the phone's motion sensors, touchscreen, or both.

## Future Controller Modes

SlipStream is designed to eventually support multiple controller types.

### Driving Controller

A steering-wheel style controller for racing and driving games.

### Gamepad

An Xbox-style controller with:

* Analog sticks
* D-pad
* A / B / X / Y
* Triggers
* Bumpers
* Start / Select

### Custom Controller

Users may eventually be able to create their own layouts and button mappings.

## Connectivity

Bluetooth is the planned primary connection method.

This means SlipStream is intended to work without:

* Internet
* Wi-Fi
* Router
* Mobile data

The phone and Windows PC will communicate directly over Bluetooth.

Future versions may also support:

* Wi-Fi
* USB

## Architecture

```text
                 ┌─────────────────────┐
                 │     SlipStream      │
                 │     Phone App       │
                 │                     │
                 │  Steering           │
                 │  Throttle / Brake   │
                 │  Buttons / Sensors  │
                 └──────────┬──────────┘
                            │
                       Bluetooth
                            │
                            ▼
                 ┌─────────────────────┐
                 │     SlipStream      │
                 │    Windows App      │
                 │                     │
                 │  Connection Layer   │
                 │  Input Processor    │
                 │  Controller Mapper  │
                 └──────────┬──────────┘
                            │
                            ▼
                 ┌─────────────────────┐
                 │  Virtual Controller │
                 └──────────┬──────────┘
                            │
                            ▼
                 ┌─────────────────────┐
                 │   Game / Simulator  │
                 └─────────────────────┘
```

## Input Protocol

The phone and Windows application are planned to communicate using a common input format.

Example:

```json
{
  "steering": -0.42,
  "throttle": 0.85,
  "brake": 0.0,
  "handbrake": false,
  "gear": 3,
  "buttons": {
    "A": true,
    "B": false,
    "X": false,
    "Y": false
  }
}
```

The connection layer will transport the input data, while the Windows application will convert it into controller inputs.

## Development Roadmap

### Phase 1 — Bluetooth Connection

* Bluetooth pairing
* Phone ↔ Windows communication
* Connection status
* Reconnection handling

### Phase 2 — Driving Controller

* Steering
* Accelerator
* Brake
* Gear controls
* Handbrake
* Additional buttons

### Phase 3 — Virtual Controller

* Windows virtual controller
* Game compatibility
* Calibration
* Dead zones
* Sensitivity

### Phase 4 — Gamepad Mode

* Xbox-style layout
* Analog sticks
* Triggers
* D-pad
* Button mapping

### Phase 5 — Customization

* Custom layouts
* Custom mappings
* Controller profiles
* Per-game configurations

### Phase 6 — Additional Connectivity

* Wi-Fi
* USB
* Automatic connection selection

## Project Structure

```text
SlipStream/
├── mobile/
│   └── Phone controller application
│
├── windows/
│   └── Windows controller application
│
├── protocol/
│   └── Shared input protocol
│
└── README.md
```

## Developers

SlipStream is developed by:

* Maharshi
* Meet

## License

License information will be added when the project is ready for release.
