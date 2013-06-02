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
    return handle
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
  removeEdge: (edge)->
    @edges = _.without(edge)

class Edge
  constructor: (@from, @to) ->
    @line = L(@from.node.pos,@to.node.pos)
    @from.addEdge(@)
    @to.addEdge(@)
  addRoad: (road) -> @road = road

class Road
  defaults =
    color: "#777"
  constructor: (@edge, @shape, @opt) ->
    @opt = _.defaults(@opt, defaults)
    @edge.addRoad(@)
    @draw()
    ents.roads.push this
  draw: () ->
    layers.main["drawRoad#{@shape}"](@)


makeRoad = (oldHandle, end, target, curve=null, newNode=null) ->
  newNode = new Node(end) unless newNode?
  newHandle = new Handle(newNode, target)
  edge = new Edge(oldHandle, newHandle)
  if curve? then shape="Curve" else shape="Line"
  new Road(edge, shape, {curve: curve})
  return newHandle.inverse

splitRoad = (intersection) ->
  edgeToSplit = intersection.road.edge
  curveToSplit = intersection.road.opt.curve
  intersectionPoint = intersection._point
  console.log "intersectionpoint", intersectionPoint
  param = curveToSplit.getParameterOf(intersectionPoint)
  console.log "param", param
  curves = split curveToSplit, param

  ###
  firstPoint =    new paper.Point(c1.p0.x, c1.p0.y)
  handleIn =      new paper.Point(c1.p1.x, c1.p1.y)
  secondPoint =   new paper.Point(c1.p3.x, c1.p1.y)
  handleOut =     new paper.Point(c1.p2.x, c1.p2.y)
  firstSegment =  new paper.Segment(firstPoint, han+leOut)
  root.path2000 = new paper.Path(firstSegment, secondSegment)
  path = path2000.split(intersection._point)#.road.opt.curve.split(intersection)
  ###

  console.log "curves", curves

  newNode =   new Node curves.left.p3
  handleIn =  new Handle newNode, curves.left.p2, "later"
  handleOut = new Handle newNode, curves.right.p1, "later"
  handleIn.inverse = handleOut
  handleOut.inverse = handleIn

  edge1 = new Edge edgeToSplit.from, handleIn
  curve = C
    p0: edgeToSplit.from.node.pos
    p1: edgeToSplit.from.pos
    p2: handleIn.pos
    p3: newNode.pos
  new Road(edge1, edgeToSplit.road.shape, {curve: curve})

  edge2 = new Edge handleOut, edgeToSplit.to
  curve = C
    p0: newNode.pos
    p1: handleOut.pos
    p2: edgeToSplit.to.pos
    p3: edgeToSplit.to.node.pos
  new Road(edge2, edgeToSplit.road.shape, {curve: curve})

  edgeToSplit.to.removeEdge(edgeToSplit)
  edgeToSplit.from.removeEdge(edgeToSplit)

  root.roads = _.without(edgeToSplit.road)

  return newNode



root.ents = {}
root.ents.makeRoad = makeRoad
root.ents.splitRoad = splitRoad
root.ents.Node = Node
root.ents.Handle = Handle
root.ents.roads = []
