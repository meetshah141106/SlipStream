import json
import os


STATUS_FILE = os.path.join(
    os.path.dirname(os.path.abspath(__file__)),
    "status.json",
)


def write_status(
    server_running=False,
    phone_connected=False,
    phone_ip=None,
    phone_port=None,
    controller_active=False,
    steering=0.0,
    gas=0.0,
    brake=0.0,
    right_stick_x=0.0,
    right_stick_y=0.0,
    last_button="None",
):
    status = {
        "server_running": server_running,
        "phone_connected": phone_connected,
        "phone_ip": phone_ip,
        "phone_port": phone_port,
        "controller_active": controller_active,

        "inputs": {
            "steering": steering,
            "gas": gas,
            "brake": brake,
            "right_stick_x": right_stick_x,
            "right_stick_y": right_stick_y,
            "last_button": last_button,
        },
    }

    try:

        temp_file = STATUS_FILE + ".tmp"

        with open(
            temp_file,
            "w",
            encoding="utf-8",
        ) as file:

            json.dump(
                status,
                file,
                indent=2,
            )

        os.replace(
            temp_file,
            STATUS_FILE,
        )

    except OSError:
        pass


def clear_status():

    write_status(
        server_running=False,
        phone_connected=False,
        phone_ip=None,
        phone_port=None,
        controller_active=False,
        steering=0.0,
        gas=0.0,
        brake=0.0,
        right_stick_x=0.0,
        right_stick_y=0.0,
        last_button="None",
    )