import time
import vgamepad as vg


gamepad = vg.VX360Gamepad()

print("Virtual controller created.")
print("Moving left stick...")

for value in [-1.0, -0.5, 0.0, 0.5, 1.0, 0.0]:

    x = int(value * 32767)

    gamepad.left_joystick(
        x_value=x,
        y_value=0
    )

    gamepad.update()

    print("Stick X:", value)

    time.sleep(1)


print("Pressing A...")

gamepad.press_button(
    button=vg.XUSB_BUTTON.XUSB_GAMEPAD_A
)

gamepad.update()

time.sleep(1)

gamepad.release_button(
    button=vg.XUSB_BUTTON.XUSB_GAMEPAD_A
)

gamepad.update()

print("Done.")