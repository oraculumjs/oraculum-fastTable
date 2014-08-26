define [
  'oraculum'
  'cs!libs'
  'text!ft/README.md'
  'text!ft/examples/gh-pages/markdown/home-demo.md'
  'text!ft/examples/gh-pages/markdown/how-to-get-it.md'
], (Oraculum, stub, files...) ->

  return Oraculum.get('concatTemplate') files...
