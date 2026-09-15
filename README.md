# SlipStream

SlipStream is a controller platform that turns your phone into a gaming controller for Windows.

The primary goal is to provide a realistic driving-controller experience using your phone as a steering wheel, with throttle, brake, gears, and other controls. The Windows application acts as the interface and receives the controls from the phone in real time.

## Features

### Driving Controller

* Steering wheel using the phone
* Accelerator and brake
* Gear controls
* Handbrake
* Horn, indicators, lights, and other configurable controls
* Motion-based steering support
* Real-time communication with Windows

### Gamepad Controller

SlipStream is designed to support more than just driving games.

A future controller mode can provide:

* Xbox-style buttons
* Analog controls
* D-pad
* Triggers
* Joysticks
* Custom button mapping

This allows the same phone application to work as either a driving controller or a traditional game controller.

## Architecture

```text
                 ┌─────────────────────┐
                 │     SlipStream      │
                 │     Phone App       │
                 │                     │
                 │  Steering / Buttons │
                 │  Throttle / Brake   │
                 └──────────┬──────────┘
                            │
                       Wi-Fi / Network
                            │
                            ▼
                 ┌─────────────────────┐
                 │     SlipStream      │
                 │    Windows App      │
                 │                     │
                 │  Input Receiver     │
                 │  Controller Mapper  │
                 └──────────┬──────────┘
                            │
                            ▼
                 ┌─────────────────────┐
                 │     Game / Sim      │
                 └─────────────────────┘
```

## Project Structure

The project consists of two main applications:

```text
SlipStream/
├── mobile/
│   └── Phone controller application
│
├── windows/
│   └── Windows controller/interface application
│
└── README.md
```

## Development

SlipStream is currently under development.

The initial version focuses on establishing reliable communication between the phone and Windows application and transmitting controller inputs with low latency.

Development will progress toward:

1. Phone-to-PC communication
2. Steering input
3. Throttle and brake
4. Additional driving controls
5. Xbox-style controller mapping
6. Game compatibility
7. Controller customization
8. Improved latency and reliability

## Developers

SlipStream is developed by:

* Maharshi
* Meet

## Status

🚧 **In Development**

The project is currently being built and tested. Features and architecture may change as development progresses.

## License

License information will be added when the project is ready for release.
