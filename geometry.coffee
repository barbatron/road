root = this

req =
  0: [
    'paper'
    'tools'
    'entities'
  ]
  1:[
    'raphael'
  ]
  2:[
    'layers'
  ]

r = requirejs
r req[0], ->
  class Point2
    constructor: (@x, @y) ->

    normalized: ->
      v = new Point2(@x, @y)
      v.normalize()
      v

    normalize: ->
      length = @length()
      @x /= length
      @y /= length

    dot: (p) ->
      @x * p.x + @y * p.y

    cross: (p) ->
      @x * p.y - @y * p.x

    angle: (p) ->
      # The angle between to ps can be calculated with the formula:
      # a.b = |a||b|cos θ
      #
      # Rewriting gives:
      #  a.b  = cos θ
      # ------
      # |a||b|
      theta = @dot(p) / (@length() * p.length()) # number
      Math.acos theta

    pa: () ->
      new paper.Point(@x,@y)
    
    mirror: (line) ->
      papLine = new paper.Path.Line(line.p0.pa(), line.p1.pa())
      if line.p0 is line.p1
        console.log "line", line
        console.log "papline", papLine

      p = papLine.getNearestPoint(@pa())
      layers.tool.clear()
      layers.tool.drawDot p, "#000"
      return P(p.x + (p.x - @x), p.y + (p.y - @y))
   

    signedAngle: (p) ->
      Math.atan2 @perp().dot(p), @dot(p)

    length: ->
      Math.sqrt @x * @x + @y * @y

    setLength: (length) ->
      @normalize()
      @x *= length
      @y *= length

    perp: ->
      new Point2(-@y, @x)

    add: (other) ->
      new Point2(@x + other.x, @y + other.y)

    sub: (other) ->
      return new Point2(@x - other.x, @y - other.y)

    sub: (other) ->
      new Point2(@x - other.x, @y - other.y)

    mult: (value) ->
      new Point2(@x * value, @y * value)

    div: (value) ->
      new Point2(@x / value, @y / value)

    distance: (p1) ->
      p2 = this
      v = p1.sub(p2) # Vertex2
      v.length()

  root.P =  (x, y) ->
    if y?
      p = new Point2(x, y)
    else if x.y?
      p = new Point2(x.x, x.y)    
    else
      p = new Point2(x.offsetX, x.offsetY)
    return p

  V = (len, ang) ->
    pp = new paper.Point {
      length: len
      angle: ang
    }
    return new Point2(pp.x, pp.y)

  class Line
    constructor: (@p0, @p1) ->
      @p0 = P @p0
      @p1 = P @p1

    slope: ->
      (@p1.y - @p0.y) / (@p1.x - @p0.x)

    inverse: ->
      L(@p0,@p1)

    toAbc: ->
      a = @p1.y - @p0.y
      b = @p0.x - @p1.x
      c = a * @p0.x + b * @p0.y
      a: a
      b: b
      c: c

    intersect: (other) ->
      i1 = @toAbc()
      i2 = other.toAbc()
      denominator = i1.a * i2.b - i2.a * i1.b
      return new Vertex2((i2.b * i1.c - i1.b * i2.c) / denominator, (i1.a * i2.c - i2.a * i1.c) / denominator)  if denominator isnt 0
      null

    angle: (other) ->
      a = @getDirection() # Vector2
      b = other.getDirection() # Vector2
      a.angle b

    signedAngle: (other) ->
      a = @getDirection() # Vector2
      b = other.getDirection() # Vector2
      a.signedAngle b

    length: ->
      x = @p1.x - @p0.x
      y = @p1.y - @p0.y
      Math.sqrt x * x + y * y

    growAdd: (amount) ->
      v = @getDirection()
      np1 = @p1.add(v.mult(amount))
      L @p0, np1

    grow: (factor) ->
      a =  (@p1.sub(@p0)).mult(factor)
      p1 = @p0.add(a)
      L @p0, p1

    growAll: (factor) ->
      a =  (@p1.sub(@p0)).mult(factor)
      p1 = @p0.add(a)
      p0 = @p0.sub(a)
      L p0, p1

    move: (p) ->
      p0 = @p0.add(p)
      p1 = @p1.add(p)
      L p0, p1

    getDirection: () ->
      d = @p1.sub(@p0) # Vector2
      d.normalized()

    json: () ->
      "#{@p0.x} #{@p0.y} - #{@p1.x} #{@p1.y}"

    perp: (point) ->
      p0 = undefined
      if point
        p0 = point
      else

        # take: p0 + (p1 - p0) / 2
        half = @p1.sub(@p0).div(2) # Vector2
        p0 = @p0.add(half)
      # throw new Error("point not on line")  if @distance(p0) isnt 0
      v = @getDirection() # Vector2
      v = v.perp()
      p1 = p0.add(v)
      new Line(p0, p1)

    distance: (p1) ->
      l1 = this
      v = l1.p1.sub(l1.p0) # Vector2
      w = p1.sub(l1.p0) # Vector2
      c1 = w.dot(v) # number
      c2 = v.dot(v) # number
      b = c1 / c2 # number
      a = v.mult(b) # Vector2
      p = l1.p0.add(a) # Vertex2
      d = p1.sub(p) # Vector2
      d.length() # number

    mult: (f) ->
      p1 = P(@p1).sub(P(@p0)).mult(f)
      return L(@p0, p1)

    toCurve: (factor = 0.33333333) ->
      p1 = L(@p0, @p1).grow(factor).p1
      p2 = L(@p1, @p0).grow(factor).p1
      return C
        p0: @p0
        p1: p1
        p2: p2
        p3: @p1

  root.L = (p0, p1) ->
    new Line(p0, p1)


  root.C = (o) ->
    if o instanceof Line
      o = o.toCurve()

    start = o.p0.pa()
    handleIn = o.p1.sub(o.p0).pa()
    handleOut = o.p2.sub(o.p3).pa()
    end = o.p3.pa()
    curve = new paper.Curve(start, handleIn, handleOut, end)
    # Aliases:
    curve.p0 = o.p0
    curve.p1 = o.p1
    curve.p2 = o.p2
    curve.p3 = o.p3
    return curve

  root.C.fromHandle = (handle, end)->
    sta = handle.node.pos
    theHolyFactor = L(sta,end).length()/3
    theOtherHolyThing = L(handle.inverse.pos, handle.node.pos)
    starg = theOtherHolyThing.growAdd(theHolyFactor).p1
    mid = handle.node.pos.add(end).div(2)
    perp = L(handle.node.pos, end).perp().growAll(1000)
    console.log starg, perp
    etarg = starg.mirror(perp)
    layers.tool.drawDot starg, "#0F0"
    layers.tool.drawDot mid, "#00F"
    layers.tool.drawLine perp, "#0FF"
    layers.tool.drawDot etarg, "#F0F"
    return C({
      p0: sta
      p1: starg
      p2: etarg
      p3: end
    })

  root.splitTest = ()->
    c = C
      p0: P(0,0)
      p1: P(0,5)
      p2: P(10,5)
      p3: P(10,0)
    #console.log JSON.stringify root.split c.pointsArr, 0.5


  root.bezier = (pts) ->
    (t) ->
      a = pts # do..while loop in disguise

      while a.length > 1
        i = 0 # cycle over control points
        b = []
        j = undefined

        while i < a.length - 1
          b[i] = [] # cycle over dimensions
          j = 0

          while j < a[i].length
            b[i][j] = a[i][j] * (1 - t) + a[i + 1][j] * t # interpolation
            j++
          i++
        a = b
      a[0]

  root.split = (o, t) ->
    left = []
    right = []
    drawCurve = (points, t) =>
      if points.length is 1
        left.push points[0]
        right.push points[0]
        #draw points[0]
      else
        newpoints = new Array(points.length-1)
        i = 0
        while i < newpoints.length
          left.push points[i]  if i is 0
          right.push points[i + 1]  if i is newpoints.length - 1
          newpoints[i] = points[i].mult(1-t).add(points[i + 1].mult(t)) if points[i + 1]?
          i++
        drawCurve newpoints, t
    drawCurve([ o.p0, o.p1, o.p2, o.p3 ], t)
    return {
      right:
        p0: right[0]
        p1: right[1]
        p2: right[2]
        p3: right[3]
      left:
        p0: left[0]
        p1: left[2]
        p2: left[1]
        p3: left[3]
    }

  root.curveLen = (c) ->
    #console.log "curve", c.p0, c.p3
    prev = c.getLocationAt(0.001, true).point
    tally = 0
    curLoc = 0
    direction = 1
    cur = null
    while curLoc < 1
      curLoc += 0.10 * direction
      #console.log "curloc", curLoc
      cur = c.getLocationAt(curLoc, true).point
      #console.log cur, prev
      dist = cur.getDistance(prev)
      #console.log "dist", dist
      layers.tool.drawDot cur
      tally += dist
      prev = cur
    tally


  root.classes.Point2 = Point2
  root.classes.Line = Line
  root.classes.Point = paper.Point
  root.classes.Curve = paper.Curve

  ###
  all = {}
  seen = ['window']
  findAll = (obj) ->
      for k, v of obj
          if seen.indexOf(k) == -1
              if v?.prototype?.constructor?.name?
                  #seen.push v.prototype.constructor?.name
                  all[v.prototype.constructor.name] = v.prototype
              seen.push k
              if v instanceof Object
                  findAll(v)

  findAll(paper)
  for k,v of all
    unless k == ''
      root.classes[k] = v
  delete root.classes['']
  ###