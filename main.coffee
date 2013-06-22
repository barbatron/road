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
    $(window).keypress (e) -> 
      if e.which is 113
        new tools.CommonTool()
      tools.current.keyDown?.call(tools.current, e)

    # Debug stuff goes here
    node = new ents.Node(P(100,100))
    handle = new ents.Handle(node, P(150, 100))
    curve = C
      p0: P(100,100)
      p1: P(150,100)
      p2: P(200,150)
      p3: P(200,200)
    ents.makeRoad(handle, curve)

    new tools.CommonTool()