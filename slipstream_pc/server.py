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


# ============================================================
# PHONE CONNECTION TIMEOUT
#
# This is intentionally longer than controller timeout.
#
# The phone must stop sending ALL communication for this long
# before we consider the phone disconnected.
# ============================================================

PHONE_TIMEOUT = 5.0


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

    try:

        while True:

            data = network.receive()

            # =================================================
            # CONTROLLER DATA RECEIVED
            # =================================================

            if data is not None:

                controller.process(data)

                message_type = data.get("type")

                # ---------------------------------------------
                # STEERING
                # ---------------------------------------------

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

                # ---------------------------------------------
                # GAS
                # ---------------------------------------------

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

                # ---------------------------------------------
                # BRAKE
                # ---------------------------------------------

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
                        )
                    )

                # ---------------------------------------------
                # RIGHT STICK
                # ---------------------------------------------

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

                # ---------------------------------------------
                # BUTTON
                # ---------------------------------------------

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

                # ---------------------------------------------
                # D-PAD
                # ---------------------------------------------

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

                # ---------------------------------------------
                # PHONE INFORMATION
                # ---------------------------------------------

                phone_ip = None
                phone_port = None

                if network.client_address is not None:

                    phone_ip = (
                        network.client_address[0]
                    )

                    phone_port = (
                        network.client_address[1]
                    )

                # ---------------------------------------------
                # WRITE LIVE STATUS
                # ---------------------------------------------

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

            # =================================================
            # NO CONTROLLER DATA
            # =================================================

            else:

                # ---------------------------------------------
                # CONTROLLER TIMEOUT
                #
                # IMPORTANT:
                # This does NOT disconnect the phone.
                # ---------------------------------------------

                if (
                    network.controller_active
                    and network.last_controller_packet_time
                    is not None
                ):

                    controller_elapsed = (
                        time.monotonic()
                        - network.last_controller_packet_time
                    )

                    if (
                        controller_elapsed
                        >= CONTROLLER_TIMEOUT
                    ):

                        controller.reset()

                        network.mark_controller_inactive()

                        steering = 0.0
                        gas = 0.0
                        brake = 0.0
                        right_stick_x = 0.0
                        right_stick_y = 0.0
                        last_button = "None"

                        phone_ip = None
                        phone_port = None

                        if network.client_address is not None:

                            phone_ip = (
                                network.client_address[0]
                            )

                            phone_port = (
                                network.client_address[1]
                            )

                        write_status(
                            server_running=True,
                            phone_connected=network.client_connected,
                            phone_ip=phone_ip,
                            phone_port=phone_port,
                            controller_active=False,
                            steering=steering,
                            gas=gas,
                            brake=brake,
                            right_stick_x=right_stick_x,
                            right_stick_y=right_stick_y,
                            last_button=last_button,
                        )

                # ---------------------------------------------
                # PHONE TIMEOUT
                #
                # Only disconnect when absolutely no UDP
                # communication has been received.
                # ---------------------------------------------

                if (
                    network.client_connected
                    and network.last_packet_time
                    is not None
                ):

                    phone_elapsed = (
                        time.monotonic()
                        - network.last_packet_time
                    )

                    if phone_elapsed >= PHONE_TIMEOUT:

                        controller.reset()

                        network.mark_disconnected()

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