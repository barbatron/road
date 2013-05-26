if typeof Math.sgn is "undefined"
  Math.sgn = (x) ->
    (if x is 0 then 0 else (if x > 0 then 1 else -1))
Vectors =
  subtract: (v1, v2) ->
    x: v1.x - v2.x
    y: v1.y - v2.y

  dotProduct: (v1, v2) ->
    (v1.x * v2.x) + (v1.y * v2.y)

  square: (v) ->
    Math.sqrt (v.x * v.x) + (v.y * v.y)

  scale: (v, s) ->
    x: v.x * s
    y: v.y * s

maxRecursion = 64
flatnessTolerance = Math.pow(2.0, -maxRecursion - 1)

###
Calculates the distance that the point lies from the curve.

@param point a point in the form {x:567, y:3342}
@param curve a Bezier curve in the form [{x:..., y:...}, {x:..., y:...}, {x:..., y:...}, {x:..., y:...}].  note that this is currently
hardcoded to assume cubiz beziers, but would be better off supporting any degree.
@return a JS object literal containing location and distance, for example: {location:0.35, distance:10}.  Location is analogous to the location
argument you pass to the pointOnPath function: it is a ratio of distance travelled along the curve.  Distance is the distance in pixels from
the point to the curve.
###
_distanceFromCurve = (point, curve) ->
  candidates = []
  w = _convertToBezier(point, curve)
  degree = curve.length - 1
  higherDegree = (2 * degree) - 1
  numSolutions = _findRoots(w, higherDegree, candidates, 0)
  v = Vectors.subtract(point, curve[0])
  dist = Vectors.square(v)
  t = 0.0
  i = 0

  while i < numSolutions
    v = Vectors.subtract(point, _bezier(curve, degree, candidates[i], null, null))
    newDist = Vectors.square(v)
    if newDist < dist
      dist = newDist
      t = candidates[i]
    i++
  v = Vectors.subtract(point, curve[degree])
  newDist = Vectors.square(v)
  if newDist < dist
    dist = newDist
    t = 1.0
  location: t
  distance: dist


###
finds the nearest point on the curve to the given point.
###
_nearestPointOnCurve = (point, curve) ->
  td = _distanceFromCurve(point, curve)
  point: _bezier(curve, curve.length - 1, td.location, null, null)
  location: td.location

_convertToBezier = (point, curve) ->
  degree = curve.length - 1
  higherDegree = (2 * degree) - 1
  c = []
  d = []
  cdTable = []
  w = []
  z = [[1.0, 0.6, 0.3, 0.1], [0.4, 0.6, 0.6, 0.4], [0.1, 0.3, 0.6, 1.0]]
  i = 0

  while i <= degree
    c[i] = Vectors.subtract(curve[i], point)
    i++
  i = 0

  while i <= degree - 1
    d[i] = Vectors.subtract(curve[i + 1], curve[i])
    d[i] = Vectors.scale(d[i], 3.0)
    i++
  row = 0

  while row <= degree - 1
    column = 0

    while column <= degree
      cdTable[row] = []  unless cdTable[row]
      cdTable[row][column] = Vectors.dotProduct(d[row], c[column])
      column++
    row++
  i = 0
  while i <= higherDegree
    w[i] = []  unless w[i]
    w[i].y = 0.0
    w[i].x = parseFloat(i) / higherDegree
    i++
  n = degree
  m = degree - 1
  k = 0

  while k <= n + m
    lb = Math.max(0, k - m)
    ub = Math.min(k, n)
    i = lb
    while i <= ub
      j = k - i
      w[i + j].y += cdTable[j][i] * z[j][i]
      i++
    k++
  w


###
counts how many roots there are.
###
_findRoots = (w, degree, t, depth) ->
  left = []
  right = []
  left_count = undefined
  right_count = undefined
  left_t = []
  right_t = []
  switch _getCrossingCount(w, degree)
    when 0
      return 0
    when 1
      if depth >= maxRecursion
        t[0] = (w[0].x + w[degree].x) / 2.0
        return 1
      if _isFlatEnough(w, degree)
        t[0] = _computeXIntercept(w, degree)
        return 1
      break
  _bezier w, degree, 0.5, left, right
  left_count = _findRoots(left, degree, left_t, depth + 1)
  right_count = _findRoots(right, degree, right_t, depth + 1)
  i = 0

  while i < left_count
    t[i] = left_t[i]
    i++
  i = 0

  while i < right_count
    t[i + left_count] = right_t[i]
    i++
  left_count + right_count

_getCrossingCount = (curve, degree) ->
  n_crossings = 0
  sign = undefined
  old_sign = undefined
  sign = old_sign = Math.sgn(curve[0].y)
  i = 1

  while i <= degree
    sign = Math.sgn(curve[i].y)
    n_crossings++  unless sign is old_sign
    old_sign = sign
    i++
  n_crossings

_isFlatEnough = (curve, degree) ->
  error = undefined
  intercept_1 = undefined
  intercept_2 = undefined
  left_intercept = undefined
  right_intercept = undefined
  a = undefined
  b = undefined
  c = undefined
  det = undefined
  dInv = undefined
  a1 = undefined
  b1 = undefined
  c1 = undefined
  a2 = undefined
  b2 = undefined
  c2 = undefined
  a = curve[0].y - curve[degree].y
  b = curve[degree].x - curve[0].x
  c = curve[0].x * curve[degree].y - curve[degree].x * curve[0].y
  max_distance_above = max_distance_below = 0.0
  i = 1

  while i < degree
    value = a * curve[i].x + b * curve[i].y + c
    if value > max_distance_above
      max_distance_above = value
    else max_distance_below = value  if value < max_distance_below
    i++
  a1 = 0.0
  b1 = 1.0
  c1 = 0.0
  a2 = a
  b2 = b
  c2 = c - max_distance_above
  det = a1 * b2 - a2 * b1
  dInv = 1.0 / det
  intercept_1 = (b1 * c2 - b2 * c1) * dInv
  a2 = a
  b2 = b
  c2 = c - max_distance_below
  det = a1 * b2 - a2 * b1
  dInv = 1.0 / det
  intercept_2 = (b1 * c2 - b2 * c1) * dInv
  left_intercept = Math.min(intercept_1, intercept_2)
  right_intercept = Math.max(intercept_1, intercept_2)
  error = right_intercept - left_intercept
  (if (error < flatnessTolerance) then 1 else 0)

_computeXIntercept = (curve, degree) ->
  XLK = 1.0
  YLK = 0.0
  XNM = curve[degree].x - curve[0].x
  YNM = curve[degree].y - curve[0].y
  XMK = curve[0].x - 0.0
  YMK = curve[0].y - 0.0
  det = XNM * YLK - YNM * XLK
  detInv = 1.0 / det
  S = (XNM * YMK - YNM * XMK) * detInv
  0.0 + XLK * S

_bezier = (curve, degree, t, left, right) ->
  temp = [[]]
  j = 0

  while j <= degree
    temp[0][j] = curve[j]
    j++
  i = 1

  while i <= degree
    j = 0

    while j <= degree - i
      temp[i] = []  unless temp[i]
      temp[i][j] = {}  unless temp[i][j]
      temp[i][j].x = (1.0 - t) * temp[i - 1][j].x + t * temp[i - 1][j + 1].x
      temp[i][j].y = (1.0 - t) * temp[i - 1][j].y + t * temp[i - 1][j + 1].y
      j++
    i++
  if left?
    j = 0
    while j <= degree
      left[j] = temp[j][0]
      j++
  if right?
    j = 0
    while j <= degree
      right[j] = temp[degree - j][j]
      j++
  temp[degree][0]

_curveFunctionCache = {}
_getCurveFunctions = (order) ->
  fns = _curveFunctionCache[order]
  unless fns
    fns = []
    f_term = ->
      (t) ->
        Math.pow t, order

    l_term = ->
      (t) ->
        Math.pow (1 - t), order

    c_term = (c) ->
      (t) ->
        c

    t_term = ->
      (t) ->
        t

    one_minus_t_term = ->
      (t) ->
        1 - t

    _termFunc = (terms) ->
      (t) ->
        p = 1
        i = 0

        while i < terms.length
          p = p * terms[i](t)
          i++
        p

    fns.push new f_term() # first is t to the power of the curve order
    i = 1

    while i < order
      terms = [new c_term(order)]
      j = 0

      while j < (order - i)
        terms.push new t_term()
        j++
      j = 0

      while j < i
        terms.push new one_minus_t_term()
        j++
      fns.push new _termFunc(terms)
      i++
    fns.push new l_term() # last is (1-t) to the power of the curve order
    _curveFunctionCache[order] = fns
  fns


###
calculates a point on the curve, for a Bezier of arbitrary order.
@param curve an array of control points, eg [{x:10,y:20}, {x:50,y:50}, {x:100,y:100}, {x:120,y:100}].  For a cubic bezier this should have four points.
@param location a decimal indicating the distance along the curve the point should be located at.  this is the distance along the curve as it travels, taking the way it bends into account.  should be a number from 0 to 1, inclusive.
###
_pointOnPath = (curve, location) ->
  cc = _getCurveFunctions(curve.length - 1)
  _x = 0
  _y = 0
  i = 0

  while i < curve.length
    _x = _x + (curve[i].x * cc[i](location))
    _y = _y + (curve[i].y * cc[i](location))
    i++
  x: _x
  y: _y

_dist = (p1, p2) ->
  Math.sqrt Math.pow(p1.x - p2.x, 2) + Math.pow(p1.y - p2.y, 2)

_isPoint = (curve) ->
  curve[0].x is curve[1].x and curve[0].y is curve[1].y


###
finds the point that is 'distance' along the path from 'location'.  this method returns both the x,y location of the point and also
its 'location' (proportion of travel along the path); the method below - _pointAlongPathFrom - calls this method and just returns the
point.
###
_pointAlongPath = (curve, location, distance) ->
  if _isPoint(curve)
    return (
      point: curve[0]
      location: location
    )
  prev = _pointOnPath(curve, location)
  tally = 0
  curLoc = location
  direction = (if distance > 0 then 1 else -1)
  cur = null
  while tally < Math.abs(distance)
    curLoc += (0.005 * direction)
    cur = _pointOnPath(curve, curLoc)
    tally += _dist(cur, prev)
    prev = cur
  point: cur
  location: curLoc

_length = (curve) ->
  return 0  if _isPoint(curve)
  prev = _pointOnPath(curve, 0)
  tally = 0
  curLoc = 0
  direction = 1
  cur = null
  while curLoc < 1
    curLoc += (0.005 * direction)
    cur = _pointOnPath(curve, curLoc)
    tally += _dist(cur, prev)
    prev = cur
  tally


###
finds the point that is 'distance' along the path from 'location'.
###
_pointAlongPathFrom = (curve, location, distance) ->
  _pointAlongPath(curve, location, distance).point


###
finds the location that is 'distance' along the path from 'location'.
###
_locationAlongPathFrom = (curve, location, distance) ->
  _pointAlongPath(curve, location, distance).location


###
returns the gradient of the curve at the given location, which is a decimal between 0 and 1 inclusive.

thanks // http://bimixual.org/AnimationLibrary/beziertangents.html
###
_gradientAtPoint = (curve, location) ->
  p1 = _pointOnPath(curve, location)
  p2 = _pointOnPath(curve.slice(0, curve.length - 1), location)
  dy = p2.y - p1.y
  dx = p2.x - p1.x
  (if dy is 0 then Infinity else Math.atan(dy / dx))


###
returns the gradient of the curve at the point which is 'distance' from the given location.
if this point is greater than location 1, the gradient at location 1 is returned.
if this point is less than location 0, the gradient at location 0 is returned.
###
_gradientAtPointAlongPathFrom = (curve, location, distance) ->
  p = _pointAlongPath(curve, location, distance)
  p.location = 1  if p.location > 1
  p.location = 0  if p.location < 0
  _gradientAtPoint curve, p.location


###
calculates a line that is 'length' pixels long, perpendicular to, and centered on, the path at 'distance' pixels from the given location.
if distance is not supplied, the perpendicular for the given location is computed (ie. we set distance to zero).
###
_perpendicularToPathAt = (curve, location, length, distance) ->
  distance = (if not distance? then 0 else distance)
  p = _pointAlongPath(curve, location, distance)
  m = _gradientAtPoint(curve, p.location)
  _theta2 = Math.atan(-1 / m)
  y = length / 2 * Math.sin(_theta2)
  x = length / 2 * Math.cos(_theta2)
  [
    x: p.point.x + x
    y: p.point.y + y
  ,
    x: p.point.x - x
    y: p.point.y - y
  ]

jsBezier = window.jsBezier =
  distanceFromCurve: _distanceFromCurve
  gradientAtPoint: _gradientAtPoint
  gradientAtPointAlongCurveFrom: _gradientAtPointAlongPathFrom
  nearestPointOnCurve: _nearestPointOnCurve
  pointOnCurve: _pointOnPath
  pointAlongCurveFrom: _pointAlongPathFrom
  perpendicularToCurveAt: _perpendicularToPathAt
  locationAlongCurveFrom: _locationAlongPathFrom
  getLength: _length
