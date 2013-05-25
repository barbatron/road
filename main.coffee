root = this

requirejs ['./node_modules/straightcurve/lib/arc2',
           './node_modules/straightcurve/lib/vector2',
           './node_modules/straightcurve/lib/vertex2',
           './node_modules/straightcurve/lib/line2',
           './node_modules/straightcurve/lib/circle2',
           './node_modules/straightcurve/lib/line2'], ->
  requirejs ['./node_modules/straightcurve/lib/distancer'], ->
    j = $
    root.layers =
      main: new Layer('main')
      tool: new Layer('tool')
    width = $('body').width()
    height = $('body').height()

    j("body").append $('<div id="mouseTrap" style="border:1px solid #aaa; background-color:rgba(0,0,0,0);    position: absolute; left: 0; top: 0; bottom: 0; z-index: 2;      width: '+width+'; height: '+height+';"></div>')
    j("#mouseTrap").click (e) -> currentTool.click?(e)
    j("#mouseTrap").mousemove (e) -> currentTool.mousemove?(e)
    j("#mouseTrap").mousedown (e) -> currentTool.mousedown?(e)

    window.currentTool = new RoadTool()
        

    ##Debug stuff goes here
    #new Node(P(100,10),P(100,80),P(110,150))
    #new Node(P(151,194),P(115,198),P(150,150))


hotkeys = {}
$(window).keypress (e) ->
  console.log e.which
  hotkeys[event.which]?()
registerHotkey = (key, func) ->
  hotkeys[key] = func

registerHotkey 49, -> window.currentTool = new NodeTool() # 1
registerHotkey 50, -> window.currentTool = new BezierTool() # 2

window.ctrlHold = false
$(window).keydown (e) ->
  if e.which is 17
    window.ctrlHold = true
$(window).keyup (e) ->
  if e.which is 17
    window.ctrlHold = false
$(window).blur (e) ->
  window.ctrlHold = false
  

class LineTool
  constructor: () ->
    @p1=null
    @p2=null
    @step=0
  click: (e) =>
    @clickSteps[@step]?.call(this,e)
    @step++
  clickSteps:    
    0: (e) ->
      @p1 = P(e)
    1: (e) ->
      @p2 = P(e)
    2: (e) ->
      layers.main.drawLine L(@p1, @p2)
      window.currentTool = new LineTool()
  mousemove: (e) =>
    @mousemoveSteps[@step]?.call(this,e)
  mousemoveSteps:
    0: (e) ->
    1: (e) ->
      layers.tool.clear()
      layers.tool.drawLine L(@p1, P(e)) if @p1?
    2: (e) ->

class RoadTool
  constructor: () ->
    @road = new Road()
    @step=0
    @mousePressed = false
  click: (e) =>
  clickSteps:    
    0: (e) ->
    1: (e) ->
    2: (e) ->
  mousedown: (e) =>
    @mousePressed = true
  mousemove: (e) =>
    @mousemoveSteps[@step]?.call(this,e)
  mousemoveSteps:
    0: (e) ->
      if @mousePressed
        @road.turnTo V(e)
      else
        @road.setCenter(P(e))
      layers.tool.clear()
      @road.draw(layers.tool.ctx)
      #layers.tool.drawRoad(P(e))
    1: (e) ->
    2: (e) ->

class Road
  constructor: () ->
    @center = new Vector2(0,0)
  setCenter: (pnt) ->
    @center = new Vector2(pnt.x, pnt.y)
  turnTo: (v) ->
    @ang = @center.signedAngle v
    console.log "ang", @ang
  draw: (ctx) ->
    if @ang?
      ctx.rotate(@ang)
      #ctx.translate(@center.x,@center.y)
    ctx.fillStyle = "gray"
    ctx.fillRect(@center.x-4, @center.y-16, 8, 32)
    ctx.fillStyle = "black"
    ctx.rotate(0)
    ctx.translate(0,0)

class NodeTool
  constructor: () ->
    @p0=null
    @p1=null
    @step=0
  click: (e) =>
    @clickSteps[@step]?.call(this,e)
    @step++
  clickSteps:    
    0: (e) ->
      @p0 = P(e)
    1: (e) ->
      @p1 = P(e)
    2: (e) ->
      new Node(@p0, @p1, P(e))
      window.currentTool = new NodeTool()
  mousemove: (e) =>
    @mousemoveSteps[@step]?.call(this,e)
  mousemoveSteps:
    0: (e) ->
    1: (e) ->
      layers.tool.clear()
      line = L(@p0, P(e))
      layers.tool.drawLine line
    2: (e) ->
      layers.tool.clear()
      line = L(@p0, @p1)
      perp = line.perp()
      layers.tool.drawLine line
      layers.tool.drawLine perp.grow perp.p0.distance(P(e))

class ArcTool
  constructor: () ->
    @p1=null
    @p2=null
    @step=0
  click: (e) =>
    @clickSteps[@step]?.call(this,e)
    @step++
  clickSteps:    
    0: (e) ->
      @p1 = P(e)
    1: (e) ->
      @p2 = P(e)
    2: (e) ->
      layers.main.drawArc new Arc2(@p1,P(e),@p2)
      window.currentTool = new ArcTool()
  mousemove: (e) =>
    @mousemoveSteps[@step]?.call(this,e)
  mousemoveSteps:
    0: (e) ->
    1: (e) ->
    2: (e) ->
      layers.tool.clear()
      layers.tool.drawArc new Arc2(@p1,P(e),@p2)

class BezierTool
  constructor: () ->
    @node=null
    @p1=null
    @p2=null
    @p3=null
    @p4=null
    @step=0
  click: (e) =>
    @clickSteps[@step]?.call(this,e)
  clickSteps:    
    0: (e) ->
      @step++ if @node?
      console.log @node
    1: (e) ->
    2: (e) ->
      @p2 = P(e)
      @step++
    3: (e) ->
      layers.main.drawBeizer {
        p0: @p0
        p1: P(e)
        p2: @p2
        p3: @p1
      }
  mousemove: (e) =>
    @mousemoveSteps[@step]?.call(this,e)
  findNode: (e) ->
    p = P(e)
    node = null
    foundNode = false
    for x in [p.x-5...p.x+5]
      if nodes[x]?
        for y in [p.y-5...p.y+5]
          node = nodes[x][y]
          if node?
            node.highLight()
            foundNode = true
            break
      break if foundNode
    return node

  mousemoveSteps:
    0: (e) ->
      p = P(e)
      foundNode = false
      for x in [p.x-5...p.x+5]
        if nodes[x]?
          for y in [p.y-5...p.y+5]
            @node = nodes[x][y]
            if @node?
              @node.highLight()
              foundNode = true
              break
        break if foundNode

      unless foundNode
        layers.tool.clear() 
        @node = null

    1: (e) ->
      if ctrlHold
        node = @findNode(e)
        if node?
          @node2 = node
          layers.tool.clear()
          @node.highLight()
          @node2.highLight()
          layers.tool.drawBeizer {
            p0: @node.perp.p0
            p1: @node.perp.p1
            p2: @node2.perp.p1
            p3: @node2.perp.p0
          }
          return        
      
      layers.tool.clear()
      @node.highLight()
      layers.tool.drawBeizer {
        p0: @node.perp.p0
        p1: @node.perp.p1
        p2: @node.perp.p1
        p3: P(e)
      }
      layers.tool.drawDot @node.perp.p1

    2: (e) ->
      layers.tool.clear()
      layers.tool.drawArc new Arc2(@p0,P(e),@p1)
    3: (e) ->
      layers.tool.clear()
      layers.tool.drawBeizer {
        p0: @p0
        p1: P(e)
        p2: @p2
        p3: @p1
      }
      currentTool = new BezierTool()

class Layer
  constructor: (id) ->
    @w = width = $('body').width()#.replace "px",""
    @h = height = $('body').height()#.replace "px",""
    $('body').append $('<canvas id="'+id+'" width='+width+' height='+height+'	style="border:1px solid #aaa; background-color:rgba(0,0,0,0); 	position: absolute; left: 0; top: 0; z-index: 0;"></canvas>')
    @ctx = document.getElementById(id).getContext('2d')
    @clear()
  clear: ->
    @ctx.clearRect 0,0,@w,@h
  drawLine: (line) ->
    @ctx.beginPath()
    @ctx.moveTo(line.p0.x,line.p0.y)
    @ctx.lineTo(line.p1.x,line.p1.y)
    @ctx.stroke()
  drawArc: (arc) ->
    lines = arc.segmentize(30)
    @drawLine line for line in lines
  drawBeizer: (beizer) ->
    @ctx.beginPath()
    @ctx.moveTo(beizer.p0.x,beizer.p0.y)
    @ctx.bezierCurveTo(
      beizer.p1.x,
      beizer.p1.y,
      beizer.p2.x,
      beizer.p2.y,
      beizer.p3.x,
      beizer.p3.y
    )
    @ctx.stroke()
    @drawNode beizer.p1
    @drawNode beizer.p2
  drawDot: (point) ->
    @ctx.fillStyle = "#FFCC33"
    @ctx.fillRect(point.x+1, point.y+1, 3, 3)
    @ctx.fillStyle = "black"
    
  drawNode: (rect, highLight = false) ->
    @ctx.fillStyle = "blue"
    if highLight
      @ctx.fillRect(rect.x-2, rect.y-2, rect.w+4, rect.h+4)      
    else
      @ctx.fillRect(rect.x, rect.y, rect.w, rect.h)
    @ctx.fillStyle = "red"
    @ctx.fillRect(rect.x+2, rect.y+2, rect.w-4, rect.h-4)
    @ctx.fillStyle = "black"

  drawRoad: (pos, ang = 0) ->
    @ctx.rotate(ang)
    @ctx.fillStyle = "gray"
    @ctx.fillRect(pos.x-4, pos.y-16, 8, 32)
    @ctx.fillStyle = "black"
    @ctx.rotate(0)

root.nodes = []

class Node
  constructor: (@p0, @p1, @p2) ->
    console.log "Herp"
    @line = L(@p0, @p1)
    @perp = @line.perp()
    @x = x = Math.floor @perp.p0.x
    @y = y = Math.floor @perp.p0.y
    layers.main.drawLine @line
    layers.main.drawLine @perp.grow Math.max(@perp.distance(@p2), @line.length())
    layers.main.drawNode
      x: @perp.p0.x - 3
      y: @perp.p0.y - 3
      w: 6
      h: 6
    root.nodes[x] = [] unless nodes[x]?
    root.nodes[x][y] = this
  highLight: -> 
    layers.tool.drawNode
      x: @perp.p0.x - 3
      y: @perp.p0.y - 3
      w: 6
      h: 6
    , true
      
  


class Bezier
  constructor: (@start, @end, @controlpoints = []) ->
    @cordinateArray = _.flatten [@start, @controllpoints, @end]

