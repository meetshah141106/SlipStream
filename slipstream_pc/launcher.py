import os
import subprocess
import sys
import time


# ============================================================
# PATHS
# ============================================================

PROJECT_ROOT = os.path.dirname(
    os.path.abspath(__file__)
)

FRONTEND_DIR = os.path.join(
    PROJECT_ROOT,
    "frontend",
)

SERVER_FILE = os.path.join(
    PROJECT_ROOT,
    "server.py",
)

DESKTOP_FILE = os.path.join(
    PROJECT_ROOT,
    "ui",
    "desktop.py",
)


# ============================================================
# WINDOWS PROCESS SETTINGS
# ============================================================

CREATE_NO_WINDOW = 0x08000000


def run_frontend_build():
    """
    Build the React frontend before starting SlipStream.
    """

    print()
    print("===================================")
    print("       SLIPSTREAM FRONTEND         ")
    print("===================================")
    print("Building React frontend...")
    print()

    try:

        result = subprocess.run(
            [
                "npm.cmd",
                "run",
                "build",
            ],
            cwd=FRONTEND_DIR,
            creationflags=CREATE_NO_WINDOW,
        )

    except FileNotFoundError:

        print()
        print("ERROR: npm was not found.")
        print()
        print(
            "Make sure Node.js and npm are installed."
        )

        return False

    if result.returncode != 0:

        print()
        print("===================================")
        print("       FRONTEND BUILD FAILED       ")
        print("===================================")
        print()
        print(
            "SlipStream was not started."
        )

        return False

    print()
    print("Frontend build completed.")
    print()

    return True


def start_server():
    """
    Start the SlipStream UDP server.
    """

    print("Starting SlipStream server...")

    return subprocess.Popen(
        [
            sys.executable,
            SERVER_FILE,
        ],
        cwd=PROJECT_ROOT,
        creationflags=CREATE_NO_WINDOW,
    )


def start_desktop():
    """
    Start the PySide6 desktop application.
    """

    print("Starting SlipStream desktop...")

    return subprocess.Popen(
        [
            sys.executable,
            DESKTOP_FILE,
        ],
        cwd=PROJECT_ROOT,
        creationflags=CREATE_NO_WINDOW,
    )


def main():

    print()
    print("===================================")
    print("          SLIPSTREAM                ")
    print("===================================")
    print()

    server_process = None
    desktop_process = None

    try:

        # ====================================================
        # BUILD FRONTEND
        # ====================================================

        if not run_frontend_build():
            return 1

        # ====================================================
        # START SERVER
        # ====================================================

        server_process = start_server()

        # Give the server a moment to bind the UDP port.
        time.sleep(0.5)

        # ====================================================
        # START DESKTOP
        # ====================================================

        desktop_process = start_desktop()

        print()
        print("===================================")
        print("       SLIPSTREAM STARTED          ")
        print("===================================")
        print()
        print(
            "Close the SlipStream window to stop."
        )
        print()

        # ====================================================
        # WAIT FOR DESKTOP
        # ====================================================

        desktop_return_code = (
            desktop_process.wait()
        )

        return desktop_return_code

    except KeyboardInterrupt:

        print()
        print("Stopping SlipStream...")

        return 0

    finally:

        # ====================================================
        # STOP DESKTOP IF STILL RUNNING
        # ====================================================

        if (
            desktop_process is not None
            and desktop_process.poll() is None
        ):

            desktop_process.terminate()

            try:
                desktop_process.wait(
                    timeout=3
                )

            except subprocess.TimeoutExpired:
                desktop_process.kill()

        # ====================================================
        # STOP SERVER
        # ====================================================

        if (
            server_process is not None
            and server_process.poll() is None
        ):

            print(
                "Stopping SlipStream server..."
            )

            server_process.terminate()

            try:
                server_process.wait(
                    timeout=3
                )

            except subprocess.TimeoutExpired:

                server_process.kill()

        print()
        print("SlipStream stopped.")


if __name__ == "__main__":
    sys.exit(main())