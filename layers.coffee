root = this

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
    @clear()
    
  clear: ->
    @ctx.clear()
    
  drawLine: (line) ->
    c = @ctx.path("M #{line.p0.x} #{line.p0.y} L #{line.p1.x} #{line.p1.y}")
    c.attr("stroke", "#eee")
    c.attr "stroke-width", "2"
    
  drawBeizer: (beizer, color="#777") ->
    c = @ctx.path """
      M #{beizer.p0.x} #{beizer.p0.y}
      C #{beizer.p1.x} #{beizer.p1.y}
        #{beizer.p2.x} #{beizer.p2.y}
        #{beizer.p3.x} #{beizer.p3.y}
      """
    c.attr "stroke-width", "9"
    c.attr("stroke", color)

  drawStraightRoad:  (line) ->
    c = @ctx.path("M #{line.p0.x} #{line.p0.y} L #{line.p1.x} #{line.p1.y}")
    c.attr("stroke", "#777")
    c.attr "stroke-width", "9"

  drawHandle: (handle) ->
    c = @ctx.circle(handle.pos.x, handle.pos.y, 4)
    c.attr("fill", "#3f3");
    @drawLine(handle.line)

  drawDot: (pos, color="#505") ->
    c = @ctx.circle(pos.x, pos.y, 4)
    c.attr("fill", color);
    
  drawRoad: (line) ->
    c = @ctx.path("M#{line.p0.x} #{line.p0.y} L#{line.p1.x} #{line.p1.y} ");
    c.attr "stroke-width", "9"
    c.attr("stroke", "#eee");

  drawRoadCurve: (road, color="#777") ->
    beizer = road.opt.curve
    c = @ctx.path """
      M #{beizer.p0.x} #{beizer.p0.y}
      C #{beizer.p1.x} #{beizer.p1.y}
        #{beizer.p2.x} #{beizer.p2.y}
        #{beizer.p3.x} #{beizer.p3.y}
      """
    c.attr "stroke-width", "9"
    c.attr "stroke", color

  drawRoadLine: (road, color="#777") ->
    c = @ctx.path """
      M #{road.edge.line.p0.x}
        #{road.edge.line.p0.y}
      L #{road.edge.line.p1.x}
        #{road.edge.line.p1.y}
      """
    c.attr "stroke-width", "9"
    c.attr "stroke", color

  drawNode: (node, large = false) ->
    c = @ctx.circle(node.pos.x, node.pos.y, 4)
    c.attr("fill", "#eee")
    if large
      c = @ctx.circle(node.pos.x, node.pos.y, 4)
    else
      c = @ctx.circle(node.pos.x, node.pos.y, 2)
    c.attr "stroke-width", "1"
    c.attr("fill", "#500")
    c.attr("stroke", "#eee")
    for handle in node.handels
      t = @ctx.circle(handle.pos.x, handle.pos.y, 1)
      t.attr("fill", "#500")
      t.attr("stroke", "#eee")

  addNodeSnapper: (node) ->
    c = @ctx.circle(node.pos.x, node.pos.y, 10)
    c.attr("fill", "rgba(0,0,0,0)");
    c.mouseover (e) => node.over(e)
    c.mouseout (e) => node.out(e)

  addEdgeSnapper: (edge) ->
    c = @ctx.path("M#{line.p0.x} #{line.p0.y} L#{line.p1.x} #{line.p1.y}")
    c.attr "stroke-width", "9"
    c.attr("stroke", "#eee");
    c.mouseover => edge.over()
    c.mouseout => edge.out()

  drawImpasse: (pos) ->
    c = @ctx.circle(pos.x, pos.y, 1)
    c.attr("fill", "#555")
    c.attr("stroke", "#999")


root.layers = {}
for layer in ['main','node','tool','nodeSnap']
  root.layers[layer] = new Layer(layer)

class PaperLayer
  constructor: (id)->
    div = $("<canvas id='#{id}'></canvas>")
    $('body').append div
    paper.setup(id)

new PaperLayer ('papa')