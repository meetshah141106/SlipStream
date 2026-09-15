import asyncio
from bleak import BleakScanner, BleakClient

SLIPSTREAM_SERVICE_UUID = "7f5c0001-8b8a-4c2e-9d1a-123456789abc"


async def main():
    print("=" * 55)
    print("             SLIPSTREAM RECEIVER")
    print("=" * 55)
    print()
    print("Searching for SlipStream...")
    print()

    devices = await BleakScanner.discover(
        timeout=10,
        return_adv=True
    )

    slipstream = None

    for device, advertisement in devices.values():

        print(
            f"Found: {device.name} | "
            f"{device.address}"
        )

        service_uuids = advertisement.service_uuids or []

        if any(
            uuid.lower() == SLIPSTREAM_SERVICE_UUID.lower()
            for uuid in service_uuids
        ):
            slipstream = device

    if slipstream is None:
        print()
        print("SlipStream was not found.")
        print("Make sure the phone is advertising.")
        return

    print()
    print("SlipStream found!")
    print(f"Address: {slipstream.address}")
    print()
    print("Connecting...")

    async with BleakClient(slipstream) as client:

        if not client.is_connected:
            print("Connection failed.")
            return

        print("CONNECTED!")
        print()

        print("Discovering services...")
        print("-" * 55)

        for service in client.services:

            print(f"SERVICE: {service.uuid}")

            for characteristic in service.characteristics:

                print(
                    f"  CHARACTERISTIC: "
                    f"{characteristic.uuid}"
                )

                print(
                    f"    Properties: "
                    f"{characteristic.properties}"
                )

        print("-" * 55)
        print()
        print("Waiting for data...")
        print("Press CTRL+C to stop.")
        print()

        while True: 
            await asyncio.sleep(1)


if __name__ == "__main__":

    try:
        asyncio.run(main())

    except KeyboardInterrupt:
        print()
        print("Receiver stopped.")