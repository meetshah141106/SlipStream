import { useEffect, useState } from "react";

import BorderGlow from "../components/BorderGlow";
import SteeringGauge from "../components/SteeringGauge";
import JoystickWidget from "../components/JoystickWidget";
import ABXYButtons from "../components/ABXYButtons";
import ThemeToggle from "../components/ThemeToggle";

function Dashboard() {
  const [status, setStatus] = useState({
    server_running: false,
    phone_connected: false,
    phone_ip: null,
    phone_port: null,
    controller_active: false,
    inputs: {
      steering: 0,
      gas: 0,
      brake: 0,
      right_stick_x: 0,
      right_stick_y: 0,
      last_button: "None",
    },
  });

  const [buttonStates, setButtonStates] = useState({
    A: false,
    B: false,
    X: false,
    Y: false,
  });

  const [activity, setActivity] = useState([]);

  useEffect(() => {
    const handleStatus = (event) => {
      const nextStatus = event.detail;

      setStatus(nextStatus);

      const lastButton =
        nextStatus.inputs?.last_button || "None";

      if (
        lastButton !== "None" &&
        lastButton.includes("•")
      ) {
        const parts = lastButton.split("•");

        const name = parts[0].trim();
        const action = parts[1]?.trim() || "";

        if (
          ["A", "B", "X", "Y"].includes(name)
        ) {
          const pressed =
            action === "PRESSED";

          setButtonStates((previous) => ({
            ...previous,
            [name]: pressed,
          }));
        }

        setActivity((previous) => {
          const item = {
            name,
            action,
            time: new Date().toLocaleTimeString(
              [],
              {
                hour: "2-digit",
                minute: "2-digit",
                second: "2-digit",
              }
            ),
          };

          return [
            item,
            ...previous,
          ].slice(0, 5);
        });
      }
    };

    window.addEventListener(
      "slipstream-status",
      handleStatus
    );

    return () => {
      window.removeEventListener(
        "slipstream-status",
        handleStatus
      );
    };
  }, []);

  const inputs = status.inputs || {};

  const steering =
    Number(inputs.steering) || 0;

  const gas =
    Number(inputs.gas) || 0;

  const brake =
    Number(inputs.brake) || 0;

  const rightStickX =
    Number(inputs.right_stick_x) || 0;

  const rightStickY =
    Number(inputs.right_stick_y) || 0;

  const connected =
    Boolean(status.phone_connected);

  const controllerActive =
    Boolean(status.controller_active);

  return (
    <div className="flex h-screen overflow-hidden bg-[#111214] text-white">

      {/* ================================================== */}
      {/* SIDEBAR */}
      {/* ================================================== */}

      <aside className="flex h-screen w-[225px] shrink-0 flex-col border-r border-white/8 bg-[#151619]">

        <div className="px-6 pt-7">

          <div className="text-[22px] font-semibold tracking-tight">
            Slip<span className="text-blue-500">Stream</span>
          </div>

          <div className="mt-1 text-xs text-white/30">
            PC Controller
          </div>

        </div>

        <nav className="mt-9 px-4">

          <button className="w-full rounded-xl bg-white/[0.07] px-4 py-3 text-left text-sm font-medium text-white">
            Dashboard
          </button>

          <button className="mt-2 w-full rounded-xl px-4 py-3 text-left text-sm text-white/35 transition hover:bg-white/[0.04] hover:text-white/70">
            Settings
          </button>

        </nav>

        <div className="mt-auto px-6 pb-6">

          <div className="font-mono text-[10px] text-white/25">
            v1.0.0
          </div>

          <div className="mt-3 flex items-center gap-2 text-xs text-white/45">

            <span className="h-2 w-2 rounded-full bg-green-500 shadow-[0_0_8px_rgba(34,197,94,0.5)]" />

            Server Running

          </div>

        </div>

      </aside>

      {/* ================================================== */}
      {/* MAIN */}
      {/* ================================================== */}

      <main className="min-w-0 flex-1 overflow-hidden px-5 py-5">

        <div className="flex h-full min-h-0 flex-col">

          {/* HEADER */}

          <header className="mb-4 flex shrink-0 items-start justify-between">

            <div>

              <h1 className="text-[23px] font-semibold tracking-tight">
                Dashboard
              </h1>

              <p className="mt-1 text-xs text-white/30">
                Monitor your SlipStream controller
              </p>

            </div>

            <div className="flex items-center gap-3">

              <div className="flex items-center gap-2 rounded-full border border-white/10 bg-white/[0.025] px-4 py-2 text-xs text-white/60">

                <span className="h-2 w-2 rounded-full bg-green-500 shadow-[0_0_8px_rgba(34,197,94,0.45)]" />

                Server Running

              </div>

              <ThemeToggle />

            </div>

          </header>

          {/* ================================================== */}
          {/* TOP STATUS */}
          {/* ================================================== */}

          <section className="mb-4 grid shrink-0 grid-cols-3 gap-4">

            <StatusCard
              label="Phone"
              active={connected}
              activeText="Connected"
              inactiveText="Disconnected"
              detail={
                connected
                  ? `${status.phone_ip || "—"}:${status.phone_port || "—"}`
                  : "Waiting for connection"
              }
            />

            <StatusCard
              label="Controller"
              active={controllerActive}
              activeText="Active"
              inactiveText="Inactive"
              detail={
                controllerActive
                  ? "Receiving input"
                  : "No input received"
              }
            />

            <StatusCard
              label="Protocol"
              active
              activeText="UDP"
              inactiveText="UDP"
              detail={`Port ${status.phone_port || "5005"}`}
              blue
            />

          </section>

          {/* ================================================== */}
          {/* LIVE INPUT */}
          {/* ================================================== */}

          <BorderGlow
            className="mb-4 min-h-0 flex-1"
            backgroundColor="#151619"
            borderRadius={20}
            glowRadius={30}
            glowIntensity={0.55}
            animated={false}
          >

            <section className="flex h-full min-h-0 flex-col p-4">

              {/* LIVE INPUT HEADER */}

              <div className="mb-3 flex shrink-0 items-center justify-between">

                <div>

                  <h2 className="text-base font-semibold">
                    Live Input
                  </h2>

                  <p className="mt-0.5 text-[11px] text-white/30">
                    Real-time controller state
                  </p>

                </div>

                <div className="flex items-center gap-2 rounded-full border border-white/10 px-3 py-1.5 text-[10px] text-white/40">

                  <span
                    className={`h-1.5 w-1.5 rounded-full ${
                      controllerActive
                        ? "bg-blue-500 shadow-[0_0_7px_rgba(59,130,246,.6)]"
                        : "bg-white/25"
                    }`}
                  />

                  {controllerActive
                    ? "LIVE"
                    : "NO INPUT"}

                </div>

              </div>

              {/* ================================================= */}
              {/* GAS + BRAKE — FULL WIDTH */}
              {/* ================================================= */}

              <div className="mb-3 shrink-0 rounded-xl border border-white/[0.07] bg-white/[0.02] px-5 py-4">

                <ThrottleBar
                  label="Gas"
                  value={gas}
                  type="gas"
                />

                <div className="my-4 h-px bg-white/[0.05]" />

                <ThrottleBar
                  label="Brake"
                  value={brake}
                  type="brake"
                />

              </div>

              {/* ================================================= */}
              {/* BOTTOM WIDGETS */}
              {/* ================================================= */}

              <div className="grid min-h-0 flex-1 grid-cols-[1.45fr_1fr_1fr] gap-3">

                {/* STEERING */}

                <div className="min-h-0 rounded-xl border border-white/[0.07] bg-white/[0.02] p-3">

                  <SteeringGauge
                    value={steering}
                  />

                </div>

                {/* JOYSTICK */}

                <div className="min-h-0 rounded-xl border border-white/[0.07] bg-white/[0.02] p-4">

                  <JoystickWidget
                    x={rightStickX}
                    y={rightStickY}
                  />

                </div>

                {/* BUTTONS */}

                <div className="min-h-0 rounded-xl border border-white/[0.07] bg-white/[0.02] p-4">

                  <ABXYButtons
                    buttonStates={buttonStates}
                  />

                </div>

              </div>

            </section>

          </BorderGlow>

          {/* ================================================== */}
          {/* BOTTOM */}
          {/* ================================================== */}

          <section className="grid h-[150px] shrink-0 grid-cols-[1fr_1fr] gap-4">

            {/* CONNECTION */}

            <BorderGlow
              backgroundColor="#151619"
              borderRadius={18}
              glowRadius={25}
              glowIntensity={0.35}
            >

              <div className="h-full p-4">

                <div className="flex items-center justify-between">

                  <div>

                    <h2 className="text-sm font-semibold">
                      Connection
                    </h2>

                    <p className="mt-0.5 text-[10px] text-white/25">
                      Current network connection
                    </p>

                  </div>

                  <div className="rounded-full border border-white/10 px-3 py-1 text-[10px] text-white/35">
                    {connected
                      ? "ONLINE"
                      : "OFFLINE"}
                  </div>

                </div>

                <div className="mt-4 grid grid-cols-4 gap-4">

                  <InfoItem
                    label="Status"
                    value={
                      connected
                        ? "Connected"
                        : "Disconnected"
                    }
                  />

                  <InfoItem
                    label="IP Address"
                    value={
                      status.phone_ip || "—"
                    }
                  />

                  <InfoItem
                    label="Port"
                    value={
                      status.phone_port || "—"
                    }
                  />

                  <InfoItem
                    label="Protocol"
                    value="UDP"
                  />

                </div>

              </div>

            </BorderGlow>

            {/* RECENT ACTIVITY */}

            <BorderGlow
              backgroundColor="#151619"
              borderRadius={18}
              glowRadius={25}
              glowIntensity={0.35}
            >

              <div className="h-full overflow-hidden p-4">

                <div className="flex items-center justify-between">

                  <div>

                    <h2 className="text-sm font-semibold">
                      Recent Activity
                    </h2>

                    <p className="mt-0.5 text-[10px] text-white/25">
                      Latest controller events
                    </p>

                  </div>

                  <span className="text-[10px] text-blue-400/60">
                    LIVE
                  </span>

                </div>

                <div className="mt-3 space-y-1">

                  {activity.length === 0 ? (

                    <div className="rounded-lg border border-white/[0.05] px-3 py-2.5 text-[11px] text-white/25">
                      No controller activity
                    </div>

                  ) : (

                    activity.map(
                      (item, index) => (
                        <div
                          key={`${item.time}-${index}`}
                          className="flex items-center justify-between border-b border-white/[0.04] py-1.5 text-[10px]"
                        >

                          <span className="text-white/60">
                            {item.name}
                          </span>

                          <span className="text-white/30">
                            {item.action}
                          </span>

                          <span className="font-mono text-white/20">
                            {item.time}
                          </span>

                        </div>
                      )
                    )

                  )}

                </div>

              </div>

            </BorderGlow>

          </section>

        </div>

      </main>

    </div>
  );
}


/* ====================================================== */
/* STATUS CARD */
/* ====================================================== */

function StatusCard({
  label,
  active,
  activeText,
  inactiveText,
  detail,
  blue = false,
}) {
  return (
    <div className="rounded-2xl border border-white/[0.09] bg-[#151619] px-4 py-3">

      <div className="text-[10px] uppercase tracking-[0.12em] text-white/30">
        {label}
      </div>

      <div className="mt-2 flex items-center gap-2">

        <span
          className={`h-2.5 w-2.5 rounded-full ${
            active
              ? blue
                ? "bg-blue-500"
                : "bg-green-500 shadow-[0_0_8px_rgba(34,197,94,.45)]"
              : "bg-white/25"
          }`}
        />

        <span className="text-sm font-semibold">
          {active
            ? activeText
            : inactiveText}
        </span>

      </div>

      <div className="mt-1 text-[10px] text-white/25">
        {detail}
      </div>

    </div>
  );
}


/* ====================================================== */
/* THROTTLE BAR */
/* ====================================================== */

function ThrottleBar({
  label,
  value,
  type,
}) {
  const percentage = Math.max(
    0,
    Math.min(
      100,
      Number(value || 0) * 100
    )
  );

  const isGas = type === "gas";

  return (
    <div>

      <div className="mb-2 flex items-center justify-between">

        <span className="text-sm font-medium text-white/70">
          {label}
        </span>

        <span className="font-mono text-xs text-white/45">
          {Math.round(percentage)}%
        </span>

      </div>

      <div className="h-[10px] overflow-hidden rounded-full bg-white/[0.055]">

        <div
          className={`h-full rounded-full transition-[width] duration-75 ease-out ${
            isGas
              ? "bg-blue-500 shadow-[0_0_10px_rgba(59,130,246,.35)]"
              : "bg-red-500 shadow-[0_0_10px_rgba(239,68,68,.3)]"
          }`}
          style={{
            width: `${percentage}%`,
          }}
        />

      </div>

    </div>
  );
}


/* ====================================================== */
/* INFO ITEM */
/* ====================================================== */

function InfoItem({
  label,
  value,
}) {
  return (
    <div>

      <div className="text-[9px] uppercase tracking-[0.1em] text-white/25">
        {label}
      </div>

      <div className="mt-1 truncate font-mono text-[11px] text-white/65">
        {value}
      </div>

    </div>
  );
}

export default Dashboard;