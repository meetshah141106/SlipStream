import { useEffect, useState } from "react";

import BorderGlow from "../components/BorderGlow";
import InputBar from "../components/InputBar";
import SteeringGauge from "../components/SteeringGauge";
import ThemeToggle from "../components/ThemeToggle";


function Dashboard() {

  /* ==========================================================
     LIVE STATUS
  ========================================================== */

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


  /* ==========================================================
     RECEIVE DATA FROM PYSIDE6
  ========================================================== */

  useEffect(() => {

    const handleStatus = (event) => {

      if (!event.detail) {
        return;
      }

      setStatus(event.detail);

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


  /* ==========================================================
     INPUT VALUES
  ========================================================== */

  const steering =
    Number(status.inputs?.steering) || 0;

  const gas =
    Number(status.inputs?.gas) || 0;

  const brake =
    Number(status.inputs?.brake) || 0;

  const rightStickX =
    Number(status.inputs?.right_stick_x) || 0;

  const rightStickY =
    Number(status.inputs?.right_stick_y) || 0;


  /* ==========================================================
     CONNECTION STATE
  ========================================================== */

  const serverRunning =
    Boolean(status.server_running);

  const phoneConnected =
    Boolean(status.phone_connected);

  const controllerActive =
    Boolean(status.controller_active);


  const phoneIP =
    status.phone_ip || "—";

  const phonePort =
    status.phone_port || "—";


  /* ==========================================================
     ACTIVITY
  ========================================================== */

  const lastButton =
    status.inputs?.last_button || "None";

  const hasActivity =
    lastButton !== "None";


  return (
    <div className="min-h-screen bg-[#111214] text-white">

      <div className="flex min-h-screen">


        {/* =====================================================
            SIDEBAR
        ===================================================== */}

        <aside className="relative w-[220px] shrink-0 border-r border-white/8 bg-[#151619] p-5">

          <div className="mb-10">

            <div className="text-xl font-semibold tracking-tight">
              SlipStream
            </div>

            <div className="mt-1 text-xs text-white/35">
              PC Controller
            </div>

          </div>


          <nav className="space-y-2">

            <div className="rounded-xl bg-white/[0.07] px-4 py-3 text-sm font-medium text-white">
              Dashboard
            </div>

            <div className="px-4 py-3 text-sm text-white/35">
              Settings
            </div>

          </nav>


          <div className="absolute bottom-5 left-5 text-xs text-white/25">
            v1.0.0
          </div>

        </aside>



        {/* =====================================================
            MAIN CONTENT
        ===================================================== */}

        <main className="min-w-0 flex-1 p-7">


          {/* ===================================================
              HEADER
          =================================================== */}

          <header className="mb-7 flex items-center justify-between">

            <div>

              <h1 className="text-2xl font-semibold tracking-tight">
                Dashboard
              </h1>

              <p className="mt-1 text-sm text-white/40">
                Monitor your SlipStream controller
              </p>

            </div>


            <div className="flex items-center gap-4">


              {/* SERVER STATUS */}

              <div className="flex items-center gap-2 rounded-full border border-white/10 bg-white/[0.04] px-4 py-2 text-sm">

                <span
                  className={`h-2.5 w-2.5 rounded-full ${
                    serverRunning
                      ? "bg-green-400"
                      : "bg-red-400"
                  }`}
                />

                <span className="text-white/70">

                  {serverRunning
                    ? "Server Running"
                    : "Server Stopped"}

                </span>

              </div>


              {/* THEME */}

              <ThemeToggle />

            </div>

          </header>



          {/* ===================================================
              STATUS CARDS
          =================================================== */}

          <div className="mb-6 grid grid-cols-3 gap-5">


            {/* PHONE */}

            <StatusCard
              title="Phone"
              value={
                phoneConnected
                  ? "Connected"
                  : "Disconnected"
              }
              detail={
                phoneConnected
                  ? "Phone connected"
                  : "Waiting for connection"
              }
              dot={
                phoneConnected
                  ? "bg-green-400"
                  : "bg-white/25"
              }
            />


            {/* CONTROLLER */}

            <StatusCard
              title="Controller"
              value={
                controllerActive
                  ? "Active"
                  : "Inactive"
              }
              detail={
                controllerActive
                  ? "Receiving input"
                  : "No input received"
              }
              dot={
                controllerActive
                  ? "bg-green-400"
                  : "bg-white/25"
              }
            />


            {/* PROTOCOL */}

            <StatusCard
              title="Protocol"
              value="UDP"
              detail="Port 5005"
              dot="bg-blue-400"
            />

          </div>



          {/* ===================================================
              LIVE INPUT
          =================================================== */}

          <section className="mb-6">

            <BorderGlow
              backgroundColor="#17181b"
              borderRadius={18}
              glowRadius={28}
              glowIntensity={0.75}
              coneSpread={22}
              colors={[
                "#38bdf8",
                "#c084fc",
                "#22c55e",
              ]}
              fillOpacity={0.18}
            >

              <div className="p-6">


                {/* LIVE INPUT HEADER */}

                <div className="mb-6 flex items-center justify-between">

                  <div>

                    <h2 className="text-lg font-semibold">
                      Live Input
                    </h2>

                    <p className="mt-1 text-xs text-white/35">
                      Real-time controller state
                    </p>

                  </div>


                  <div
                    className={`rounded-full border px-3 py-1 text-xs ${
                      controllerActive
                        ? "border-green-400/20 bg-green-400/10 text-green-500"
                        : "border-white/10 bg-white/[0.04] text-white/40"
                    }`}
                  >

                    {controllerActive
                      ? "Input Active"
                      : "No Input"}

                  </div>

                </div>



                {/* INPUT CONTENT */}

                <div className="grid grid-cols-[330px_1fr] items-start gap-10">


                  {/* STEERING */}

                  <div>

                    <div className="mb-3 text-xs uppercase tracking-wider text-white/35">
                      Steering
                    </div>

                    <SteeringGauge
                      value={steering}
                    />

                  </div>



                  {/* INPUT BARS */}

                  <div className="space-y-6 pt-2">

                    <InputBar
                      label="Gas"
                      value={gas}
                      type="gas"
                    />

                    <InputBar
                      label="Brake"
                      value={brake}
                      type="brake"
                    />

                    <InputBar
                      label="Right Stick X"
                      value={rightStickX}
                      type="bipolar"
                    />

                    <InputBar
                      label="Right Stick Y"
                      value={rightStickY}
                      type="bipolar"
                    />

                  </div>

                </div>

              </div>

            </BorderGlow>

          </section>



          {/* ===================================================
              LOWER CARDS
          =================================================== */}

          <div className="grid grid-cols-2 gap-5">


            {/* =================================================
                CONNECTION
            ================================================= */}

            <BorderGlow
              backgroundColor="#17181b"
              borderRadius={18}
              glowRadius={25}
              glowIntensity={0.7}
              coneSpread={22}
              colors={[
                "#38bdf8",
                "#c084fc",
                "#22c55e",
              ]}
              fillOpacity={0.15}
            >

              <div className="p-6">


                <div className="flex items-center justify-between">

                  <div>

                    <h2 className="text-lg font-semibold">
                      Connection
                    </h2>

                    <p className="mt-1 text-xs text-white/30">
                      Current network connection
                    </p>

                  </div>


                  <div
                    className={`flex items-center gap-2 rounded-full border px-3 py-1.5 ${
                      phoneConnected
                        ? "border-green-400/20 bg-green-400/10"
                        : "border-white/8 bg-white/[0.03]"
                    }`}
                  >

                    <span
                      className={`h-2 w-2 rounded-full ${
                        phoneConnected
                          ? "bg-green-400"
                          : "bg-white/25"
                      }`}
                    />

                    <span
                      className={`text-[10px] uppercase tracking-wider ${
                        phoneConnected
                          ? "text-green-500"
                          : "text-white/35"
                      }`}
                    >

                      {phoneConnected
                        ? "Online"
                        : "Offline"}

                    </span>

                  </div>

                </div>



                <div className="mt-6 grid grid-cols-2 gap-x-8 gap-y-5">

                  <ConnectionItem
                    label="Status"
                    value={
                      phoneConnected
                        ? "Connected"
                        : "Disconnected"
                    }
                  />

                  <ConnectionItem
                    label="Controller"
                    value={
                      controllerActive
                        ? "Active"
                        : "Inactive"
                    }
                  />

                  <ConnectionItem
                    label="IP Address"
                    value={phoneIP}
                  />

                  <ConnectionItem
                    label="Port"
                    value={phonePort}
                  />

                </div>

              </div>

            </BorderGlow>



            {/* =================================================
                RECENT ACTIVITY
            ================================================= */}

            <BorderGlow
              backgroundColor="#17181b"
              borderRadius={18}
              glowRadius={25}
              glowIntensity={0.7}
              coneSpread={22}
              colors={[
                "#38bdf8",
                "#c084fc",
                "#22c55e",
              ]}
              fillOpacity={0.15}
            >

              <div className="p-6">


                <div className="flex items-center justify-between">

                  <div>

                    <h2 className="text-lg font-semibold">
                      Recent Activity
                    </h2>

                    <p className="mt-1 text-xs text-white/30">
                      Latest controller events
                    </p>

                  </div>


                  <span className="text-[10px] uppercase tracking-wider text-white/20">
                    Live
                  </span>

                </div>



                <div className="mt-6 space-y-3">

                  {hasActivity ? (

                    <ActivityItem
                      title={lastButton}
                      detail="Latest controller event"
                    />

                  ) : (

                    <ActivityItem
                      title="No controller activity"
                      detail="Waiting for input events"
                    />

                  )}

                </div>

              </div>

            </BorderGlow>

          </div>

        </main>

      </div>

    </div>
  );
}



/* =============================================================
   STATUS CARD
============================================================= */

function StatusCard({
  title,
  value,
  detail,
  dot,
}) {

  return (

    <BorderGlow
      backgroundColor="#17181b"
      borderRadius={16}
      glowRadius={22}
      glowIntensity={0.65}
      coneSpread={22}
      colors={[
        "#38bdf8",
        "#c084fc",
        "#22c55e",
      ]}
      fillOpacity={0.12}
    >

      <div className="p-5">

        <div className="text-xs uppercase tracking-wider text-white/30">
          {title}
        </div>


        <div className="mt-3 flex items-center gap-2">

          <span
            className={`h-2.5 w-2.5 rounded-full ${dot}`}
          />

          <span className="text-base font-medium">
            {value}
          </span>

        </div>


        <div className="mt-1 text-xs text-white/30">
          {detail}
        </div>

      </div>

    </BorderGlow>

  );
}



/* =============================================================
   CONNECTION ITEM
============================================================= */

function ConnectionItem({
  label,
  value,
}) {

  return (

    <div>

      <div className="text-[10px] uppercase tracking-wider text-white/25">
        {label}
      </div>

      <div className="mt-1.5 font-mono text-sm text-white/65">
        {value}
      </div>

    </div>

  );
}



/* =============================================================
   ACTIVITY ITEM
============================================================= */

function ActivityItem({
  title,
  detail,
}) {

  return (

    <div className="flex items-center gap-3 rounded-xl border border-white/[0.06] bg-white/[0.025] p-4">

      <div className="flex h-8 w-8 shrink-0 items-center justify-center rounded-full bg-white/[0.04]">

        <span className="h-2 w-2 rounded-full bg-green-400" />

      </div>


      <div className="min-w-0">

        <div className="text-sm text-white/50">
          {title}
        </div>

        <div className="mt-0.5 text-xs text-white/20">
          {detail}
        </div>

      </div>

    </div>

  );

}


export default Dashboard;