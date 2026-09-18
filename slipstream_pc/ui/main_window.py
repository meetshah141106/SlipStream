import json
import os
import subprocess

from PySide6.QtCore import Qt, QTimer
from PySide6.QtWidgets import (
    QMainWindow,
    QWidget,
    QHBoxLayout,
    QVBoxLayout,
    QGridLayout,
    QLabel,
    QFrame,
)

from .widgets.sidebar import Sidebar
from .widgets.status_card import StatusCard


# ============================================================
# STATUS FILE
# ============================================================

STATUS_FILE = os.path.join(
    os.path.dirname(
        os.path.dirname(
            os.path.abspath(__file__)
        )
    ),
    "status.json",
)


class MainWindow(QMainWindow):

    def __init__(self):
        super().__init__()

        self.setWindowTitle("SlipStream")

        self.setMinimumSize(1100, 700)
        self.resize(1200, 760)

        self.setup_ui()

    # ========================================================
    # SETUP UI
    # ========================================================

    def setup_ui(self):

        central = QWidget()
        self.setCentralWidget(central)

        main_layout = QHBoxLayout(central)

        main_layout.setContentsMargins(
            0,
            0,
            0,
            0,
        )

        main_layout.setSpacing(0)

        # ====================================================
        # SIDEBAR
        # ====================================================

        self.sidebar = Sidebar()

        main_layout.addWidget(
            self.sidebar
        )

        # ====================================================
        # MAIN CONTENT
        # ====================================================

        self.content = QWidget()

        content_layout = QVBoxLayout(
            self.content
        )

        content_layout.setContentsMargins(
            34,
            28,
            34,
            28,
        )

        content_layout.setSpacing(22)

        main_layout.addWidget(
            self.content
        )

        # ====================================================
        # HEADER
        # ====================================================

        header_layout = QHBoxLayout()

        title_container = QVBoxLayout()

        title_container.setSpacing(4)

        title = QLabel(
            "Welcome to SlipStream"
        )

        title.setObjectName(
            "pageTitle"
        )

        subtitle = QLabel(
            "Your phone controller is ready to connect."
        )

        subtitle.setObjectName(
            "pageSubtitle"
        )

        title_container.addWidget(
            title
        )

        title_container.addWidget(
            subtitle
        )

        header_layout.addLayout(
            title_container
        )

        header_layout.addStretch()

        # ====================================================
        # SERVER STATUS PILL
        # ====================================================

        self.server_status = QLabel()

        self.server_status.setObjectName(
            "statusPill"
        )

        header_layout.addWidget(
            self.server_status,
            alignment=Qt.AlignmentFlag.AlignTop,
        )

        content_layout.addLayout(
            header_layout
        )

        # ====================================================
        # STATUS CARDS
        # ====================================================

        cards = QGridLayout()

        cards.setSpacing(16)

        # ----------------------------------------------------
        # PHONE CARD
        # ----------------------------------------------------

        self.phone_card = StatusCard(
            "PHONE",
            "DISCONNECTED",
            "Waiting for phone",
        )

        # ----------------------------------------------------
        # VIRTUAL CONTROLLER CARD
        # ----------------------------------------------------

        self.controller_card = StatusCard(
            "VIRTUAL CONTROLLER",
            "INACTIVE",
            "Xbox 360 Controller  •  Waiting for input",
        )

        # ----------------------------------------------------
        # SERVER CARD
        # ----------------------------------------------------

        self.server_card = StatusCard(
            "SERVER",
            "CHECKING...",
            "UDP : 5000",
        )

        cards.addWidget(
            self.phone_card,
            0,
            0,
        )

        cards.addWidget(
            self.controller_card,
            0,
            1,
        )

        cards.addWidget(
            self.server_card,
            0,
            2,
        )

        cards.setColumnStretch(
            0,
            1,
        )

        cards.setColumnStretch(
            1,
            1,
        )

        cards.setColumnStretch(
            2,
            1,
        )

        content_layout.addLayout(
            cards
        )

        # ====================================================
        # LIVE INPUT CARD
        # ====================================================

        input_card = QFrame()

        input_card.setObjectName(
            "contentCard"
        )

        input_layout = QVBoxLayout(
            input_card
        )

        input_layout.setContentsMargins(
            22,
            20,
            22,
            22,
        )

        input_layout.setSpacing(8)

        section_title = QLabel(
            "Live Input"
        )

        section_title.setObjectName(
            "sectionTitle"
        )

        section_subtitle = QLabel(
            "Controller input received from the phone"
        )

        section_subtitle.setObjectName(
            "sectionSubtitle"
        )

        input_layout.addWidget(
            section_title
        )

        input_layout.addWidget(
            section_subtitle
        )

        input_layout.addSpacing(
            20
        )

        # ----------------------------------------------------
        # INPUT GRID
        # ----------------------------------------------------

        input_grid = QGridLayout()

        input_grid.setSpacing(12)

        self.steering_value = self.add_input(
            input_grid,
            0,
            0,
            "Steering",
            "0.00000",
        )

        self.gas_value = self.add_input(
            input_grid,
            0,
            1,
            "Gas",
            "0.00000",
        )

        self.brake_value = self.add_input(
            input_grid,
            0,
            2,
            "Brake",
            "0.00000",
        )

        self.right_stick_x_value = self.add_input(
            input_grid,
            1,
            0,
            "Right Stick X",
            "0.00000",
        )

        self.right_stick_y_value = self.add_input(
            input_grid,
            1,
            1,
            "Right Stick Y",
            "0.00000",
        )

        self.last_button_value = self.add_input(
            input_grid,
            1,
            2,
            "Last Button",
            "None",
        )

        input_layout.addLayout(
            input_grid
        )

        content_layout.addWidget(
            input_card
        )

        # ====================================================
        # CONNECTION CARD
        # ====================================================

        connection_card = QFrame()

        connection_card.setObjectName(
            "contentCard"
        )

        connection_layout = QVBoxLayout(
            connection_card
        )

        connection_layout.setContentsMargins(
            22,
            20,
            22,
            20,
        )

        connection_layout.setSpacing(8)

        connection_title = QLabel(
            "Connection"
        )

        connection_title.setObjectName(
            "sectionTitle"
        )

        connection_subtitle = QLabel(
            "SlipStream communication status"
        )

        connection_subtitle.setObjectName(
            "sectionSubtitle"
        )

        connection_layout.addWidget(
            connection_title
        )

        connection_layout.addWidget(
            connection_subtitle
        )

        connection_layout.addSpacing(
            14
        )

        info_layout = QHBoxLayout()

        self.protocol_value = (
            self.add_connection_info(
                info_layout,
                "Protocol",
                "UDP",
            )
        )

        self.port_value = (
            self.add_connection_info(
                info_layout,
                "Port",
                "5000",
            )
        )

        self.connection_value = (
            self.add_connection_info(
                info_layout,
                "Status",
                "Waiting for phone",
            )
        )

        connection_layout.addLayout(
            info_layout
        )

        content_layout.addWidget(
            connection_card
        )

        content_layout.addStretch()

        # ====================================================
        # SIDEBAR EVENTS
        # ====================================================

        self.sidebar.page_changed.connect(
            self.change_page
        )

        # ====================================================
        # SERVER STATUS TIMER
        # ====================================================

        self.server_timer = QTimer(
            self
        )

        self.server_timer.timeout.connect(
            self.check_server_status
        )

        self.server_timer.start(
            1000
        )

        self.check_server_status()

        # ====================================================
        # PHONE / CONTROLLER / INPUT TIMER
        # ====================================================

        self.status_timer = QTimer(
            self
        )

        self.status_timer.timeout.connect(
            self.update_status
        )

        self.status_timer.start(
            100
        )

        self.update_status()

    # ========================================================
    # INPUT CARD
    # ========================================================

    def add_input(
        self,
        layout,
        row,
        column,
        name,
        value,
    ):

        box = QFrame()

        box.setObjectName(
            "contentCard"
        )

        box_layout = QVBoxLayout(
            box
        )

        box_layout.setContentsMargins(
            14,
            12,
            14,
            12,
        )

        box_layout.setSpacing(
            4
        )

        name_label = QLabel(
            name
        )

        name_label.setObjectName(
            "cardTitle"
        )

        value_label = QLabel(
            value
        )

        value_label.setObjectName(
            "cardValue"
        )

        box_layout.addWidget(
            name_label
        )

        box_layout.addWidget(
            value_label
        )

        layout.addWidget(
            box,
            row,
            column,
        )

        return value_label

    # ========================================================
    # CONNECTION INFORMATION
    # ========================================================

    def add_connection_info(
        self,
        layout,
        name,
        value,
    ):

        container = QVBoxLayout()

        container.setSpacing(
            3
        )

        name_label = QLabel(
            name
        )

        name_label.setObjectName(
            "cardTitle"
        )

        value_label = QLabel(
            value
        )

        value_label.setObjectName(
            "cardValue"
        )

        container.addWidget(
            name_label
        )

        container.addWidget(
            value_label
        )

        layout.addLayout(
            container
        )

        return value_label

    # ========================================================
    # SERVER STATUS
    # ========================================================

    def check_server_status(self):
        """
        Check whether UDP port 5000 is currently being
        used on Windows.

        This does NOT:
        - bind to port 5000
        - connect to the server
        - send UDP packets
        - modify the existing networking code
        """

        running = False

        try:

            result = subprocess.run(
                [
                    "netstat",
                    "-ano",
                    "-p",
                    "udp",
                ],
                capture_output=True,
                text=True,
                creationflags=subprocess.CREATE_NO_WINDOW,
            )

            output = result.stdout

            for line in output.splitlines():

                line = line.strip()

                if not line:
                    continue

                parts = line.split()

                if len(parts) < 2:
                    continue

                local_address = parts[1]

                if (
                    local_address.endswith(
                        ":5000"
                    )
                    or local_address.endswith(
                        ".5000"
                    )
                ):

                    running = True
                    break

        except Exception:

            running = False

        # ====================================================
        # RUNNING
        # ====================================================

        if running:

            self.server_status.setText(
                "●  Server Running  UDP : 5000"
            )

            self.server_card.set_value(
                "RUNNING"
            )

            self.server_card.set_description(
                "UDP : 5000  •  Listening"
            )

        # ====================================================
        # OFFLINE
        # ====================================================

        else:

            self.server_status.setText(
                "●  Server Offline  UDP : 5000"
            )

            self.server_card.set_value(
                "OFFLINE"
            )

            self.server_card.set_description(
                "UDP : 5000  •  Not listening"
            )

    # ========================================================
    # READ STATUS FILE
    # ========================================================

    def update_status(self):
        """
        Read status information produced by server.py.

        The UI does not communicate with the phone.
        """

        if not os.path.exists(
            STATUS_FILE
        ):

            self.reset_ui_status()

            return

        try:

            with open(
                STATUS_FILE,
                "r",
                encoding="utf-8",
            ) as file:

                status = json.load(
                    file
                )

        except (
            OSError,
            json.JSONDecodeError,
        ):

            return

        # ====================================================
        # PHONE STATUS
        # ====================================================

        phone_connected = status.get(
            "phone_connected",
            False,
        )

        phone_ip = status.get(
            "phone_ip"
        )

        phone_port = status.get(
            "phone_port"
        )

        # ====================================================
        # CONTROLLER STATUS
        # ====================================================

        controller_active = status.get(
            "controller_active",
            False,
        )

        # ====================================================
        # PHONE CARD
        # ====================================================

        if phone_connected:

            self.phone_card.set_value(
                "CONNECTED"
            )

            if (
                phone_ip
                and phone_port
            ):

                self.phone_card.set_description(
                    f"{phone_ip}:{phone_port}  •  UDP device"
                )

            elif phone_ip:

                self.phone_card.set_description(
                    f"{phone_ip}  •  UDP device"
                )

            else:

                self.phone_card.set_description(
                    "UDP device"
                )

            self.connection_value.setText(
                "Connected"
            )

        else:

            self.phone_card.set_value(
                "DISCONNECTED"
            )

            self.phone_card.set_description(
                "Waiting for phone"
            )

            self.connection_value.setText(
                "Waiting for phone"
            )

        # ====================================================
        # CONTROLLER CARD
        # ====================================================

        if controller_active:

            self.controller_card.set_value(
                "ACTIVE"
            )

            self.controller_card.set_description(
                "Xbox 360 Controller  •  ViGEm"
            )

        else:

            self.controller_card.set_value(
                "INACTIVE"
            )

            self.controller_card.set_description(
                "Xbox 360 Controller  •  Waiting for input"
            )

        # ====================================================
        # LIVE INPUT
        # ====================================================

        inputs = status.get(
            "inputs",
            {},
        )

        steering = inputs.get(
            "steering",
            0.0,
        )

        gas = inputs.get(
            "gas",
            0.0,
        )

        brake = inputs.get(
            "brake",
            0.0,
        )

        right_stick_x = inputs.get(
            "right_stick_x",
            0.0,
        )

        right_stick_y = inputs.get(
            "right_stick_y",
            0.0,
        )

        last_button = inputs.get(
            "last_button",
            "None",
        )

        # ====================================================
        # UPDATE INPUT VALUES
        # ====================================================

        self.steering_value.setText(
            f"{float(steering):.5f}"
        )

        self.gas_value.setText(
            f"{float(gas):.5f}"
        )

        self.brake_value.setText(
            f"{float(brake):.5f}"
        )

        self.right_stick_x_value.setText(
            f"{float(right_stick_x):.5f}"
        )

        self.right_stick_y_value.setText(
            f"{float(right_stick_y):.5f}"
        )

        self.last_button_value.setText(
            str(last_button)
        )

    # ========================================================
    # RESET UI
    # ========================================================

    def reset_ui_status(self):

        self.phone_card.set_value(
            "DISCONNECTED"
        )

        self.phone_card.set_description(
            "Waiting for phone"
        )

        self.controller_card.set_value(
            "INACTIVE"
        )

        self.controller_card.set_description(
            "Xbox 360 Controller  •  Waiting for input"
        )

        self.connection_value.setText(
            "Waiting for phone"
        )

        self.steering_value.setText(
            "0.00000"
        )

        self.gas_value.setText(
            "0.00000"
        )

        self.brake_value.setText(
            "0.00000"
        )

        self.right_stick_x_value.setText(
            "0.00000"
        )

        self.right_stick_y_value.setText(
            "0.00000"
        )

        self.last_button_value.setText(
            "None"
        )

    # ========================================================
    # SIDEBAR PAGE CHANGES
    # ========================================================

    def change_page(
        self,
        page,
    ):

        if page == "dashboard":

            self.setWindowTitle(
                "SlipStream — Dashboard"
            )

        elif page == "controller":

            self.setWindowTitle(
                "SlipStream — Controller"
            )

        elif page == "devices":

            self.setWindowTitle(
                "SlipStream — Devices"
            )

        elif page == "settings":

            self.setWindowTitle(
                "SlipStream — Settings"
            )

        elif page == "about":

            self.setWindowTitle(
                "SlipStream — About"
            )