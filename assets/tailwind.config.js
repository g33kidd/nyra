module.exports = {
  purge: [
    '../lib/**/*.ex',
    '../lib/**/*.leex',
    '../lib/**/*.eex',
    './js/**/*.js'
  ],
  darkMode: false, // or 'media' or 'class'
  theme: {
    extend: {
      colors: {
        nyra: {
          sw: {
            50: "#F5E8EB",
            100: "#A76E7F"
          },
          pink: {
            50: "#FFE4E5",
            100: "#F44B65",
            200: "#CE4A88",
            300: "#9A5398",
            400: "#635791"
          },
          orange: {
            100: "#E48D3D",
          },
          blue: {
            50: "#59BAB8",
            100: "#3A5379",
            200: "#2F4858"
          },
        },
        'nyra-pink': "#F44B65",
        'nyra-orange': "#E48D3D",
      },
      fontFamily: {
        'slab': ['Roboto Slab', 'sans-serif'],
        'roboto': ['Roboto', 'sans-serif'],
        'condensed': ['Roboto Condensed', 'sans-serif'],
        'montserrat': ['Montserrat', 'sans-serif']
      },
    },
  },
  variants: {
    extend: {},
  },
  plugins: [],
}
