root = this

class Node
  constructor: (@pos, target=null) ->
    @handels = []
    new Handle(@, target) if target?
    #root.nodes[@pos.x] = [] unless nodes[@pos.x]?
    #root.nodes[@pos.x][@pos.y] = this
    layers.node.drawNode(@)
    layers.nodeSnap.addNodeSnapper(@)
  addHandle: (handle) ->
    if @handels.indexOf handle is -1
      @handels.push handle
      @handels.push handle.inverse
    return handleqqqqqq
  over: (e) ->
    tools.current.over?(@, e)
    #layers.tool.drawNode(@, true)
    console.log "in", this
  out: (e) ->
    tools.current.out?(@, e)
    layers.tool.clear()
    console.log "out", this

class Handle
  constructor: (@node, @pos, @inverse = null) ->
    @line = L(@node.pos,@pos)
    console.log @node, @pos
    @edges = []
    unless @inverse?
      #mirrTarg = @pos.mirror(@line.perp())
      @inverse = new Handle(@node, @line.grow(-1).p1, @)
    @draw()
    @node.addHandle(@)
  draw: ->
    layers.main.drawHandle(@)
  addEdge: (edge)->
    @edges.push edge

class Edge
  constructor: (@from, @to) ->
    @line = L(@from.node.pos,@to.node.pos)
    @from.addEdge(@)
    @to.addEdge(@)

class Road
  defaults =
    color: "#777"
  constructor: (@edge, @shape, @opt) ->
    @opt = _.defaults(@opt, defaults)
    @draw()
  draw: () ->
    layers.main["drawRoad#{@shape}"](@)


makeRoad = (oldHandle, end, target, curve=null) ->
  newNode = new Node(end)
  newHandle = new Handle(newNode, target)
  edge = new Edge(oldHandle, newHandle)
  if curve? then shape="Curve" else shape="Line"
  new Road(edge, shape, {curve: curve})
  return newHandle.inverse

root.ents = {}
root.ents.makeRoad = makeRoad
root.ents.Node = Node
root.ents.Handle = Handle
#root.nodes = []
