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
    c.attr "stroke-width", "9"
    
  drawBeizer: (beizer) ->
    c = @ctx.path """
      M #{beizer.p0.x} #{beizer.p0.y}
      C #{beizer.p1.x} #{beizer.p1.y}
        #{beizer.p2.x} #{beizer.p2.y}
        #{beizer.p3.x} #{beizer.p3.y}
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
    t = @ctx.circle(node.ctrl.x, node.ctrl.y, 1)
    t.attr("fill", "#500")
    t.attr("stroke", "#eee")
    
  addNodeSnapper: (node) ->
    c = @ctx.circle(node.pos.x, node.pos.y, 10)
    c.attr("fill", "#555");
    c.mouseover => node.over()
    c.mouseout => node.out()
    
  drawImpasse: (pos) ->
    c = @ctx.circle(pos.x, pos.y, 10)
    c.attr("fill", "#555");
    c.attr("stroke", "#999");


root.layers = {}
for layer in ['main','node','tool','nodeSnap']
  root.layers[layer] = new Layer(layer)
