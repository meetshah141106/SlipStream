from PySide6.QtCore import Signal
from PySide6.QtWidgets import (
    QFrame,
    QVBoxLayout,
    QLabel,
    QPushButton,
    QWidget,
    QSizePolicy,
)


class Sidebar(QFrame):

    page_changed = Signal(str)

    def __init__(self, parent=None):
        super().__init__(parent)

        self.setObjectName("sidebar")
        self.setFixedWidth(220)

        layout = QVBoxLayout(self)
        layout.setContentsMargins(18, 24, 18, 20)
        layout.setSpacing(6)

        # Logo
        logo = QLabel("SlipStream")
        logo.setObjectName("logo")

        subtitle = QLabel("PC Controller")
        subtitle.setObjectName("logoSubtitle")

        layout.addWidget(logo)
        layout.addWidget(subtitle)

        layout.addSpacing(28)

        self.buttons = {}

        self.add_nav_button(
            layout,
            "⌂   Dashboard",
            "dashboard",
        )

        self.add_nav_button(
            layout,
            "🎮   Controller",
            "controller",
        )

        self.add_nav_button(
            layout,
            "📱   Devices",
            "devices",
        )

        self.add_nav_button(
            layout,
            "⚙   Settings",
            "settings",
        )

        layout.addStretch()

        self.add_nav_button(
            layout,
            "ⓘ   About",
            "about",
        )

        self.select_page("dashboard")

    def add_nav_button(
        self,
        layout,
        text,
        page,
    ):
        button = QPushButton(text)

        button.setObjectName("navButton")
        button.setProperty("selected", False)

        button.setCursor(
            __import__("PySide6").QtCore.Qt.CursorShape.PointingHandCursor
        )

        button.clicked.connect(
            lambda: self.select_page(page)
        )

        self.buttons[page] = button

        layout.addWidget(button)

    def select_page(self, page: str):

        for name, button in self.buttons.items():
            button.setProperty(
                "selected",
                name == page,
            )

            button.style().unpolish(button)
            button.style().polish(button)

        self.page_changed.emit(page)