// Generated by CoffeeScript 1.6.2
(function() {
  var Layer, PaperLayer, layer, root, zIndex, _i, _len, _ref;

  root = this;

  zIndex = 0;

  Layer = (function() {
    function Layer(id) {
      var div, height, width;

      this.w = width = $('body').width();
      this.h = height = $('body').height();
      div = $("<div id='" + id + "'></div>");
      div.css({
        "border": "1px solid #aaa",
        "background-color": "rgba(0,0,0,0)",
        "position": "absolute"
      }, "left: 0", "top: 0", {
        "z-index": zIndex++,
        "width": width + "px",
        "height": height + "px"
      });
      $('body').append(div);
      this.ctx = new Raphael(id, 10000, 10000);
      this.clear();
    }

    Layer.prototype.clear = function() {
      return this.ctx.clear();
    };

    Layer.prototype.drawLine = function(line) {
      var c;

      c = this.ctx.path("M " + line.p0.x + " " + line.p0.y + " L " + line.p1.x + " " + line.p1.y);
      c.attr("stroke", "#eee");
      return c.attr("stroke-width", "2");
    };

    Layer.prototype.drawBeizer = function(beizer, color) {
      var c;

      if (color == null) {
        color = "#777";
      }
      c = this.ctx.path("M " + beizer.p0.x + " " + beizer.p0.y + "\nC " + beizer.p1.x + " " + beizer.p1.y + "\n  " + beizer.p2.x + " " + beizer.p2.y + "\n  " + beizer.p3.x + " " + beizer.p3.y);
      c.attr("stroke-width", "7");
      return c.attr("stroke", color);
    };

    Layer.prototype.drawHandle = function(handle) {
      var c;

      c = this.ctx.circle(handle.pos.x, handle.pos.y, 4);
      c.attr("fill", "#3f3");
      return this.drawLine(handle.line);
    };

    Layer.prototype.drawDot = function(pos, color) {
      var c;

      if (color == null) {
        color = "#505";
      }
      c = this.ctx.circle(pos.x, pos.y, 4);
      return c.attr("fill", color);
    };

    Layer.prototype.drawRoad = function(edge, color) {
      var beizer, c;

      if (color == null) {
        color = "#777";
      }
      beizer = edge.curve;
      c = this.ctx.path("M " + beizer.p0.x + " " + beizer.p0.y + "\nC " + beizer.p1.x + " " + beizer.p1.y + "\n  " + beizer.p2.x + " " + beizer.p2.y + "\n  " + beizer.p3.x + " " + beizer.p3.y);
      c.attr("stroke-width", "6");
      c.attr("stroke", color);
      return c;
    };

    Layer.prototype.remove = function(id) {
      return this.ctx.getById(id).remove();
    };

    Layer.prototype.drawNode = function(node, large) {
      var c;

      if (large == null) {
        large = false;
      }
      c = this.ctx.circle(node.pos.x, node.pos.y, 4);
      c.attr("fill", "#eee");
      if (large) {
        c = this.ctx.circle(node.pos.x, node.pos.y, 4);
      } else {
        c = this.ctx.circle(node.pos.x, node.pos.y, 2);
      }
      c.attr("stroke-width", "1");
      c.attr("fill", "#500");
      return c.attr("stroke", "#eee");
    };

    Layer.prototype.addNodeSnapper = function(node) {
      var c,
        _this = this;

      c = this.ctx.circle(node.pos.x, node.pos.y, 10);
      c.attr("fill", "rgba(0,0,0,0)");
      c.mouseover(function(e) {
        return node.over(e);
      });
      return c.mouseout(function(e) {
        return node.out(e);
      });
    };

    Layer.prototype.addEdgeSnapper = function(edge) {
      var c,
        _this = this;

      c = this.ctx.path("M" + line.p0.x + " " + line.p0.y + " L" + line.p1.x + " " + line.p1.y);
      c.attr("stroke-width", "9");
      c.attr("stroke", "#eee");
      c.mouseover(function() {
        return edge.over();
      });
      return c.mouseout(function() {
        return edge.out();
      });
    };

    Layer.prototype.drawImpasse = function(pos) {
      var c;

      c = this.ctx.circle(pos.x, pos.y, 1);
      c.attr("fill", "#555");
      return c.attr("stroke", "#999");
    };

    return Layer;

  })();

  root.layers = {};

  _ref = ['main', 'node', 'tool', 'nodeSnap'];
  for (_i = 0, _len = _ref.length; _i < _len; _i++) {
    layer = _ref[_i];
    root.layers[layer] = new Layer(layer);
  }

  PaperLayer = (function() {
    function PaperLayer(id) {
      var div;

      div = $("<canvas id='" + id + "'></canvas>");
      $('body').append(div);
      paper.setup(id);
    }

    return PaperLayer;

  })();

  new PaperLayer('papa');

}).call(this);

/*
//@ sourceMappingURL=layers.map
*/
