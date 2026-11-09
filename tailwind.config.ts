import type { Config } from "tailwindcss";

const config: Config = {
  content: [
    "./pages/**/*.{js,ts,jsx,tsx,mdx}",
    "./components/**/*.{js,ts,jsx,tsx,mdx}",
    "./app/**/*.{js,ts,jsx,tsx,mdx}",
  ],
  theme: {
    extend: {
      colors: {
        brand: {
          50: "#fdf8f6",
          100: "#f2e8e5",
          500: "#8e5d52",
          600: "#74483f",
          700: "#5d3730",
          900: "#361f1b",
        },
        sand: {
          50: "#faf9f6",
          100: "#f5f3ef",
          200: "#e9e4db",
          300: "#d9d0c2",
          400: "#b5a894",
        }
      },
    },
  },
  plugins: [],
};
export default config;
