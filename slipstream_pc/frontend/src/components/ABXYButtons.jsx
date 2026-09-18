function ABXYButtons({
  buttonStates = {},
}) {
  const buttonClass = (name, color) => {
    const pressed = buttonStates[name];

    return `
      absolute flex h-12 w-12 items-center justify-center
      rounded-full border-2
      font-mono text-sm font-semibold
      transition-all duration-75
      ${color}
      ${
        pressed
          ? "scale-90 bg-white/10 shadow-[0_0_24px_currentColor]"
          : "bg-transparent"
      }
    `;
  };

  return (
    <div className="flex h-full min-h-0 flex-col">

      {/* HEADER */}

      <div className="mb-2">
        <div className="text-[11px] font-medium uppercase tracking-[0.16em] text-white/35">
          Buttons
        </div>
      </div>

      {/* BUTTON LAYOUT */}

      <div className="relative min-h-0 flex-1">

        <div className="absolute left-1/2 top-1/2 h-[150px] w-[150px] -translate-x-1/2 -translate-y-1/2">

          {/* Y */}

          <div
            className={buttonClass(
              "Y",
              "border-yellow-400 text-yellow-400"
            )}
            style={{
              left: "50%",
              top: "0",
              transform: buttonStates.Y
                ? "translate(-50%, 0) scale(.90)"
                : "translate(-50%, 0)",
            }}
          >
            Y
          </div>

          {/* X */}

          <div
            className={buttonClass(
              "X",
              "border-blue-400 text-blue-400"
            )}
            style={{
              left: "0",
              top: "50%",
              transform: buttonStates.X
                ? "translate(0, -50%) scale(.90)"
                : "translate(0, -50%)",
            }}
          >
            X
          </div>

          {/* B */}

          <div
            className={buttonClass(
              "B",
              "border-red-400 text-red-400"
            )}
            style={{
              right: "0",
              top: "50%",
              transform: buttonStates.B
                ? "translate(0, -50%) scale(.90)"
                : "translate(0, -50%)",
            }}
          >
            B
          </div>

          {/* A */}

          <div
            className={buttonClass(
              "A",
              "border-green-400 text-green-400"
            )}
            style={{
              left: "50%",
              bottom: "0",
              transform: buttonStates.A
                ? "translate(-50%, 0) scale(.90)"
                : "translate(-50%, 0)",
            }}
          >
            A
          </div>

        </div>

      </div>

    </div>
  );
}

export default ABXYButtons;