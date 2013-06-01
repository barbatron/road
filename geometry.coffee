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
  class Point
    constructor: (@x, @y) ->

    normalized: ->
      v = new Point(@x, @y)
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
      unless @pap?
        @pap = new paper.Point(@x,@y)
      return @pap

    mirror: (line) ->
      line = new paper.Path.Line(line.p0.pa(), line.p1.pa())
      p = line.getNearestPoint(@pa())
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
      new Point(-@y, @x)

    add: (other) ->
      new Point(@x + other.x, @y + other.y)

    sub: (other) ->
      return new Point(@x - other.x, @y - other.y)

    sub: (other) ->
      new Point(@x - other.x, @y - other.y)

    mult: (value) ->
      new Point(@x * value, @y * value)

    div: (value) ->
      new Point(@x / value, @y / value)

    distance: (p1) ->
      p2 = this
      v = p1.sub(p2) # Vertex2
      v.length()

  root.P =  (x, y) ->
    if y?
      p = new Point(x, y)
    else
      p = new Point(x.offsetX, x.offsetY)
    return p

  V = (len, ang) ->
    pp = new paper.Point {
      length: len
      angle: ang
    }
    return new Point(pp.x, pp.y)

  class Line
    constructor: (@p0, @p1) ->

    slope: ->
      (@p1.y - @p0.y) / (@p1.x - @p0.x)

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
      a.angle2 b

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
      throw new Error("point not on line")  if @distance(p0) isnt 0
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

  root.L = (p0, p1) ->
    new Line(p0, p1)

  root.C = (o) ->
    start = o.p0.pa()
    handleIn = o.p1.sub(o.p0).pa()
    handleOut = o.p2.sub(o.p3).pa()
    end = o.p3.pa()
    curve = new paper.Curve(start, handleIn, handleOut, end)
    curve.p0 = o.p0
    curve.p1 = o.p1
    curve.p2 = o.p2
    curve.p3 = o.p3
    return curve

  root.C.fromNode = (node, end)->
    sta = node.pos
    starg = node.line.growAdd(L(sta,end).length()/2.5).p1
    mid = node.pos.add(end).div(2)
    perp = L(node.pos, end).perp().growAll(1000)
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