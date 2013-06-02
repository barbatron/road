root = this


class Tool
  constructor: () ->
    console.log "setting tool", @
    tools.current = @

class CommonTool extends Tool
  constructor: () ->
    super()
    layers.tool.clear()
  over: (ent, e) ->
    if ent instanceof ents.Node
      shortest = 9007199254740992
      selected = null
      for handle in ent.handels
        dist = P(e).distance(handle.pos)
        if dist < shortest
          selected = handle
          shortest = dist
      new RoadTool(selected)

class RoadTool extends Tool
  constructor: (@handle = null) ->
    super()
    @endNode = null

  click: (e) =>
    if @curve?
      if @intersection?
        @endNode = ents.splitRoad(@intersection)
      layers.main.drawBeizer @curve
      nextHandle = ents.makeRoad(@handle, @curve.p3, @curve.p2, @curve, @endNode)
      tools.current = new RoadTool(nextHandle)

  over: (ent, e) ->
    if ent instanceof ents.Node
      console.log "ent", ent
      console.log "@handle", @handle
      curve = C.fromHandle @handle, ent.pos
      color = @check(curve)
      if color?
        @draw color
        @endNode = ent

  out: (ent, e) ->
    if ent instanceof ents.Node
      @endNode = null

  move: (e) ->
    unless @endNode?
      curve = C.fromHandle @handle, P(e)
      @intersection = null
      if curve.length > 100
        intersection= @intersecting(curve)
        if intersection?
          @intersection = intersection
          curve = C.fromHandle @handle, P(intersection.p.x, intersection.p.y)
      @draw @check(curve)

  intersecting: (curve)->
    intersections = []
    for road in ents.roads
      if road.opt.curve?
        for inter in curve.getIntersections(road.opt.curve)
          inter.road = road
          intersections.push inter
    shortest = 9007199254740992
    selected = null
    asdf = null
    console.log "inters", intersections, curve.p0, curve.p3
    root.intersections = intersections
    for cross in intersections
      if cross?._point?
        cross.p = P(cross._point.x, cross._point.y)
        dist = P(cross._point.x, cross._point.y).distance(@handle.node.pos)
        continue if dist < 1
        if dist < shortest
          console.log shortest
          shortest = dist
          selected = cross
          asdf = cross
    console.log "intersection detected at", selected, asdf
    return selected

  check: (curve) ->
    angle = Math.abs L(curve.p0, curve.p1).signedAngle L(curve.p2, curve.p3)
    len = curveLen curve
    rad = (len*((2*Math.PI)/angle))/(2*Math.PI)
    if angle > Math.PI/2
      new SharpTurnTool(@handle)
    unless rad < 15 or L(curve.p1, curve.p2).length() > L(curve.p0, curve.p3).length()
      hue = 0
      for k,v of root.colorSpeed
        hue = Math.max v, hue if rad > new Number(k)
      color = "hsb(#{hue}, 0.9, 0.5)"
      @curve = curve
    console.log angle, len, rad, color
    return color

  draw: (color) ->
    layers.tool.clear()
    layers.tool.drawBeizer @curve, color if @curve?
    for edge in @handle.inverse.edges
      layers.tool["drawRoad#{edge.road.shape}"](edge.road, "rgba(255,30,30,0.5)")

  keyDown: (e) ->
    tools.current = new StraightRoadTool(@node) if e.which is 17

root.colorSpeed =
  15:	 0
  30:	 0.05
  55:	 0.10
  90:	 0.15
  135: 0.20
  195: 0.25
  250: 0.30
  335: 0.35
  435: 0.40
  560: 0.45
  755: 0.50

class SharpTurnTool extends Tool
  constructor: (@handle) ->
    super()

  click: (e) ->
    if @line?
      #layers.main.drawStraightRoad(@line)
      nextHandle = ents.makeRoad(@handle, @line.p1, @line.p0, null, @endNode)
      new RoadTool(nextHandle)

  move: (e) ->
    unless @endNode?
      curve = C.fromHandle @handle, P(e)
      @line = L(@handle.node.pos, P(e))
      @check(curve)
      @draw()

  over: (ent, e) ->
    if ent instanceof ents.Node
      curve = C.fromHandle @handle, ent.pos
      @line = L @handle.node.pos, ent.pos
      @check(curve)
      @endNode = ent
      @draw()

  out: (ent, e) ->
    if ent instanceof ents.Node
      @endNode = null

  check: (curve) ->
    angle = Math.abs L(curve.p0, curve.p1).signedAngle L(curve.p2, curve.p3)
    console.log "angle", angle
    if angle <= Math.PI/2
      unless  L(curve.p1, curve.p2).length() > L(curve.p0, curve.p3).length()
        new RoadTool(@handle)

  draw: () ->
    layers.tool.clear()
    layers.tool.drawStraightRoad(@line)


class StraightRoadTool extends Tool
  constructor: (@node = null) ->
    super()
  click: (e) ->
    line = @straightLineFromNode(@node, P(e))
    layers.main.drawLine line 
    node = new ents.Node line.p1, line.p0
    tools.current = new RoadTool(node)
  move: (e) ->
    layers.tool.clear()
    line = @straightLineFromNode(@node, P(e))        
    layers.tool.drawLine line
  straightLineFromNode: (node, pos) ->
    line = L(node.pos, node.ctrl).growAdd(1000)
    loc = jsBezier.nearestPointOnCurve(pos, @lineToBez(line)).location
    return L(node.pos, node.ctrl).growAdd(1000*loc)
  lineToBez: (l) ->
    return [
      {x: l.p0.x, y: l.p0.y}
      {x: l.p0.x, y: l.p0.y}
      {x: l.p1.x, y: l.p1.y}
      {x: l.p1.x, y: l.p1.y}
    ]
  keyUp: (e) ->
    tools.current = new RoadTool(@node) if e.which is 17



root.tools = {}
root.tools.RoadTool = RoadTool
root.tools.CommonTool = CommonTool

