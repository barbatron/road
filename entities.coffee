root = this

class Node
  constructor: (@pos, @target) ->
    @handels = [@target]
    @line = L(@target, @pos)
    @ctrl = @line.growAdd(50).p1    
    root.nodes[@pos.x] = [] unless nodes[@pos.x]?
    root.nodes[@pos.x][@pos.y] = this
    layers.node.drawNode(@)
    layers.nodeSnap.addNodeSnapper(@)
  addHandle: () ->
    
  over: () ->
    tools.current.over?(@)
    layers.tool.drawNode(@, true)
    console.log "in", this
  out: () ->
    tools.current.out?(@)
    layers.tool.clear()
    console.log "out", this

class Edge
  constructor: (@from, @to) ->
    @line = L(@from.pos,@to.pos)

class Road
  defaults =
    color: "#777"
  constructor: (@edge, @shape, @opt) ->
    @opt = _.defaults(@opt, defaults)
    @draw()
  draw: () ->
    layer.main["drawRoad#{@shape}"](@)


root.ents = {}
root.ents.Node = Node
root.nodes = []
