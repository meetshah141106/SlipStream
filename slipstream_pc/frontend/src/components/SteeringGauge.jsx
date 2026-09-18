function SteeringGauge({ value = 0 }) {
  const steering = Math.max(
    -1,
    Math.min(1, Number(value) || 0)
  );

  /*
    Steering:
      -1.00 = far left
       0.00 = center
      +1.00 = far right
  */

  const angle = 270 + steering * 70;

  const centerX = 200;
  const centerY = 185;

  const needleLength = 125;

  const angleRad =
    (angle * Math.PI) / 180;

  const needleX =
    centerX +
    Math.cos(angleRad) *
      needleLength;

  const needleY =
    centerY +
    Math.sin(angleRad) *
      needleLength;

  const status =
    steering === 0
      ? "CENTER"
      : steering < 0
        ? "LEFT"
        : "RIGHT";


  return (
    <div className="relative w-full">

      {/* ==================================================
          VALUE
      ================================================== */}

      <div className="mb-2 text-center">

        <div className="font-mono text-[32px] font-semibold tracking-tight text-white">
          {steering.toFixed(2)}
        </div>

        <div className="mt-0.5 text-[11px] uppercase tracking-[0.22em] text-white/30">
          {status}
        </div>

      </div>


      {/* ==================================================
          GAUGE
      ================================================== */}

      <div className="w-full">

        <svg
          viewBox="0 0 400 250"
          className="h-auto w-full"
          preserveAspectRatio="xMidYMid meet"
        >

          {/* =================================================
              OUTER GAUGE
          ================================================= */}

          <path
            d="M 40 185 A 160 160 0 0 1 360 185"
            fill="none"
            stroke="rgba(24,24,27,0.08)"
            strokeWidth="22"
            strokeLinecap="round"
          />


          {/* =================================================
              BLUE GAUGE BACKGROUND
          ================================================= */}

          <path
            d="M 40 185 A 160 160 0 0 1 360 185"
            fill="none"
            stroke="rgba(37,99,235,0.12)"
            strokeWidth="7"
            strokeLinecap="round"
          />


          {/* =================================================
              BLUE GAUGE ARC
          ================================================= */}

          <path
            d="M 40 185 A 160 160 0 0 1 360 185"
            fill="none"
            stroke="#2563eb"
            strokeOpacity="0.78"
            strokeWidth="3"
            strokeLinecap="round"
            style={{
              filter:
                "drop-shadow(0 0 5px rgba(37,99,235,0.28))",
            }}
          />


          {/* =================================================
              TICKS
          ================================================= */}

          <line
            x1="40"
            y1="185"
            x2="59"
            y2="185"
            stroke="rgba(24,24,27,0.18)"
            strokeWidth="2"
          />

          <line
            x1="73"
            y1="92"
            x2="87"
            y2="106"
            stroke="rgba(24,24,27,0.16)"
            strokeWidth="2"
          />

          <line
            x1="200"
            y1="25"
            x2="200"
            y2="48"
            stroke="rgba(24,24,27,0.30)"
            strokeWidth="2"
          />

          <line
            x1="327"
            y1="92"
            x2="313"
            y2="106"
            stroke="rgba(24,24,27,0.16)"
            strokeWidth="2"
          />

          <line
            x1="360"
            y1="185"
            x2="341"
            y2="185"
            stroke="rgba(24,24,27,0.18)"
            strokeWidth="2"
          />


          {/* =================================================
              NEEDLE
              No CSS transition.
              Moves immediately with the live value.
          ================================================= */}

          <line
            x1={centerX}
            y1={centerY}
            x2={needleX}
            y2={needleY}
            stroke="#2563eb"
            strokeWidth="4"
            strokeLinecap="round"
            style={{
              filter:
                "drop-shadow(0 0 7px rgba(37,99,235,0.45))",
            }}
          />


          {/* =================================================
              NEEDLE END
          ================================================= */}

          <circle
            cx={needleX}
            cy={needleY}
            r="7"
            fill="#2563eb"
            style={{
              filter:
                "drop-shadow(0 0 8px rgba(37,99,235,0.4))",
            }}
          />


          {/* =================================================
              CENTER HUB
          ================================================= */}

          <circle
            cx={centerX}
            cy={centerY}
            r="15"
            fill="#ffffff"
            stroke="#2563eb"
            strokeWidth="3"
            style={{
              filter:
                "drop-shadow(0 0 6px rgba(37,99,235,0.3))",
            }}
          />

          <circle
            cx={centerX}
            cy={centerY}
            r="6"
            fill="#2563eb"
          />


          {/* =================================================
              SCALE
          ================================================= */}

          <text
            x="40"
            y="218"
            textAnchor="middle"
            fill="rgba(24,24,27,0.30)"
            fontSize="11"
            fontFamily="ui-monospace, SFMono-Regular, Menlo, monospace"
          >
            -1.00
          </text>

          <text
            x="200"
            y="218"
            textAnchor="middle"
            fill="rgba(24,24,27,0.30)"
            fontSize="11"
            fontFamily="ui-monospace, SFMono-Regular, Menlo, monospace"
          >
            0.00
          </text>

          <text
            x="360"
            y="218"
            textAnchor="middle"
            fill="rgba(24,24,27,0.30)"
            fontSize="11"
            fontFamily="ui-monospace, SFMono-Regular, Menlo, monospace"
          >
            +1.00
          </text>

        </svg>

      </div>

    </div>
  );
}

export default SteeringGauge;