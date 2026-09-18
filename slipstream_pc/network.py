import json
import socket
import time


class NetworkServer:
    def __init__(
        self,
        host,
        port,
        socket_timeout=0.1,
        buffer_size=4096,
    ):
        self.host = host
        self.port = port
        self.socket_timeout = socket_timeout
        self.buffer_size = buffer_size

        self.socket = None

        # Most recent phone address
        self.client_address = None

        # Whether the phone has recently communicated
        self.client_connected = False

        # Becomes True after actual controller JSON
        # has been received.
        self.controller_active = False

        # Time of the most recent packet of ANY kind.
        self.last_packet_time = None

        # Time of the most recent controller packet.
        self.last_controller_packet_time = None

    def start(self):
        """Create and bind the UDP socket."""

        self.socket = socket.socket(
            socket.AF_INET,
            socket.SOCK_DGRAM,
        )

        self.socket.setsockopt(
            socket.SOL_SOCKET,
            socket.SO_REUSEADDR,
            1,
        )

        self.socket.bind(
            (self.host, self.port)
        )

        self.socket.settimeout(
            self.socket_timeout
        )

        print("===================================")
        print("        SLIPSTREAM PC SERVER       ")
        print("===================================")
        print("Protocol : UDP")
        print(f"Address  : {self.host}")
        print(f"Port     : {self.port}")
        print("Status   : WAITING FOR PHONE")
        print("===================================")

    def receive(self):
        """
        Receive one UDP packet.

        Returns:
            dict -> controller JSON message
            None -> handshake, invalid packet, or timeout
        """

        if self.socket is None:
            raise RuntimeError(
                "Network server has not been started."
            )

        try:
            raw_data, address = self.socket.recvfrom(
                self.buffer_size
            )

        except socket.timeout:
            return None

        except OSError as e:
            print("Network error:", e)
            return None

        # ----------------------------------------------------
        # ANY UDP PACKET MEANS THE PHONE IS ALIVE
        # ----------------------------------------------------

        now = time.monotonic()

        self.last_packet_time = now

        # ----------------------------------------------------
        # PHONE CONNECTION
        # ----------------------------------------------------

        if (
            not self.client_connected
            or address != self.client_address
        ):
            self.client_address = address
            self.client_connected = True

            print()
            print("-----------------------------------")
            print("PHONE CONNECTED")
            print(
                f"Address: {address[0]}:{address[1]}"
            )
            print("-----------------------------------")

        # ----------------------------------------------------
        # DECODE
        # ----------------------------------------------------

        try:
            text = raw_data.decode("utf-8").strip()

        except UnicodeDecodeError:
            print("Received invalid UTF-8 data.")
            return None

        if not text:
            return None

        # ----------------------------------------------------
        # HANDSHAKE
        # ----------------------------------------------------

        if text == "Hello from SlipStream":
            print("Handshake received.")
            return None

        # ----------------------------------------------------
        # JSON
        # ----------------------------------------------------

        try:
            data = json.loads(text)

        except json.JSONDecodeError as e:
            print(
                f"Invalid JSON received: {e}"
            )

            print(
                f"Raw packet: {raw_data!r}"
            )

            return None

        # ----------------------------------------------------
        # CONTROLLER ACTIVITY
        # ----------------------------------------------------

        self.last_controller_packet_time = now

        if not self.controller_active:

            self.controller_active = True

            print("-----------------------------------")
            print("CONTROLLER ACTIVE")
            print("-----------------------------------")

        return data

    def mark_disconnected(self):
        """Mark the phone as disconnected."""

        if self.client_connected:

            print()
            print("-----------------------------------")
            print("PHONE DISCONNECTED")
            print("Controller reset")
            print("Status: WAITING FOR PHONE")
            print("-----------------------------------")

        self.client_connected = False
        self.controller_active = False

        self.client_address = None

        self.last_packet_time = None
        self.last_controller_packet_time = None

    def mark_controller_inactive(self):
        """Mark controller input as inactive without disconnecting phone."""

        if self.controller_active:

            print("-----------------------------------")
            print("CONTROLLER INACTIVE")
            print("-----------------------------------")

        self.controller_active = False

        self.last_controller_packet_time = None

    def close(self):
        """Close the UDP socket."""

        if self.socket is not None:

            try:
                self.socket.close()

            except OSError:
                pass

            self.socket = None

        self.client_connected = False
        self.controller_active = False
        self.client_address = None

        self.last_packet_time = None
        self.last_controller_packet_time = None