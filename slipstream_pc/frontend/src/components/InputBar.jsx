function InputBar({
  label,
  value = 0,
  type = "normal",
}) {
  const numericValue = Number(value) || 0;

  /*
   * BIPOLAR INPUT
   * Used for Right Stick X/Y
   * Range -1.00 to +1.00
   */

  if (type === "bipolar") {
    const clamped = Math.max(
      -1,
      Math.min(1, numericValue)
    );

    const position =
      ((clamped + 1) / 2) * 100;

    const fillStart =
      clamped >= 0
        ? 50
        : position;

    const fillWidth =
      Math.abs(clamped) * 50;

    return (
      <div className="w-full">

        {/* LABEL */}

        <div className="mb-2 flex items-center justify-between">

          <span className="text-sm font-medium text-white/65">
            {label}
          </span>

          <span className="font-mono text-xs text-white/40">
            {clamped.toFixed(2)}
          </span>

        </div>


        {/* TRACK */}

        <div className="relative h-[9px] w-full rounded-full bg-white/[0.055]">

          {/* CENTER MARKER */}

          <div className="absolute left-1/2 top-1/2 h-[15px] w-px -translate-x-1/2 -translate-y-1/2 bg-white/20" />


          {/* FILL */}

          {Math.abs(clamped) > 0 && (
            <div
              className="absolute top-0 h-full rounded-full bg-blue-600 transition-all duration-100 ease-out"
              style={{
                left: `${fillStart}%`,
                width: `${fillWidth}%`,
              }}
            />
          )}


          {/* KNOB */}

          <div
            className="absolute top-1/2 h-[13px] w-[13px] -translate-x-1/2 -translate-y-1/2 rounded-full border-2 border-[#17181b] bg-blue-600 shadow-[0_0_8px_rgba(37,99,235,0.35)] transition-all duration-100 ease-out"
            style={{
              left: `${position}%`,
            }}
          />

        </div>


        {/* SCALE */}

        <div className="mt-1.5 flex justify-between font-mono text-[9px] text-white/20">

          <span>-1.00</span>

          <span>0.00</span>

          <span>+1.00</span>

        </div>

      </div>
    );
  }


  /*
   * NORMAL INPUT
   * Used for Gas/Brake
   */

  const percentage = Math.max(
    0,
    Math.min(100, numericValue * 100)
  );


  let fillClass = "bg-blue-400";

  if (type === "gas") {
    fillClass = "bg-green-500";
  }

  if (type === "brake") {
    fillClass = "bg-red-500";
  }


  return (
    <div className="w-full">

      {/* LABEL */}

      <div className="mb-2 flex items-center justify-between">

        <span className="text-sm font-medium text-white/65">
          {label}
        </span>

        <span className="font-mono text-xs text-white/40">
          {Math.round(percentage)}%
        </span>

      </div>


      {/* TRACK */}

      <div className="h-[9px] w-full rounded-full bg-white/[0.055]">

        <div
          className={`h-full rounded-full ${fillClass} transition-all duration-100 ease-out`}
          style={{
            width: `${percentage}%`,
          }}
        />

      </div>

    </div>
  );
}

export default InputBar;