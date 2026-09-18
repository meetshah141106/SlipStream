import json
import os
import sys

from PySide6.QtCore import QTimer, QUrl
from PySide6.QtWidgets import QApplication
from PySide6.QtWebEngineWidgets import QWebEngineView


class SlipStreamWindow(QWebEngineView):

    def __init__(self):
        super().__init__()

        self.setWindowTitle("SlipStream")
        self.resize(1400, 900)

        # ====================================================
        # PATHS
        # ====================================================

        project_root = os.path.abspath(
            os.path.join(
                os.path.dirname(__file__),
                "..",
            )
        )

        self.frontend_path = os.path.join(
            project_root,
            "frontend",
            "dist",
            "index.html",
        )

        self.status_file = os.path.join(
            project_root,
            "status.json",
        )

        # ====================================================
        # LOAD REACT
        # ====================================================

        self.load(
            QUrl.fromLocalFile(
                self.frontend_path
            )
        )

        # ====================================================
        # STATUS TIMER
        # ====================================================

        self.status_timer = QTimer(self)

        self.status_timer.timeout.connect(
            self.send_status_to_react
        )

        # 100 ms = 10 updates per second
        self.status_timer.start(16)

    # ========================================================
    # READ STATUS.JSON
    # ========================================================

    def read_status(self):

        if not os.path.exists(
            self.status_file
        ):
            return None

        try:

            with open(
                self.status_file,
                "r",
                encoding="utf-8",
            ) as file:

                return json.load(file)

        except (
            OSError,
            json.JSONDecodeError,
        ):

            return None

    # ========================================================
    # SEND STATUS TO REACT
    # ========================================================

    def send_status_to_react(self):

        status = self.read_status()

        if status is None:
            return

        try:

            status_json = json.dumps(
                status,
                separators=(",", ":"),
            )

            javascript = f"""
                window.dispatchEvent(
                    new CustomEvent(
                        "slipstream-status",
                        {{
                            detail: {status_json}
                        }}
                    )
                );
            """

            self.page().runJavaScript(
                javascript
            )

        except Exception as error:

            print(
                "Failed to send status:",
                error,
            )


# ============================================================
# APPLICATION
# ============================================================

def main():

    app = QApplication(sys.argv)

    window = SlipStreamWindow()

    window.show()

    sys.exit(
        app.exec()
    )


if __name__ == "__main__":
    main()