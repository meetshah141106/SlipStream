function JoystickWidget({
  x = 0,
  y = 0,
}) {
  const joystickX = Math.max(
    -1,
    Math.min(1, Number(x) || 0)
  );

  const joystickY = Math.max(
    -1,
    Math.min(1, Number(y) || 0)
  );

  // Maximum distance the knob can move
  const MAX_OFFSET = 45;

  // X: positive = right
  const offsetX =
    joystickX * MAX_OFFSET;

  // Y: positive = UP
  // CSS positive Y = DOWN, so invert it
  const offsetY =
    -joystickY * MAX_OFFSET;

  return (
    <div className="flex h-full min-h-0 flex-col">

      {/* HEADER */}

      <div className="mb-2 shrink-0">
        <div className="text-[11px] font-medium uppercase tracking-[0.16em] text-white/35">
          Right Stick
        </div>
      </div>

      {/* JOYSTICK */}

      <div className="flex min-h-0 flex-1 items-center justify-center">

        <div className="relative aspect-square h-[min(100%,155px)] max-h-[155px] w-auto">

          {/* OUTER RING */}

          <div className="absolute inset-0 rounded-full border border-blue-500/40 bg-blue-500/[0.025]" />

          {/* INNER RING */}

          <div className="absolute inset-[18%] rounded-full border border-white/[0.06]" />

          <div className="absolute inset-[36%] rounded-full border border-white/[0.05]" />

          {/* CROSSHAIR */}

          <div className="absolute left-1/2 top-0 h-full w-px -translate-x-1/2 bg-blue-400/15" />

          <div className="absolute left-0 top-1/2 h-px w-full -translate-y-1/2 bg-blue-400/15" />

          {/* DIRECTION MARKERS */}

          <div className="absolute left-1/2 top-2 h-1 w-1 -translate-x-1/2 rounded-full bg-blue-400/50" />

          <div className="absolute bottom-2 left-1/2 h-1 w-1 -translate-x-1/2 rounded-full bg-blue-400/50" />

          <div className="absolute left-2 top-1/2 h-1 w-1 -translate-y-1/2 rounded-full bg-blue-400/50" />

          <div className="absolute right-2 top-1/2 h-1 w-1 -translate-y-1/2 rounded-full bg-blue-400/50" />

          {/* MOVING KNOB */}

          <div
            className="absolute left-1/2 top-1/2 h-10 w-10 rounded-full border-2 border-blue-300 bg-blue-500 shadow-[0_0_20px_rgba(37,99,235,0.65)] transition-transform duration-75 ease-out"
            style={{
              transform: `
                translate(
                  calc(-50% + ${offsetX}px),
                  calc(-50% + ${offsetY}px)
                )
              `,
            }}
          >
            <div className="absolute inset-[7px] rounded-full bg-blue-300/70" />
          </div>

        </div>

      </div>

      {/* VALUES */}

      <div className="mt-2 flex shrink-0 justify-center gap-5 font-mono text-[10px] text-white/35">

        <span>
          X:{" "}
          <span className="text-white/65">
            {joystickX.toFixed(2)}
          </span>
        </span>

        <span>
          Y:{" "}
          <span className="text-white/65">
            {joystickY.toFixed(2)}
          </span>
        </span>

      </div>

    </div>
  );
}

export default JoystickWidget;