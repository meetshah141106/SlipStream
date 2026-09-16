import vgamepad as vg


class Controller:
    def __init__(self):
        self.gamepad = vg.VX360Gamepad()

        print("Virtual Xbox 360 controller created.")
        print("Waiting for controller input...")

    def process(self, data):
        """
        Process one controller message received from the phone.
        """

        try:
            message_type = data.get("type")

            # -----------------------------------------
            # STEERING
            # -----------------------------------------
            if message_type == "steering":

                value = float(data.get("value", 0.0))

                # Clamp to -1.0 ... +1.0
                value = max(-1.0, min(1.0, value))

                x = int(value * 32767)

                self.gamepad.left_joystick(
                    x_value=x,
                    y_value=0
                )

                self.gamepad.update()

            # -----------------------------------------
            # GAS
            # -----------------------------------------
            elif message_type == "gas":

                value = float(data.get("value", 0.0))

                # Clamp to 0.0 ... 1.0
                value = max(0.0, min(1.0, value))

                trigger = int(value * 255)

                self.gamepad.right_trigger(
                    value=trigger
                )

                self.gamepad.update()

            # -----------------------------------------
            # BRAKE
            # -----------------------------------------
            elif message_type == "brake":

                value = float(data.get("value", 0.0))

                # Clamp to 0.0 ... 1.0
                value = max(0.0, min(1.0, value))

                trigger = int(value * 255)

                self.gamepad.left_trigger(
                    value=trigger
                )

                self.gamepad.update()

            # -----------------------------------------
            # RIGHT STICK
            # -----------------------------------------
            elif message_type == "right_stick":

                x_value = float(data.get("x", 0.0))
                y_value = float(data.get("y", 0.0))

                x_value = max(-1.0, min(1.0, x_value))
                y_value = max(-1.0, min(1.0, y_value))

                x = int(x_value * 32767)
                y = int(y_value * 32767)

                self.gamepad.right_joystick(
                    x_value=x,
                    y_value=y
                )

                self.gamepad.update()

            # -----------------------------------------
            # BUTTONS
            # -----------------------------------------
            elif message_type == "button":

                name = data.get("name")
                pressed = bool(data.get("pressed", False))

                button_map = {
                    "A": vg.XUSB_BUTTON.XUSB_GAMEPAD_A,
                    "B": vg.XUSB_BUTTON.XUSB_GAMEPAD_B,
                    "X": vg.XUSB_BUTTON.XUSB_GAMEPAD_X,
                    "Y": vg.XUSB_BUTTON.XUSB_GAMEPAD_Y,

                    "L1": vg.XUSB_BUTTON.XUSB_GAMEPAD_LEFT_SHOULDER,
                    "R1": vg.XUSB_BUTTON.XUSB_GAMEPAD_RIGHT_SHOULDER,

                    "START": vg.XUSB_BUTTON.XUSB_GAMEPAD_START,
                    "BACK": vg.XUSB_BUTTON.XUSB_GAMEPAD_BACK,
                }

                button = button_map.get(name)

                if button is not None:

                    if pressed:
                        self.gamepad.press_button(
                            button=button
                        )

                    else:
                        self.gamepad.release_button(
                            button=button
                        )

                    self.gamepad.update()

            # -----------------------------------------
            # D-PAD
            # -----------------------------------------
            elif message_type == "dpad":

                direction = data.get("direction")
                pressed = bool(data.get("pressed", False))

                dpad_map = {
                    "UP": vg.XUSB_BUTTON.XUSB_GAMEPAD_DPAD_UP,
                    "DOWN": vg.XUSB_BUTTON.XUSB_GAMEPAD_DPAD_DOWN,
                    "LEFT": vg.XUSB_BUTTON.XUSB_GAMEPAD_DPAD_LEFT,
                    "RIGHT": vg.XUSB_BUTTON.XUSB_GAMEPAD_DPAD_RIGHT,
                }

                button = dpad_map.get(direction)

                if button is not None:

                    if pressed:
                        self.gamepad.press_button(
                            button=button
                        )

                    else:
                        self.gamepad.release_button(
                            button=button
                        )

                    self.gamepad.update()

        except Exception as e:
            print("Controller error:", e)

    def reset(self):
        """
        Return the virtual Xbox controller to a safe neutral state.

        This is called when the phone disappears so that, for example,
        a stuck gas or brake input cannot remain active.
        """

        try:
            # Center left stick.
            self.gamepad.left_joystick(
                x_value=0,
                y_value=0
            )

            # Center right stick.
            self.gamepad.right_joystick(
                x_value=0,
                y_value=0
            )

            # Release triggers.
            self.gamepad.left_trigger(
                value=0
            )

            self.gamepad.right_trigger(
                value=0
            )

            # Release all buttons we use.
            buttons = [
                vg.XUSB_BUTTON.XUSB_GAMEPAD_A,
                vg.XUSB_BUTTON.XUSB_GAMEPAD_B,
                vg.XUSB_BUTTON.XUSB_GAMEPAD_X,
                vg.XUSB_BUTTON.XUSB_GAMEPAD_Y,

                vg.XUSB_BUTTON.XUSB_GAMEPAD_LEFT_SHOULDER,
                vg.XUSB_BUTTON.XUSB_GAMEPAD_RIGHT_SHOULDER,

                vg.XUSB_BUTTON.XUSB_GAMEPAD_START,
                vg.XUSB_BUTTON.XUSB_GAMEPAD_BACK,

                vg.XUSB_BUTTON.XUSB_GAMEPAD_DPAD_UP,
                vg.XUSB_BUTTON.XUSB_GAMEPAD_DPAD_DOWN,
                vg.XUSB_BUTTON.XUSB_GAMEPAD_DPAD_LEFT,
                vg.XUSB_BUTTON.XUSB_GAMEPAD_DPAD_RIGHT,
            ]

            for button in buttons:
                self.gamepad.release_button(
                    button=button
                )

            self.gamepad.update()

        except Exception as e:
            print("Controller reset error:", e)