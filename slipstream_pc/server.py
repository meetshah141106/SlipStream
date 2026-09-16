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


def main():

    network = NetworkServer(
        host=HOST,
        port=PORT,
        socket_timeout=SOCKET_TIMEOUT,
        buffer_size=BUFFER_SIZE,
    )

    controller = Controller()

    network.start()

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

                controller.process(data)

            # ====================================================
            # NO CONTROLLER DATA
            # ====================================================

            else:

                # Only apply the timeout after actual controller
                # data has been received.
                #
                # "Hello from SlipStream" does NOT activate this.

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

    except KeyboardInterrupt:

        print()
        print("Shutting down SlipStream...")

        controller.reset()
        network.close()

        print("Server stopped.")


if __name__ == "__main__":
    main()