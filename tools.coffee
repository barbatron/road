root = this


class Tool
  constructor: () ->
    console.log "setting tool", @
    tools.current = @

class CommonTool extends Tool
  constructor: () ->
  over: (ent) ->
    if ent instanceof ents.Node
      new RoadTool ent

class RoadTool extends Tool
  constructor: (@node = null) ->
    super()
  click: (e) =>
    #if @endNode? then end = @endNode.pos else end = P(e)
    if @curve?
      layers.main.drawBeizer @curve
      @endNode = new ents.Node @curve.p3, @curve.p2# unless @endNode?
      tools.current = new RoadTool(@endNode)
  bezier: (end)->
    sta = @node.pos
    starg = @node.line.growAdd(L(sta,end).length()/2.5).p1
    mid = @node.pos.add(end).div(2)
    perp = L(@node.pos, end).perp().growAll(1000)#@node.pos.add(end).div(2))#line.growAdd(100)
    etarg = starg.mirror(perp)#V(end.x+((mid.x-end.x)/2), end.y+((mid.y-end.y)/2))
    layers.tool.drawDot starg, "#0F0"
    layers.tool.drawDot mid, "#00F"
    layers.tool.drawLine perp, "#0FF"
    layers.tool.drawDot etarg, "#F0F"
    return C({
      p0: sta
      p1: starg
      p2: etarg
      p3: end
    })
  over: (ent) ->
    if ent instanceof ents.Node
      layers.tool.clear()
      layers.tool.drawNode @node, true
      layers.tool.drawBeizer @bezier ent.pos
      @endNode = ent
  out: (ent) ->
    if ent instanceof ents.Node
      @endNode = null
  move: (e) ->
    unless @endNode?
      layers.tool.clear()
      layers.tool.drawNode @node, true
      curve = @bezier P(e)
      angle = Math.abs L(curve.p0, curve.p1).signedAngle L(curve.p2, curve.p3)
      len = curveLen curve
      if angle > Math.PI / 2
        steepness = 255
        color = "#333"
      else
        steepness = Math.max 0, ((0.028-(angle/len))*20)-.30
        green = 1 - steepness
        color = "hsb(#{steepness}, 0.9, 0.5)"
        @curve = curve
      console.log angle, steepness, len
      layers.tool.drawBeizer @curve, color if @curve?
  keyDown: (e) ->
    tools.current = new StraightRoadTool(@node) if e.which is 17


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
root.tools.current = new CommonTool()
root.tools.RoadTool = RoadTool

