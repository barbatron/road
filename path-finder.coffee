root = this
edgeAllowed = (handle, destination) ->

  unless handle? or destination? or not (handle instanceof ents.Handle and destination instanceof Point2)
    throw Error "Misstreated algorithm exception"

  # Symetical cubic beizers - Edge - Mod
  curve = C.fromHandle handle, destination

  # Projection forward (relative to handle)- Edge - Rule
  isProjectionBackward: (point) ->
    fwdPos = handle.pos
    invPos = handle.inverse.pos
    nodePos = handle.node.pos
    angle = handle.line.angle(L(nodePos, point))
    return angle > 2 * Math.PI / 3

  # Dont bend more than 45 degrees - Edge - Rule
  angle = Math.abs L(curve.p0, curve.p1).signedAngle L(curve.p2, curve.p3)
  if angle > Math.PI/2
    console.log "Curve is more than 45 deg"

  # Minimum 15 m radius - Edge - Rule
  len = curveLen curve
  @rad = (len*((2*Math.PI)/angle))/(2*Math.PI)
  if @rad < 15
    console.log "Curve radius is lower than 15"


  # No loops - Edge - Rule
  # Dont snap to origin node - Edge - Rule
  # No edges shorter than 20 meters - Edge - Rule  
  if curveLen(@curve) < 20


  # No double connections between nodes - Edge/Node - Rule
  
  # No edges closer than 20 meters to nodes (unless they are connected to those nodes) - Node - Rule



  # Should not intersect other edges - Edge - Mod    
  # Should snap to closest curve - Edge - Mod
  # Snap to edge or node if this close - Edge/Node - Mod
  # Snapped and intersected edges should be cut - Factory - Mod
  
  
  
  