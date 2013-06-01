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
  click: (e) =>
    #if @endNode? then end = @endNode.pos else end = P(e)
    if @curve?
      layers.main.drawBeizer @curve
      #@endNode = new ents.Node @curve.p3, @curve.p2# unless @endNode?
      nextHandle = ents.makeRoad(@handle, @curve.p3, @curve.p2, @curve )
      tools.current = new RoadTool(nextHandle)

  over: (ent, e) ->
    if ent instanceof ents.Node
      layers.tool.clear()
      #layers.tool.drawNode @node, true
      layers.tool.drawBeizer @bezier ent.pos
      @endNode = ent
  out: (ent, e) ->
    if ent instanceof ents.Node
      @endNode = null
  move: (e) ->
    unless @endNode?
      layers.tool.clear()
      #layers.tool.drawNode @node, true
      curve = C.fromHandle @handle, P(e)

      angle = Math.abs L(curve.p0, curve.p1).signedAngle L(curve.p2, curve.p3)

      len = curveLen curve
      rad = (len*((2*Math.PI)/angle))/(2*Math.PI)
      #steepness = Math.max 0, ((0.028-(angle/len))*20)-.30
      color = "#333"
      if angle > Math.PI/2
        new SharpTurnTool(@handle)
      else if rad < 15 or L(curve.p1, curve.p2).length() > L(curve.p0, curve.p3).length()
        color = "#333"
      else
        hue = 0
        for k,v of root.colorSpeed
          hue = Math.max v, hue if rad > new Number(k)
        color = "hsb(#{hue}, 0.9, 0.5)"
        @curve = curve
      console.log angle, len, rad, color
      layers.tool.drawBeizer @curve, color if @curve?
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
      nextHandle = ents.makeRoad(@handle, @line.p1, @line.p0)
      new RoadTool(nextHandle)
  move: (e) ->
    curve = C.fromHandle @handle, P(e)
    angle = Math.abs L(curve.p0, curve.p1).signedAngle L(curve.p2, curve.p3)
    console.log "angle", angle
    if angle <= Math.PI/2
      unless  L(curve.p1, curve.p2).length() > L(curve.p0, curve.p3).length()
        new RoadTool(@handle)
    @line = L(@handle.node.pos, P(e))
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

