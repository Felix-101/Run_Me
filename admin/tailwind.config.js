/** @type {import('tailwindcss').Config} */
export default {
  content: ["./index.html", "./src/**/*.{ts,tsx}"],
  theme: {
    extend: {
      colors: {
        runme: {
          bg: "#050505",
          surface: "#0c0c0c",
          card: "#121212",
          raised: "#161616",
          border: "rgba(255, 255, 255, 0.06)",
          muted: "#737373",
          subtle: "#a3a3a3",
          accent: "#ccff00",
          "accent-hover": "#b8e600",
          danger: "#ff4d6a",
          warning: "#fbbf24",
          glow: "rgba(204, 255, 0, 0.12)"
        }
      },
      boxShadow: {
        neon: "0 0 24px rgba(204, 255, 0, 0.08)",
        card: "0 4px 24px rgba(0, 0, 0, 0.45)"
      },
      fontFamily: {
        display: ['"DM Sans"', "system-ui", "sans-serif"]
      }
    }
  },
  plugins: []
};

