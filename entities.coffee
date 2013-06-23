root = this

class Entity
  constructor: () ->
    @id = _.uniqueId()

class Node extends Entity
  constructor: (@pos, target=null) ->
    super()
    @handels = []
    new Handle(this, target) if target?
    #root.nodes[@pos.x] = [] unless nodes[@pos.x]?
    #root.nodes[@pos.x][@pos.y] = this
    layers.nodeSnap.addNodeSnapper(this)
    @draw()
    ents.nodes.push this
  addHandle: (handle) ->
    if @handels.indexOf handle is -1
      @handels.push handle
    return handle
  draw: ->
    layers.main.drawNode(this)
  over: (e) ->
    tools.current.over?(this, e)
    #layers.tool.drawNode(@, true)
  out: (e) ->
    tools.current.out?(this, e)
    layers.tool.clear()
  edges: ->
    return _.pluck @handles, "edge"

class Handle  extends Entity
  constructor: (@node, @pos, @inverse = null) ->
    super()
    @line = L(@node.pos,@pos)
    #@edges = []
    unless @inverse?
      #mirrTarg = @pos.mirror(@line.perp())
      @inverse = new Handle(@node, @line.grow(-1).p1, this)
    @draw()
    @node.addHandle(this)
    ents.handels.push this
  updatePos: (pos) ->
    @pos = pos
    @line = L(@node.pos,@pos)
    @draw()
  draw: ->
    layers.main.drawHandle(@)
  addEdge: (edge)->
    unless edge instanceof Edge
      console.error("wtf mate!")
      console.stack()
      throw new Error("HEY!")
    @edge = edge
  removeEdge: (edge)->
    @edge = null if @edge is edge
    #@edges.splice(@edges.indexOf(edge), 1)

class Edge extends Entity
  defaults =
    color: "#777"
    width: 7
  constructor: (@from, @to) ->
    super()
    @opt = _.defaults(defaults)
    @line = L(@from.node.pos,@to.node.pos)
    @from.addEdge(this)
    @to.addEdge(this)
    @draw()
    ents.edges.push this
  destroy: () ->
    @from.removeEdge(this)
    @to.removeEdge(this)
    ents.edges = _.without ents.edges, this
    redrawAll()
  same: (edge) ->
    if @to is edge.to or
       @to is edge.from or
       @from is edge.from
      return true
    else
      return false
  draw: () ->
    layers.main.drawEdge(this)
  curve: () ->
    curve = C
      p0: @from.node.pos
      p1: @from.pos
      p2: @to.pos
      p3: @to.node.pos

class Leaf extends Entity
  constructor: (@edge, @rect, @loc) ->
    super()
    @draw()
    @pos = @rect.p0
  draw: () ->
    layers.main.drawLeaf(@rect, "#777")

class Lot extends Entity
  constructor: (@path) ->
    super()
    @draw()
  draw: () ->
    layers.main.drawLot(@path)



makeRoad = (oldHandle, curve, newNode=null, continous) ->
  newNode = new Node(curve.p3) unless newNode?
  newHandle = new Handle(newNode, curve.p2)
  if continous
    oldHandle.updatePos curve.p1
    prevHandle = oldHandle
  else
    prevHandle = new Handle(oldHandle.node, curve.p1)
  new Edge(prevHandle, newHandle)
  return newHandle.inverse

splitRoad = (intersection) ->
  edgeToSplit = intersection.edge
  curveToSplit = intersection.edge.curve()
  curves = split curveToSplit, intersection.location.parameter


  newNode =   new Node curves.left.p3
  handleIn =  new Handle newNode, curves.left.p1, "later"
  handleOut = new Handle newNode, curves.right.p2, "later"
  handleIn.inverse = handleOut
  handleOut.inverse = handleIn

  edgeToSplit.from.updatePos curves.left.p2
  edgeToSplit.to.updatePos curves.right.p1

  curve = C
    p0: edgeToSplit.from.node.pos
    p1: curves.left.p2
    p2: handleIn.pos
    p3: newNode.pos
  new Edge(edgeToSplit.from, handleIn)

  curve = C
    p0: newNode.pos
    p1: handleOut.pos
    p2: curves.right.p1
    p3: edgeToSplit.to.node.pos
  new Edge(handleOut, edgeToSplit.to)

  edgeToSplit.destroy()

  return newNode

root.test = () ->
  c = C
    p0: P(0,0)
    p1: P(50,0)
    p2: P(100,50)
    p3: P(100,100)

  console.log split(c,0.5)


root.entTypes = 
  "Edge": "edges"
  "Node": "nodes"
  "Handle": "handels"


root.saveAll = () ->
  localStorage.all = JSON.stringify JSON.decycle root.ents.all()

root.redrawAll = () ->
  layers.main.clear()
  entityTypes = [ents.edges, ents.nodes, ents.handels]
  for entityType in entityTypes
    for ent in entityType
      console.log ent
      ent.draw()

root.loadAll = () ->
  #res = new Resurrect()
  #ents = _.extend ents, res.resurrect localStorage.all
  stored = JSON.retrocycle((JSON.parse localStorage.all), root.classes)
  console.log stored
  seen = []
  find = (obj, namespace) ->
    console.log namespace
    for k, v of obj
      continue unless v?
      if seen.indexOf(v) == -1
        seen.push v
      else
        continue
      if v?.___const? and root.classes[v.___const]? and v.___const isnt "Object"
        v.__proto__ = root.classes[v.___const].prototype
        v.constructor = root.classes[v.___const].prototype.constructor 
        console.log "Added prototype for  "+ v.___const
        #delete v.___const
      if _.isObject v
        find(v, namespace+"."+k)
  for type,arr of stored
    ents[entTypes[type]] = arr
  #  for ent in arr
  #    ent.__proto__ = ents[type].prototype
  redrawAll()

root.ents = {}
root.ents.makeRoad = makeRoad
root.ents.splitRoad = splitRoad
root.ents.Node = Node
root.ents.Handle = Handle
root.ents.Edge = Edge
root.ents.Leaf = Leaf
root.ents.Lot = Lot
root.classes.Entity = Entity
root.classes.Node =  Node
root.classes.Handle = Handle
root.classes.Edge = Edge
root.classes.Leaf = Leaf
root.classes.Lot = Lot

for k,v of entTypes
  root.ents[v] = []

root.ents.all = () ->
  obj = {}
  for k,v of entTypes
    obj[k] = root.ents[v]
  return obj


root.validateEdgeIntegrity = ->
  for edge in ents.edges
    unless edge.from.edge is edge
      console.error "problem in edge", edge
  _.delay(validateEdgeIntegrity, 1000)

validateEdgeIntegrity()