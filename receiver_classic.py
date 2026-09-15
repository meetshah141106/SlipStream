import bluetooth


def main():
    print("=" * 55)
    print("          SLIPSTREAM CLASSIC BLUETOOTH")
    print("              RFCOMM RECEIVER")
    print("=" * 55)
    print()

    server_socket = bluetooth.BluetoothSocket(
        bluetooth.RFCOMM
    )

    server_socket.bind(("", bluetooth.PORT_ANY))
    server_socket.listen(1)

    port = server_socket.getsockname()[1]

    print(f"RFCOMM server started on channel {port}")
    print()
    print("Waiting for SlipStream phone...")
    print("")

    client_socket, client_info = server_socket.accept()

    print("CONNECTED!")
    print(f"Phone: {client_info}")
    print()
    print("Waiting for controller data...")
    print("Press CTRL+C to stop.")
    print()

    try:
        while True:

            data = client_socket.recv(1024)

            if not data:
                print("Phone disconnected.")
                break

            print("RAW DATA:", data)

    except KeyboardInterrupt:
        print()
        print("Receiver stopped.")

    except OSError as error:
        print("Connection error:", error)

    finally:
        client_socket.close()
        server_socket.close()

        print("Bluetooth connection closed.")


if __name__ == "__main__":
    main()