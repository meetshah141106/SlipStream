import { useEffect, useState } from "react";

function ThemeToggle() {
  const [dark, setDark] = useState(() => {
    const saved = localStorage.getItem("slipstream-theme");

    if (saved) {
      return saved === "dark";
    }

    return true;
  });

  useEffect(() => {
    const root = document.documentElement;

    if (dark) {
      root.classList.add("dark");
      root.style.colorScheme = "dark";
      localStorage.setItem("slipstream-theme", "dark");
    } else {
      root.classList.remove("dark");
      root.style.colorScheme = "light";
      localStorage.setItem("slipstream-theme", "light");
    }
  }, [dark]);

  return (
    <div className="flex items-center rounded-full border border-white/10 bg-white/[0.04] p-1 text-xs">
      <button
        onClick={() => setDark(false)}
        className={`rounded-full px-3 py-1.5 transition ${
          !dark
            ? "bg-white text-black"
            : "text-white/35 hover:text-white/60"
        }`}
      >
        Light
      </button>

      <button
        onClick={() => setDark(true)}
        className={`rounded-full px-3 py-1.5 transition ${
          dark
            ? "bg-white/10 text-white"
            : "text-black/40 hover:text-black/70"
        }`}
      >
        Dark
      </button>
    </div>
  );
}

export default ThemeToggle;