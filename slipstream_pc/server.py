from config import HOST, PORT
from network import NetworkServer
from controller import Controller


def main():
    network = NetworkServer(HOST, PORT)
    controller = Controller()

    network.start()

    while True:
        network.wait_for_phone()

        while True:
            data = network.receive()

            if data is None:
                print("Phone disconnected.")
                network.close_client()
                break

            controller.process(data)


if __name__ == "__main__":
    main()