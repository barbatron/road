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
    if @endNode? then end = @endNode.pos else end = P(e)
    bezier = @bezier end
    layers.main.drawBeizer bezier
    @endNode = new ents.Node bezier.p3, bezier.p2 unless @endNode?
    tools.current = new RoadTool(@endNode)
  bezier: (end)->
    sta = @node.pos
    mid = @node.line.growAdd(100).p1
    starg = @node.ctrl
    etarg = V(end.x+((mid.x-end.x)/2), end.y+((mid.y-end.y)/2))
    layers.tool.drawDot starg, "#0F0"
    layers.tool.drawDot mid
    layers.tool.drawDot etarg, "#F0F"
    return {
      p0: sta
      p1: starg
      p2: etarg
      p3: end
    }
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
      layers.tool.drawBeizer @bezier P(e)
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

