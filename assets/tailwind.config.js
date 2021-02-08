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
        'nyra-pink': "#F44B65",
        'nyra-orange': "#E48D3D"
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
