import json
import socket


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

        # Whether we have received a phone packet
        self.client_connected = False

        # Becomes True only after actual controller JSON
        # has been received.
        self.controller_active = False

    # ============================================================
    # START
    # ============================================================

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

    # ============================================================
    # RECEIVE
    # ============================================================

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

        # --------------------------------------------------------
        # PHONE DETECTED
        # --------------------------------------------------------

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

        # --------------------------------------------------------
        # DECODE UTF-8
        # --------------------------------------------------------

        try:
            text = raw_data.decode("utf-8").strip()

        except UnicodeDecodeError:
            print("Received invalid UTF-8 data.")
            return None

        if not text:
            return None

        # --------------------------------------------------------
        # HANDSHAKE
        # --------------------------------------------------------

        if text == "Hello from SlipStream":
            print("Handshake received.")
            return None

        # --------------------------------------------------------
        # JSON CONTROLLER DATA
        # --------------------------------------------------------

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

        # --------------------------------------------------------
        # CONTROLLER ACTIVE
        # --------------------------------------------------------

        if not self.controller_active:

            self.controller_active = True

            print("-----------------------------------")
            print("CONTROLLER ACTIVE")
            print("-----------------------------------")

        return data

    # ============================================================
    # DISCONNECT
    # ============================================================

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

    # ============================================================
    # CLOSE
    # ============================================================

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