import time

from config import (
    HOST,
    PORT,
    CONTROLLER_TIMEOUT,
    SOCKET_TIMEOUT,
    BUFFER_SIZE,
)

from network import NetworkServer
from controller import Controller

from status import (
    write_status,
    clear_status,
)


def main():

    network = NetworkServer(
        host=HOST,
        port=PORT,
        socket_timeout=SOCKET_TIMEOUT,
        buffer_size=BUFFER_SIZE,
    )

    controller = Controller()

    network.start()

    # ========================================================
    # LIVE INPUT STATE
    # ========================================================

    steering = 0.0
    gas = 0.0
    brake = 0.0

    right_stick_x = 0.0
    right_stick_y = 0.0

    last_button = "None"

    # ========================================================
    # INITIAL STATUS
    # ========================================================

    write_status(
        server_running=True,
        phone_connected=False,
        phone_ip=None,
        phone_port=None,
        controller_active=False,
        steering=steering,
        gas=gas,
        brake=brake,
        right_stick_x=right_stick_x,
        right_stick_y=right_stick_y,
        last_button=last_button,
    )

    # Time of the last actual controller packet.
    last_packet_time = None

    try:

        while True:

            data = network.receive()

            # ====================================================
            # CONTROLLER DATA RECEIVED
            # ====================================================

            if data is not None:

                last_packet_time = time.monotonic()

                # ------------------------------------------------
                # PROCESS CONTROLLER
                # ------------------------------------------------

                controller.process(data)

                # ------------------------------------------------
                # READ PACKET TYPE
                # ------------------------------------------------

                message_type = data.get("type")

                # =================================================
                # STEERING
                # =================================================

                if message_type == "steering":

                    try:
                        steering = float(
                            data.get(
                                "value",
                                0.0,
                            )
                        )

                    except (
                        TypeError,
                        ValueError,
                    ):
                        steering = 0.0

                    steering = max(
                        -1.0,
                        min(
                            1.0,
                            steering,
                        ),
                    )

                # =================================================
                # GAS
                # =================================================

                elif message_type == "gas":

                    try:
                        gas = float(
                            data.get(
                                "value",
                                0.0,
                            )
                        )

                    except (
                        TypeError,
                        ValueError,
                    ):
                        gas = 0.0

                    gas = max(
                        0.0,
                        min(
                            1.0,
                            gas,
                        ),
                    )

                # =================================================
                # BRAKE
                # =================================================

                elif message_type == "brake":

                    try:
                        brake = float(
                            data.get(
                                "value",
                                0.0,
                            )
                        )

                    except (
                        TypeError,
                        ValueError,
                    ):
                        brake = 0.0

                    brake = max(
                        0.0,
                        min(
                            1.0,
                            brake,
                        ),
                    )

                # =================================================
                # RIGHT STICK
                # =================================================

                elif message_type == "right_stick":

                    try:
                        right_stick_x = float(
                            data.get(
                                "x",
                                0.0,
                            )
                        )

                    except (
                        TypeError,
                        ValueError,
                    ):
                        right_stick_x = 0.0

                    try:
                        right_stick_y = float(
                            data.get(
                                "y",
                                0.0,
                            )
                        )

                    except (
                        TypeError,
                        ValueError,
                    ):
                        right_stick_y = 0.0

                    right_stick_x = max(
                        -1.0,
                        min(
                            1.0,
                            right_stick_x,
                        ),
                    )

                    right_stick_y = max(
                        -1.0,
                        min(
                            1.0,
                            right_stick_y,
                        ),
                    )

                # =================================================
                # BUTTON
                # =================================================

                elif message_type == "button":

                    name = data.get(
                        "name",
                        "Unknown",
                    )

                    pressed = bool(
                        data.get(
                            "pressed",
                            False,
                        )
                    )

                    if pressed:

                        last_button = (
                            f"{name} • PRESSED"
                        )

                    else:

                        last_button = (
                            f"{name} • RELEASED"
                        )

                # =================================================
                # DPAD
                # =================================================

                elif message_type == "dpad":

                    direction = data.get(
                        "direction",
                        "Unknown",
                    )

                    pressed = bool(
                        data.get(
                            "pressed",
                            False,
                        )
                    )

                    if pressed:

                        last_button = (
                            f"D-Pad {direction} • PRESSED"
                        )

                    else:

                        last_button = (
                            f"D-Pad {direction} • RELEASED"
                        )

                # =================================================
                # PHONE INFORMATION
                # =================================================

                phone_ip = None
                phone_port = None

                if network.client_address is not None:

                    phone_ip = (
                        network.client_address[0]
                    )

                    phone_port = (
                        network.client_address[1]
                    )

                # =================================================
                # WRITE STATUS
                # =================================================

                write_status(
                    server_running=True,
                    phone_connected=network.client_connected,
                    phone_ip=phone_ip,
                    phone_port=phone_port,
                    controller_active=network.controller_active,
                    steering=steering,
                    gas=gas,
                    brake=brake,
                    right_stick_x=right_stick_x,
                    right_stick_y=right_stick_y,
                    last_button=last_button,
                )

            # ====================================================
            # NO CONTROLLER DATA
            # ====================================================

            else:

                # Only apply the timeout after actual controller
                # data has been received.

                if (
                    network.controller_active
                    and last_packet_time is not None
                ):

                    elapsed = (
                        time.monotonic()
                        - last_packet_time
                    )

                    if elapsed >= CONTROLLER_TIMEOUT:

                        controller.reset()

                        network.mark_disconnected()

                        last_packet_time = None

                        # Reset displayed inputs
                        steering = 0.0
                        gas = 0.0
                        brake = 0.0
                        right_stick_x = 0.0
                        right_stick_y = 0.0
                        last_button = "None"

                        write_status(
                            server_running=True,
                            phone_connected=False,
                            phone_ip=None,
                            phone_port=None,
                            controller_active=False,
                            steering=steering,
                            gas=gas,
                            brake=brake,
                            right_stick_x=right_stick_x,
                            right_stick_y=right_stick_y,
                            last_button=last_button,
                        )

    except KeyboardInterrupt:

        print()
        print("Shutting down SlipStream...")

        controller.reset()

        network.close()

        clear_status()

        print("Server stopped.")


if __name__ == "__main__":
    main()