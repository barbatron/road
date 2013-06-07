root = this


colorSpeed =
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
      if @intersection? and not @endNode?
        @endNode = ents.splitRoad(@intersection)
      layers.main.drawBeizer @curve
      nextHandle = ents.makeRoad(@handle, @curve, @endNode)
      tools.current = new RoadTool(nextHandle)

  over: (ent, e) ->
    if ent instanceof ents.Node
      if ent is @handle.node
        return
      curve = C.fromHandle @handle, ent.pos
      @settle(curve)

      #if ent is @intersection.road.edge.from.node or ent is @intersection.road.edge.to.node
      #  @endNode = ent
      #  @intersection = null

      @draw()

  out: (ent, e) ->
    if ent instanceof ents.Node
      @endNode = null

  move: (e) ->
    if @endNode?
      if L(@endNode.pos, P(e)).length() > 10
        @endNode = null
      else
        return
    if P(e).distance(@handle.node.pos) <= 0
      return
    curve = C.fromHandle @handle, P(e)
    @settle(curve)
    @draw()

  settle: (curve) ->
    @check(curve)
    @intersection = null
    @endNode = null
    if @curve?
      iteration = 0
      unsettled = true
      while unsettled
        curve = @curve
        # Let road intersection tool decide a curve
        curve = @intersecting(curve)
        @check(curve, true) if curve?
        intersectingRoadLength = curveLen @curve

        # Check if the suggested curve crosses any nodes
        curve = @intersectingNode(curve)
        @check(curve, true) if curve?
        intersectingNodeLength = curveLen @curve

        # An agreement on both rules can be assumed of both
        # reders a curve of same length
        if intersectingNodeLength == intersectingRoadLength
          unsettled = false

        # If we're in unending dispute don't suggest a road.
        iteration++
        if iteration > 16
          console.warn "Can't settle, let's agree to disagree"
          @curve = null
          unsettled = false

    # Don't draw roads upon themselves.
    if @endNode is @handle.node
      @curve = null

    # Don't make too short roads
    if @curve? and curveLen(@curve) < 10
      @curve = null

  intersectingNode: (curve) ->
    @endNode = null

    selected = null
    for node in ents.nodes
      continue if node is @handle.node
      point = @curve.getNearestPoint(node.pos)
      distPntToNode = L(point, node.pos).length()
      if distPntToNode < 10
        distFromCurveStart = L(@handle.node.pos, point).length()
        if distFromCurveStart < shortest or not shortest?
          selected = node
          shortest = distFromCurveStart
    if selected?
      @endNode = selected
      return C.fromHandle @handle, selected.pos
    else
      return null

  intersecting: (curve)->
    @intersection = null

    # Find all intersections
    intersections = []
    for road in ents.roads
      if road.curve?
        for inter in curve.getIntersections(road.curve)
          inter.road = road
          intersections.push inter

    # Find intersection closest to start node
    selected = null
    for cross in intersections
      if cross?._point?
        cross.p = P(cross._point.x, cross._point.y)
        dist = P(cross._point.x, cross._point.y).distance(@handle.node.pos)
        continue if dist < 1
        if dist < shortest or not shortest?
          shortest = dist
          selected = cross

    # If closest found make a new curve
    if selected?
      pos = P(selected.p.x, selected.p.y)
      @intersection = selected
      return C.fromHandle @handle, pos
    else
      return null

  color: () ->
    hue = 0
    for k,v of colorSpeed
      hue = Math.max v, hue if @rad > new Number(k)
    return "hsb(#{hue}, 0.9, 0.5)"

  check: (curve, skipBackward = false) ->
    isBackward = L(curve.p1, curve.p2).length() > L(curve.p0, curve.p3).length()

    # Check if angle is too steep to make a countinous curve
    angle = Math.abs L(curve.p0, curve.p1).signedAngle L(curve.p2, curve.p3)
    if angle > Math.PI/2 or (skipBackward and isBackward)
      @curve = L(@handle.node.pos, curve.p3).toCurve()
      @rad = 99999
      @continous = false
      return

    # Check if the curve should be reversed
    if isBackward
      new RoadTool(@handle.inverse)

    # It seems ok to make a curve, lets cache the radius
    len = curveLen curve
    @rad = (len*((2*Math.PI)/angle))/(2*Math.PI)
    if @rad > 15 # or L(curve.p1, curve.p2).length() > L(curve.p0, curve.p3).length()
      @curve = curve
      @continous = true


  draw: () ->
    if @curve?
      layers.tool.clear()
      layers.tool.drawBeizer @curve, @color()
      for edge in @handle.inverse.edges
        layers.tool.drawRoad(edge.road, "rgba(255,30,30,0.5)")

  keyDown: (e) ->
    tools.current = new StraightRoadTool(@node) if e.which is 17


class SharpTurnTool extends Tool
  constructor: (@handle) ->
    super()

  click: (e) ->
    if @line?
      #layers.main.drawStraightRoad(@line)
      nextHandle = ents.makeRoad(@handle, @line.toCurve(), @endNode)
      new RoadTool(nextHandle)

  move: (e) ->
    unless @endNode?
      curve = C.fromHandle @handle, P(e)
      @line = L(@handle.node.pos, P(e))
      @check(curve)
      @draw()

  over: (ent, e) ->
    if ent instanceof ents.Node
      if ent is @handle.node
        return
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

