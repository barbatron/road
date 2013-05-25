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
      main: new Layer('canvas')
      toolLayer: new Layer('toolLayer')
    j("#mouseTrap").click (e) -> currentTool.click?(e)
    j("#mouseTrap").mousemove (e) -> currentTool.mousemove?(e)
    window.currentTool = new NodeTool()
    new Node(P(100,200),P(200,200),P(399),P(350))
    lines = new Arc2(P(10,10),P(50,10),P(200,100)).segmentize(30)
    layers.main.drawLine line for line in lines


hotkeys = {}
$(window).keypress (e) ->
  console.log e.which
  hotkeys[event.which]?()
registerHotkey = (key, func) ->
  hotkeys[key] = func

registerHotkey 49, -> currentTool = new NodeTool() # 1
registerHotkey 50, -> currentTool = new BezierTool() # 2

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
      layers.toolLayer.clear()
      layers.toolLayer.drawLine L(@p1, P(e)) if @p1?
    2: (e) ->

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
      window.currentTool = new LineTool()
  mousemove: (e) =>
    @mousemoveSteps[@step]?.call(this,e)
  mousemoveSteps:
    0: (e) ->
    1: (e) ->
      layers.toolLayer.clear()
      line = L(@p0, P(e))
      layers.toolLayer.drawLine line
      layers.toolLayer.drawLine line.perp().grow 10
    2: (e) ->

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
      layers.toolLayer.clear()
      layers.toolLayer.drawArc new Arc2(@p1,P(e),@p2)

class BezierTool
  constructor: () ->
    @p1=null
    @p2=null
    @p3=null
    @p4=null
    @step=0
  click: (e) =>
    @clickSteps[@step]?.call(this,e)
  clickSteps:    
    0: (e) ->
      @p0 = P(e)
      @step++
    1: (e) ->
      @p1 = P(e)
      @step++
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
  mousemoveSteps:
    0: (e) ->
    1: (e) ->
      layers.toolLayer.clear()
      layers.toolLayer.drawLine L(@p0, P(e))
    2: (e) ->
      layers.toolLayer.clear()
      layers.toolLayer.drawArc new Arc2(@p0,P(e),@p1)
    3: (e) ->
      layers.toolLayer.clear()
      layers.toolLayer.drawBeizer {
        p0: @p0
        p1: P(e)
        p2: @p2
        p3: @p1
      }
      currentTool = new BezierTool()

class Layer
  constructor: (id) ->
    @ctx = document.getElementById(id).getContext('2d')
    @clear()
  clear: ->
    @ctx.clearRect 0,0,500,300
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
  drawRect: (rect) ->
    @ctx.fillStyle = "blue"
    @ctx.fillRect(rect.x, rect.y, rect.w, rect.h)
    @ctx.fillStyle = "red"
    @ctx.fillRect(rect.x+2, rect.y+2, rect.w-4, rect.h-4)
    @ctx.fillStyle = "black"


root.nodes = []

class Node
  constructor: (@p0, @p1, @p2) ->
    console.log "Herp"
    @line = L(@p0, @p1)
    @perp = @line.perp()
    @x = @perp.p0.x
    @y = @perp.p0.y
    layers.main.drawLine @line
    layers.main.drawLine @perp.grow 10
    layers.main.drawRect
      x: @perp.p0.x - 3
      y: @perp.p0.y - 3
      w: 6
      h: 6
    nodes[x] = [] unless nodes[x]?
    nodes[x][y] = this


  


class Bezier
  constructor: (@start, @end, @controlpoints = []) ->
    @cordinateArray = _.flatten [@start, @controllpoints, @end]

