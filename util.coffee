root = this

class Snapper
  constructor: (@p, opts={}) ->
    defs = 
      snapRange: 10
      callback: ->
      items: null
      comparer: (a,b) -> a < b
    @options = _.defaults(opts, defs)

  snap: () ->
    #items = @options.items || @items() || []
    snapResult = @nearest @items(), (i) => @distFunc(i)
    result = undefined
    if snapResult? and snapResult.distance < @options.snapRange
      result = snapResult

    return result

  nearest: (items, distFunc) -> 
    nearest = null
    for item in items
      itemDist = distFunc item
      @options?.callback?(itemDist)?     
      if itemDist? and (not nearest or itemDist.distance < nearest.distance)
        nearest = 
          item: item
          itemDist: itemDist
          point: itemDist.point
          distance: itemDist.distance
    return nearest

class EdgeSnapper extends Snapper 
  items: () ->
    ents.edges

  distFunc: (edge) ->
    nearestLocation = edge.curve().getNearestLocation(@p)
    return unless nearestLocation?
    newPoint = P(edge.curve().getPointAt(nearestLocation.parameter, true))  
    edgeResult =
      edge: edge
      point: newPoint
      distance: newPoint.distance(@p)                 
    return edgeResult
    
class NodeSnapper extends Snapper 
  items: () ->
    ents.nodes
  
  distFunc: (node) ->
    return {
      node: node
      point: node.pos
      distance: node.pos.distance @p
    }
  
class HandleSnapper extends Snapper
  items: () ->
    return @options.items

  distFunc: (handle) ->
    pl = L(handle.node.pos, @p)
    res = {
      selectedHandle: handle
      point: handle.line.p1
      handle: handle
      distance: handle.line.angle(pl) * 5
    }
    return res


root.util =
  Snapper: Snapper
  EdgeSnapper: EdgeSnapper
  NodeSnapper: NodeSnapper
  HandleSnapper: HandleSnapper