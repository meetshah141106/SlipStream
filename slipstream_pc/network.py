import socket


class NetworkServer:
    def __init__(self, host, port):
        self.host = host
        self.port = port
        self.server_socket = None
        self.client_socket = None
        self.client_address = None

    def start(self):
        self.server_socket = socket.socket(
            socket.AF_INET,
            socket.SOCK_STREAM
        )

        self.server_socket.setsockopt(
            socket.SOL_SOCKET,
            socket.SO_REUSEADDR,
            1
        )

        self.server_socket.bind(
            (self.host, self.port)
        )

        self.server_socket.listen(1)

        print(f"SlipStream server listening on {self.host}:{self.port}")

    def wait_for_phone(self):
        print("Waiting for phone...")

        self.client_socket, self.client_address = (
            self.server_socket.accept()
        )

        print(f"Phone connected: {self.client_address}")

        return self.client_socket

    def receive(self):
        if self.client_socket is None:
            return None

        try:
            data = self.client_socket.recv(1024)

            if not data:
                return None

            return data.decode("utf-8").strip()

        except ConnectionResetError:
            return None

    def close_client(self):
        if self.client_socket:
            self.client_socket.close()
            self.client_socket = None

    def close(self):
        self.close_client()

        if self.server_socket:
            self.server_socket.close()
            self.server_socket = None