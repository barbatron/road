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
    
    tools.current = @

class RoadTool extends Tool
  constructor: (@edge) ->

class NodeTool extends Tool
  constructor: (@edge, @point) ->
    super()
    if @edge? and @point?
      # Immediate node placement
      loc = @edge.curve().getLocationOf(@point)
      
      node = ents.splitEdge(@edge, loc.getParameter())
      new FreeEdgeTool(node)
      return

  move: (e) ->
    @point = P(e)    
    layers.tool.drawDot(@point, "rgba(100,100,200,0.6)")
  click: (e) ->
    return unless @point?
    node = new ents.Node(@point)
    new FreeEdgeTool(node)

class CommonTool extends Tool
  constructor: () ->
    super()
    layers.tool.clear()
    @node = null
    @selection = []

  click: (e) ->
    if @edge? and _.indexOf(@selection, @edge) == -1
      @selection.push(@edge)
      layers.selection.drawEdge @edge, "rgba(255,255,0,0.4)"  
    
  over: (ent, e) ->
    if ent instanceof ents.Node
      @node = ent
      
    if ent instanceof ents.Handle
      @handle = ent
      layers.handles.clear()
      for handle in ents.handels
        acc = handle.id == @handle.id
        layers.handles.drawHandle(handle, "#3b3", acc)

  move: (e) ->  
    @cursor = cursor = P(e)
    @point = @cursor
    layers.tool.clear()
    
    callback = (edgeDist) -> layers.tool.drawDot(edgeDist.point, "rgba(255,30,30,0.5)")
    snapPoint = new util.EdgeSnapper(@cursor, { callback: callback }).snap()

    snapPoint2 = new util.NodeSnapper(@cursor, { callback: (ns) ->
    #  
    }).snap()

    return unless snapPoint? or snapPoint2?
    
    point = snapPoint.point;
          
    if snapPoint2?.point 
      point = snapPoint2.point
      
    @edge = snapPoint.item
    @point = snapPoint.point
    @node = @edge?.nearestNode(@point)
    
    if @node?
      handleResult = new util.HandleSnapper(@cursor, { items: @node.handels  }).snap()
      if results?
        
        @handle = results.itemDist.selectedHandle
        layers.handles.clear()
        for handle in ents.handels
          acc = handle.id == @handle.id
          layers.handles.drawHandle(handle, "#3b3", acc)



    layers.tool.drawNode(@node, true) if @node?
    layers.tool.drawEdge(@edge, "rgba(255,30,30,0.5)") if @edge?

  keyDown: (e) ->
    
    keyBind =
      115: (e) -> #s
        
      101: (e) -> #e
        if @edge?
          new LeafTool @edge 
        else
          console.warn 'Unable to set leaf tool - no edge'
      119: (e) -> #w
        if @handle?
          new EdgeTool @handle 
        else
          console.warn 'Unable to set edge tool - no handle'
      97: (e) -> #a
        #if @point?
          new NodeTool @edge, @point 
        #else
          #console.warn 'Unable to set node tool - no point'
      
    handler = keyBind[e.which]
    keyBind[e.which]?.call(this, e)

class LeafTool extends Tool
  constructor: (@edge, @leaf1=null, @modifier=null) ->
    super()

  click: (e) ->
    if @rects.length > 0
      for rect in @rects
        leaf = new ents.Leaf(@edge, rect, @loc)
      for lot in @lots
        new ents.Lot(lot)
      new CommonTool()

  move: (e) ->
    layers.tool.clear()

    nearestLoc = @edge.curve().getNearestLocation(P(e).pa())
    return unless nearestLoc?

    point = @edge.curve().getPointAt(nearestLoc._parameter, true)
    normal = @edge.curve().getNormalAt(nearestLoc._parameter, true)
    tangent = @edge.curve().getTangentAt(nearestLoc._parameter, true)

    @loc = nearestLoc
    @modifier = @checkSide(P(e), P(point), normal)
    @rects = []

    curve = C(split(@edge.curve(), nearestLoc._parameter).left)
    curveLength = curve.getLength()

    n = @edge.curve().getLength()/curveLength
    n = Math.min(n,@edge.curve().getLength()/10)
    lotWidth = @edge.curve().getLength()/n
    @lots = []

    for i in [0..n]
      s = split @edge.curve(), ((1/n)*i)
      loc = @edge.curve().getNearestLocation(s.left.p3)

      point2 = @edge.curve().getPointAt(loc._parameter, true)
      normal2 = @edge.curve().getNormalAt(loc._parameter, true)
      tangent2 = @edge.curve().getTangentAt(loc._parameter, true)

      @modifier = @modifier * -1
      driveWay = @makeRect(point2, normal2, tangent2)

      distanceToStart = P(point2).distance(@edge.curve().p0)
      distanceToEnd = P(point2).distance(@edge.curve().p3)
      unless distanceToStart < lotWidth/2 or distanceToEnd < lotWidth/2
        @rects.push driveWay
        @lots.push @makeLot driveWay, lotWidth


    #@adjustLots(lots)

    for rect in @rects
      layers.tool.drawLeaf(rect, "#00FF00")
    #dist = @leaf1.pos.distance(@rect.p0)
    #@rect = @makeRect(point, normal, tangent)

  adjustLots: (lots) ->
    for lot in lots
      lot.path = new paper.Path()
      path.moveTo(lot.p0)
      path.lineTo(lot.p1)
      path.lineTo(lot.p2)
      path.lineTo(lot.p3)
      path.closePath()

    for lot1 in lots
      for lot2 in lots
        unless lot1 is lot2

          intersections = lot1.path.getIntersections(lot2)
          for intersection in intersections
            intersection.segment.point.linkTo = intersection.point


  makeLot: (driveWay, width) ->
    driveWay.tangent.length = width
    driveWay.normal.length = width*4

    height = 700/width

    pp0 = @edge.curve().getNearestLocation(driveWay.p0.add(P(driveWay.tangent)))
    pp1 = @edge.curve().getNearestLocation(driveWay.p0.sub(P(driveWay.tangent)))

    p0 = P(pp0._point)
    p1 = P(pp1._point)
    p2 = P(pp1._point).add(P(pp1.getNormal().setLength(height*@modifier)))
    p3 = P(pp0._point).add(P(pp0.getNormal().setLength(height*@modifier)))

    lot =
      p0: p0
      p1: p1
      p2: p2
      p3: p3
    layers.tool.drawLot(lot)

    return lot



  makeRect: (point, normal, tangent) ->
    offset = @edge.opt.width/2

    normal.length = (offset-1)*@modifier
    p0 = P(point).add(P(normal))

    if @modifier > 0
      normal.length = (offset+(5*@modifier))
    else
      normal.length = (offset-(5*@modifier))
    p1 = P(point).add(P(normal))

    tangent.length = 5
    p2 = p1.add(P(tangent))
    p3 = p0.add(P(tangent))

    return {
      p0: p0
      p1: p1
      p2: p2
      p3: p3
      tangent: tangent
      normal: normal
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



class FreeEdgeTool extends Tool
  constructor: (@node) ->
    super()
    @valid = false

  click: (e) ->
    if @valid
      new EdgeTool(new ents.Handle(@node, @line.p1))

  move: (e) ->
    
    @line = L(@node.pos, P(e))
    @valid = @node.validateHandle(@line)
    @draw()

  draw: () ->
    layers.tool.clear()
    layers.tool.drawLine(@line, 
      if @valid then "rgba(0,255,128,0.5)" else "rgba(255,128,128,0.5)")

class ContinousEdgeTool extends Tool
  # Projection forward - Edge
  # Dont snap to origin node - Edge
  # Symetical cubic beizers - Edge
  # Should snap to closes curves - Edge
  # Dont bend more than 45 degrees - Edge
  # Minimum 15 m radius - Edge
  # Should not intersect other roads - Edge
  # Abfharts should however be allowed - Edge/Node
  # Snapped and intersected edges should be cut - Factory
  # No edges closer than 20 meters to nodes (unless they are connected to those nodes) - Node
  # Snap to edge or node if this close - Edge/Node
  # No loops - Edge
  # No edges shorter than 20 meters - Edge
  # No double connections between nodes  - Edge/Node

  constructor: (@handle) ->
    super()

  move: (e) ->




class EdgeTool extends Tool
  constructor: (@handle) ->
    super()


    if @handle.edge?
      unless @handle.inverse.edge?
        @handle = @handle.inverse 
      else
        new FreeEdgeTool(@handle.node)
        return

    @endNode = null

  click: (e) =>
    if @curve?
      if @intersection? and not @endNode?
        
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
    # Check if distance to end node is too close
    if @endNode?
      if L(@endNode.pos, P(e)).length() > 10
        @endNode = null
      else
        return

    # Prevent backward curves
    point = P(e)
    if @isBackwardPoint(point)
      return

    # Prevent snapping to self
    snapPoint = @snap point
    if P(snapPoint.point).distance(@handle.node.pos) <= 10
      return


    try
      curve = C.fromHandle @handle, snapPoint.point
      @settle(curve)
      @draw()
    catch e 
      console.warn e
      console.warn "can not make curve from", point

  snap: (orig) ->
    location = 
      point: orig
    for edge in ents.edges
      nearestLocation = edge.curve().getNearestLocation(orig)
      continue unless nearestLocation?
      newPoint = P(edge.curve().getPointAt(nearestLocation.parameter, true))
      dist = newPoint.distance(orig)
      continue if newPoint.distance(@handle.node.pos) < 10
      if dist < 10
        if dist < closest or not closest?
          closest = dist
          location =
            point: newPoint
            edge: edge
            location: nearestLocation
    return location     

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
      for inter in curve.getIntersections(edge.curve())
        unless @intersectingPrevRoad(edge)
          inter.edge = edge
          inter.location = {}
          inter.location.parameter = edge.curve().getParameterOf(inter._point)
          intersections.push inter

    snapPoint = @snap curve.p3
    unless snapPoint.point == curve.p3
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
  
  isBackwardPoint: (point) ->
    fwdPos = @handle.pos
    invPos = @handle.inverse.pos
    nodePos = @handle.node.pos
    angle = @handle.line.angle(L(nodePos, point))
    return angle > 2 * Math.PI / 3

  check: (curve, skipBackward = false) ->
    isBackward = @isBackwardPoint(curve.p3)

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
      layers.tool.drawDot @curve.p1
      layers.tool.drawDot @curve.p2
      if @handle.inverse.edge?
        layers.tool.drawEdge(@handle.inverse.edge, "rgba(255,30,30,0.5)")



root.tools = {}
root.tools.EdgeTool = EdgeTool
root.tools.CommonTool = CommonTool
root.tools.LeafTool = LeafTool

