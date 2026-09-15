import asyncio
from bleak import BleakScanner


async def main():
    print("=" * 45)
    print("       SLIPSTREAM BLUETOOTH SCANNER")
    print("=" * 45)
    print()
    print("Scanning for BLE devices for 10 seconds...")
    print()

    devices = await BleakScanner.discover(timeout=10)

    if not devices:
        print("No BLE devices found.")
        return

    print(f"Found {len(devices)} device(s):\n")

    for device in devices:
        print(f"Name:    {device.name}")
        print(f"Address: {device.address}")
        print("-" * 45)


if __name__ == "__main__":
    asyncio.run(main())