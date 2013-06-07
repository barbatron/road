root = this

redrawAll = () ->
  layers.main.clear()
  entityTypes = [ents.roads, ents.nodes, ents.handels]
  for entityType in entityTypes
    for ent in entityType
      ent.draw()

class Node
  constructor: (@pos, target=null) ->
    @handels = []
    new Handle(@, target) if target?
    #root.nodes[@pos.x] = [] unless nodes[@pos.x]?
    #root.nodes[@pos.x][@pos.y] = this
    layers.nodeSnap.addNodeSnapper(@)
    @draw()
    ents.nodes.push this
  addHandle: (handle) ->
    if @handels.indexOf handle is -1
      @handels.push handle
      @handels.push handle.inverse
    return handle
  draw: ->
    layers.main.drawNode(@)
  over: (e) ->
    tools.current.over?(@, e)
    #layers.tool.drawNode(@, true)
  out: (e) ->
    tools.current.out?(@, e)
    layers.tool.clear()

class Handle
  constructor: (@node, @pos, @inverse = null) ->
    @line = L(@node.pos,@pos)
    @edges = []
    unless @inverse?
      #mirrTarg = @pos.mirror(@line.perp())
      @inverse = new Handle(@node, @line.grow(-1).p1, @)
    @draw()
    @node.addHandle(@)
    ents.handels.push this
  draw: ->
    layers.main.drawHandle(@)
  addEdge: (edge)->
    @edges.push edge
  removeEdge: (edge)->
    @edges = _.without(edge)

class Edge
  constructor: (@from, @to) ->
    @line = L(@from.node.pos,@to.node.pos)
    @from.addEdge(@)
    @to.addEdge(@)
  addRoad: (road) -> @road = road
  destroy: () ->
    @road.destroy()

class Road
  defaults =
    color: "#777"
  constructor: (@edge, @curve) ->
    @opt = _.defaults(defaults)
    @edge.addRoad(@)
    @elem = @draw()
    ents.roads.push this
  draw: () ->
    layers.main.drawRoad(@)
  destroy: () ->
    #layers.main.remove(@elem.id)
    #@elem.parent.removeChild(@elem);
    #@elem.remove()
    #root.e = @elem
    ents.roads = _.without ents.roads, @
    redrawAll()


makeRoad = (oldHandle, curve, newNode=null) ->
  newNode = new Node(curve.p3) unless newNode?
  newHandle = new Handle(newNode, curve.p2)
  edge = new Edge(oldHandle, newHandle)
  #if curve? then shape="Curve" else shape="Line"
  new Road(edge, curve)
  return newHandle.inverse

splitRoad = (intersection) ->
  edgeToSplit = intersection.road.edge
  curveToSplit = intersection.road.curve
  intersectionPoint = intersection._point
  param = curveToSplit.getParameterOf(intersectionPoint)
  curves = split curveToSplit, param


  newNode =   new Node curves.left.p3
  handleIn =  new Handle newNode, curves.left.p1, "later"
  handleOut = new Handle newNode, curves.right.p2, "later"
  handleIn.inverse = handleOut
  handleOut.inverse = handleIn

  edge1 = new Edge edgeToSplit.from, handleIn
  curve = C
    p0: edgeToSplit.from.node.pos
    p1: curves.left.p2
    p2: handleIn.pos
    p3: newNode.pos
  new Road(edge1, curve)

  edge2 = new Edge handleOut, edgeToSplit.to
  curve = C
    p0: newNode.pos
    p1: handleOut.pos
    p2: curves.right.p1
    p3: edgeToSplit.to.node.pos
  new Road(edge2, curve)

  edgeToSplit.to.removeEdge(edgeToSplit)
  edgeToSplit.from.removeEdge(edgeToSplit)

  edgeToSplit.destroy()

  return newNode

root.test = () ->
  c = C
    p0: P(0,0)
    p1: P(50,0)
    p2: P(100,50)
    p3: P(100,100)

  console.log split(c,0.5)



root.ents = {}
root.ents.makeRoad = makeRoad
root.ents.splitRoad = splitRoad
root.ents.Node = Node
root.ents.Handle = Handle
root.ents.roads = []
root.ents.nodes = []
root.ents.handels = []
