root = this

req = 
  0: [
    'geometry'
    'paper'
    'tools'
    'entities'
  ]
  1:[
    'raphael'
  ]
  2:[
    'layers'
  ]

r = requirejs
r req[0], ->

  #root.P = (x,y)->
  #  new paper.Point(x,y)

  #root.L = (p0,p1)->
  #  new paper.Path.Line(p0,p1)

  #root.geom =
  #  getDirection: (line) ->
  #    d = line.lastSegment.point.subtract(line.firstSegment.point) # Vector2
  #    d.normalize()

  #  growAdd: (line, amount) ->
  #    #v = @getDirection()
  #    v = geom.getDirection(line)# line.lastSegment.point.getDirectedAngle(line.firstSegment.point)
  #    console.log "amount", amount
  #    console.log "v", v.angle
  #    console.log line.lastSegment.point
  #    root.poi = line.lastSegment.point
  #    x = Math.sin(v.angle)*amount
  #    y = Math.cos(v.angle)*amount
  #    np1 = line.lastSegment.point.add(P(x,y))
  #    console.log np1
  #    L line.firstSegment.point, np1

  #  getAngleLine: (line) ->
  #    line.getLastSegment().point.getDirectedAngle(line.getFirstSegment().point)

  #  getAngle: (p0, p1) ->
  #    p0.getDirectedAngle(p1)

  r req[1], -> r req[2], ->

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

