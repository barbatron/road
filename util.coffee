root = this

class Snapper
  constructor: (@p, opts={}) ->
    defs = 
      snapRange: 10
      callback: ->
    @options = _.defaults(opts, defs)

  snap: () ->
    snapResult = @nearest @items(), (i) => @distFunc(i)
    resultDefaults = 
      orig: @p
      point: @p
      distance: null      
      item: null

    if snapResult? and snapResult.distance < @options.snapRange
      result = _.defaults(snapResult, resultDefaults)

    return result

  nearest: (items, distFunc) -> 
    nearest = null
    for item in items
      itemDist = distFunc item
      @options?.callback?(itemDist)?     
      if itemDist? and (!nearest or itemDist.distance < nearest.distance)
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
  
root.util =
  Snapper: Snapper
  EdgeSnapper: EdgeSnapper
  NodeSnapper: NodeSnapper