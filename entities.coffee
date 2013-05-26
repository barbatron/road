root = this

class Node
  constructor: (@pos, @target) ->
    @line = L(@target, @pos)
    console.log @line
    @ctrl = @line.growAdd(50).p1
    
    root.nodes[@pos.x] = [] unless nodes[@pos.x]?
    root.nodes[@pos.x][@pos.y] = this
    layers.node.drawNode(@)
    layers.nodeSnap.addNodeSnapper(@)
  over: () ->
    tools.current.over?(@)
    layers.tool.drawNode(@, true)
    console.log "in", this
  out: () ->
    tools.current.out?(@)
    layers.tool.clear()
    console.log "out", this


root.ents = {}
root.ents.Node = Node

