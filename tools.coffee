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
  click: () ->
    if @closestEdge?
      new LeafTool @closestEdge
    ###
    if @closestHandle?
      new EdgeTool @closestHandle
    ###
  over: (ent, e) ->
    if ent instanceof ents.Node
      @node = ent
  move: (e) ->
    if @node?
      point = P(e)
      edges = []
      shortest = null
      layers.tool.clear()
      for handle in @node.handels
        for edge in handle.edges
          nearestPoint = edge.curve.getNearestPoint(point)
          break unless nearestPoint?
          nearestPoint = P nearestPoint
          dist = point.distance(nearestPoint)
          layers.tool.drawDot(nearestPoint, "rgba(255,30,30,0.5)")
          if dist < shortest or not shortest?
            shortest = dist
            @closestEdge = edge
            if edge.from.node is @node
              @closestHandle = edge.from.inverse
            else
              @closestHandle = edge.to.inverse
      if @closestEdge?
        layers.tool.drawRoad(@closestEdge, "rgba(255,30,30,0.5)")

  keyDown: (e) ->
    console.log(@node) if e.which is 119

class LeafTool extends Tool
  constructor: (@edge, @leaf1=null, @modifier=null) ->
    super()

  click: (e) ->
    if @rect?
      leaf = new ents.Leaf(@edge, @rect, @parameter)
      new LeafTool(@edge, leaf, @modifier)

  move: (e) ->
    layers.tool.clear()
    nearestLoc = @edge.curve.getNearestLocation(P(e))
    return unless nearestLoc?
    nearestLoc.parameter = @edge.curve.getParameterAt(nearestLoc._distance)
    point = @edge.curve.getPointAt(nearestLoc.parameter, true)
    normal = @edge.curve.getNormalAt(nearestLoc.parameter, true)
    tangent = @edge.curve.getTangentAt(nearestLoc.parameter, true)
    @parameter = nearestLoc.parameter
    if @leaf1?
      @checkSide(P(e), P(point), normal)
      @rect = @makeRect(point, normal, tangent)
      diff = @leaf1.parameter - @parameter
      nearestLoc.parameter += diff
      point = @edge.curve.getPointAt(nearestLoc.parameter, true)
      normal = @edge.curve.getNormalAt(nearestLoc.parameter, true)
      tangent = @edge.curve.getTangentAt(nearestLoc.parameter, true)
      rect = @makeRect(point, normal, tangent)
      layers.tool.drawLeaf(rect)
      #dist = @leaf1.pos.distance(@rect.p0)
      #@rect = @makeRect(point, normal, tangent)
    else
      @modifier = @checkSide(P(e), P(point), normal)
      @rect = @makeRect(point, normal, tangent)
    layers.tool.drawLeaf(@rect)

  makeRect: (point, normal, tangent) ->
    normal.length = ((@modifier*(@edge.opt.width/2))-(@modifier*1))
    p0 = P(point).add(P(normal))

    normal.length = @modifier*((@modifier*(@edge.opt.width/2))+(@modifier*5))
    p1 = p0.add(P(normal))

    tangent.length = 5
    p2 = p1.add(P(tangent))
    p3 = p0.add(P(tangent))

    return {
      p0: p0
      p1: p1
      p2: p2
      p3: p3
    }


  checkSide: (mousePos, point, normal) ->
    normal.length = 5
    upperNormal = P(normal)
    uppperDist = mousePos.distance(point.add(upperNormal))
    normal.length = -5
    lowerNormal = P(normal)
    lowerDist = mousePos.distance(point.add(lowerNormal))
    if uppperDist < lowerDist
      return -1
    else
      return 1





class EdgeTool extends Tool
  constructor: (@handle = null) ->
    super()
    @endNode = null

  click: (e) =>
    if @curve?
      if @intersection? and not @endNode?
        console.log "splitting at", @intersection
        @endNode = ents.splitRoad(@intersection)
      nextHandle = ents.makeRoad(@handle, @curve, @endNode, @continous)
      tools.current = new EdgeTool(nextHandle)

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
    point = P(e)
    snapPoint = @snap(point)
    point = snapPoint.point if snapPoint?
    curve = C.fromHandle @handle, point
    @settle(curve)
    @draw()

  snap: (orig) ->
    location = null
    for edge in ents.edges
      nearestLocation = edge.curve.getNearestLocation(orig)
      continue unless nearestLocation?
      newPoint = P(edge.curve.getPointAt(nearestLocation.parameter, true))
      dist = newPoint.distance(orig)
      if dist < 10
        if dist < closest or not closest?
          closest = dist
          location =
            point: newPoint
            edge: edge
            location: nearestLocation
    if location?
      return location
    else
      return null

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
    if @curve? and curveLen(@curve) < 20
      @curve = null

    # Don't make edges between already conneted nodes
    if @endNode?
      for edge1 in @handle.node.edges()
        for edge2 in @endNode.edges()
          if edge1.same(edge2)
            @curve = null
            @endNode = null
            break
        break unless @curve?

  intersectingNode: (curve) ->
    @endNode = null

    selected = null
    for node in ents.nodes
      continue if node is @handle.node
      point = @curve.getNearestPoint(node.pos)
      distPntToNode = L(point, node.pos).length()
      if distPntToNode < 20
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
    for edge in ents.edges
      for inter in curve.getIntersections(edge.curve)
        unless @intersectingPrevRoad(edge)
          inter.edge = edge
          inter.location = {}
          inter.location.parameter = edge.curve.getParameterOf(inter._point)
          intersections.push inter

    snapPoint = @snap curve.p3
    if snapPoint?
      snapPoint._point = new paper.Point(snapPoint.point)
      intersections.push snapPoint

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

  intersectingPrevRoad: (otherEdge) ->
    for edge in @handle.node.edges()
      if edge is otherEdge
        return true
    return false



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
      new EdgeTool(@handle.inverse)

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
        layers.tool.drawRoad(edge, "rgba(255,30,30,0.5)")



root.tools = {}
root.tools.EdgeTool = EdgeTool
root.tools.CommonTool = CommonTool

