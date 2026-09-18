from PySide6.QtWidgets import (
    QFrame,
    QVBoxLayout,
    QLabel,
)


class StatusCard(QFrame):

    def __init__(
        self,
        title: str,
        value: str,
        description: str,
        parent=None,
    ):
        super().__init__(parent)

        self.setObjectName("statusCard")

        layout = QVBoxLayout(self)
        layout.setContentsMargins(20, 18, 20, 18)
        layout.setSpacing(6)

        title_label = QLabel(title)
        title_label.setObjectName("cardTitle")

        value_label = QLabel(value)
        value_label.setObjectName("cardValue")

        description_label = QLabel(description)
        description_label.setObjectName("cardDescription")

        layout.addWidget(title_label)
        layout.addWidget(value_label)
        layout.addWidget(description_label)

        self.value_label = value_label
        self.description_label = description_label

    def set_value(self, value: str):
        self.value_label.setText(value)

    def set_description(self, description: str):
        self.description_label.setText(description)