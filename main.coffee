root = this

req = 
  0: [
    './node_modules/straightcurve/lib/arc2'
    './node_modules/straightcurve/lib/vector2'
    './node_modules/straightcurve/lib/vertex2'
    './node_modules/straightcurve/lib/line2'
    './node_modules/straightcurve/lib/circle2'
    './node_modules/straightcurve/lib/line2'
    'tools'
    'entities'
  ]
  1:[
    './node_modules/straightcurve/lib/distancer'
    'raphael'
  ]
  2:[
    'layers'
  ]

r = requirejs
r req[0], -> r req[1], -> r req[2], ->
  $("#nodeSnap").click (e) -> tools.current.click?(e)
  $("#nodeSnap").mousemove (e) -> tools.current.move?(e)

  # Debug stuff goes here
  new ents.Node(P(100,80),P(100,10))
  new ents.Node(P(151,194),P(115,198))


hotkeys = {}
$(window).keypress (e) ->
  console.log e.which
  hotkeys[event.which]?()
registerHotkey = (key, func) ->
  hotkeys[key] = func

registerHotkey 49, -> window.currentTool = new NodeTool() # 1
registerHotkey 50, -> window.currentTool = new BezierTool() # 2
registerHotkey 113, -> window.currentTool = new NodeTool() # 2

