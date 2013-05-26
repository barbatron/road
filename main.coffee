root = this

requirejs ['./node_modules/straightcurve/lib/arc2',
           './node_modules/straightcurve/lib/vector2',
           './node_modules/straightcurve/lib/vertex2',
           './node_modules/straightcurve/lib/line2',
           './node_modules/straightcurve/lib/circle2',
           './node_modules/straightcurve/lib/line2'
           ], ->
  requirejs ['./node_modules/straightcurve/lib/distancer', 'raphael'], (a, Raphael)->
    j = $
    root.layers =
      main: new Layer('main')
      node: new Layer('node')
      tool: new Layer('tool')
    width = $('body').width()
    height = $('body').height()

    j("body").append $('<div id="mouseTrap" style="border:1px solid #aaa; background-color:rgba(0,0,0,0);    position: absolute; left: 0; top: 0; bottom: 0; z-index: 111;      width: 10000px; height: 10000px;"></div>')
    j("#mouseTrap").click (e) -> currentTool.click?(e)
    j("#mouseTrap").mousemove (e) -> currentTool.mousemove?(e)
    j("#mouseTrap").mousedown (e) -> currentTool.mousedown?(e)
    window.currentTool = new NodeTool()
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
    @p1=null
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
      layers.tool.clear()
      @road.draw(layers.tool.ctx)
    1: (e) ->
      layers.tool.clear()
      @road.draw(layers.tool.ctx)
    2: (e) ->

findNode = (e) ->
  p = P(e)
  node = null
  foundNode = false
  for x in [p.x-5...p.x+5]
    if nodes[x]?
      for y in [p.y-5...p.y+5]
        node = nodes[x][y]
        if node?
          foundNode = true
          break
    break if foundNode
  return node

###
redrawNodes = () ->
  layers.node.clear()
  for nodeY in nodes
    if nodeY?
      for node in nodeY
        node?.draw?()   
###

class NodeTool
  constructor: () ->
    @p0=null
    @p1=null
    @step=0
  click: (e) =>
    @clickSteps[@step]?.call(this,e)
  clickSteps:
    0: (e) ->
      if @node?
        window.currentTool = new BezierTool(@node)
      else
        @p0 = P(e)
        @step++
    1: (e) ->
      new Edge(@p0, P(e))
      window.currentTool = new NodeTool()
  mousemove: (e) =>
    @mousemoveSteps[@step]?.call(this,e)
  mousemoveSteps:
    0: (e) ->
      layers.tool.clear() 
      @node = findNode(e)
      if @node?
        layers.tool.drawNode(@node, true)
      else  
        layers.tool.drawImpasse(P(e))
    1: (e) ->
      line = L(@p0, P(e))
      layers.tool.clear()
      layers.tool.drawRoad line
      layers.tool.drawImpasse(@p0)

class Edge
  constructor: (@p0, @p1) ->
    @n0 = new Node(@p0, @p1)
    @n1 = new Node(@p1, @p0)
    @line = L(@p0, @p1)
    @draw()
  draw: () ->
    layers.main.drawRoad @line
    layers.main.drawImpasse(@p0)

class Node
  constructor: (@pos, @target) ->
    @line = L(@target, @pos)
    @ctrl = @line.growAdd(50).p1
    
    root.nodes[@pos.x] = [] unless nodes[@pos.x]?
    root.nodes[@pos.x][@pos.y] = this
    layers.node.drawNode(@)
  
      

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
  constructor: (@node = null) ->
    @p1=null
    @p2=null
    @p3=null
    @p4=null
    unless @node? then @step=0 else @step=1
  click: (e) =>
    @clickSteps[@step]?.call(this,e)
  clickSteps:    
    0: (e) ->
      @step++ if @node?
    1: (e) ->
      bezier = @bezier e 
      layers.main.drawBeizer bezier
      node = new Node bezier.p3, bezier.p2
      window.currentTool = new BezierTool(node)
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
  bezier: (e)->
    sta = @node.pos
    end = P(e)
    mid = @node.line.growAdd(100).p1
    starg = @node.ctrl
    etarg = P(end.x+((mid.x-end.x)/2), end.y+((mid.y-end.y)/2))
    layers.tool.drawDot starg, "#0F0"
    layers.tool.drawDot mid
    layers.tool.drawDot etarg, "#F0F"
    return {
      p0: sta
      p1: starg
      p2: etarg
      p3: end
    }
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
          layers.tool.drawNode(@node, true)
          layers.tool.drawNode(@node2, true)
          layers.tool.drawBeizer {
            p0: @node.perp.p0
            p1: @node.perp.p1
            p2: @node2.perp.p1
            p3: @node2.perp.p0
          }
          return
      
      layers.tool.clear()
      layers.tool.drawNode(@node, true)
      layers.tool.drawBeizer @bezier e

    2: (e) ->
      layers.tool.clear()
      layers.tool.drawArc new Arc2(@p0,P(e),@p1)
    3: (e) ->
      layers.tool.clear()
      layers.tool.drawBeizer {
        p0: @pos
        p1: P(e)
        p2: @p2
        p3: @p1
      }
      currentTool = new BezierTool()

zIndex = 0
class Layer
  constructor: (id) ->
    @w = width = $('body').width()#.replace "px",""
    @h = height = $('body').height()#.replace "px",""
    div = $("<div id='#{id}'></div>")
    div.css
      "border": "1px solid #aaa"
      "background-color": "rgba(0,0,0,0)"
      "position": "absolute"
      "left: 0"
      "top: 0"
      "z-index": zIndex++
      "width": width + "px"
      "height": height + "px"
    $('body').append div
    @ctx = new Raphael(id, 10000, 10000)
    #@ctx.setViewBox 0, 0, setViewBox, @h, false
    @clear()
  clear: ->
    @ctx.clear()
  drawLine: (line) ->
    @ctx.path("M #{line.p0.x} #{line.p0.y} L #{line.p1.x} #{line.p1.y}")
  drawArc: (arc) ->
    lines = arc.segmentize(30)
    @drawLine line for line in lines
  drawBeizer: (beizer) ->
    c = @ctx.path """M #{beizer.p0.x} #{beizer.p0.y}
      C #{beizer.p1.x}
      #{beizer.p1.y}
      #{beizer.p2.x}
      #{beizer.p2.y}
      #{beizer.p3.x}
      #{beizer.p3.y}
      """
    c.attr "stroke-width", "9"
    c.attr("stroke", "#eee")
  
  drawDot: (pos, color="#505") ->
    c = @ctx.circle(pos.x, pos.y, 4)
    c.attr("fill", color);
    
  drawRoad: (line) ->
    c = @ctx.path("M#{line.p0.x} #{line.p0.y} L#{line.p1.x} #{line.p1.y} ");
    c.attr "stroke-width", "9"
    c.attr("stroke", "#eee");

  drawNode: (node, large = false) ->
    if large
      c = @ctx.circle(node.pos.x, node.pos.y, 8)
    else
      c = @ctx.circle(node.pos.x, node.pos.y, 4)
    c.attr("fill", "#500")
    c.attr("stroke", "#eee")
    t = @ctx.circle(node.ctrl.x, node.ctrl.y, 10)
    t.attr("fill", "#500")
    t.attr("stroke", "#eee")
    

  drawImpasse: (pos) ->
    c = @ctx.circle(pos.x, pos.y, 10)
    c.attr("fill", "#555");
    c.attr("stroke", "#999");

root.nodes = []

  


class Bezier
  constructor: (@start, @end, @controlpoints = []) ->
    @cordinateArray = _.flatten [@start, @controllpoints, @end]

