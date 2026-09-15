import socket

HOST = "0.0.0.0"
PORT = 5000

server = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
server.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
server.bind((HOST, PORT))
server.listen(1)

print(f"SlipStream server listening on port {PORT}...")
print("Waiting for phone...")

while True:
    conn, address = server.accept()

    print(f"\nPhone connected: {address}")

    try:
        while True:
            data = conn.recv(1024)

            if not data:
                print("Phone disconnected.")
                break

            message = data.decode("utf-8").strip()

            print("Received:", message)

    except ConnectionResetError:
        print("Phone connection lost.")

    finally:
        conn.close()
        print("Waiting for phone...")
