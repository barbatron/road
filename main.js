// Generated by CoffeeScript 1.6.2
(function() {
  var ArcTool, Bezier, BezierTool, Layer, LineTool, Node, NodeTool, hotkeys, registerHotkey, root,
    __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

  root = this;

  requirejs(['./node_modules/straightcurve/lib/arc2', './node_modules/straightcurve/lib/vector2', './node_modules/straightcurve/lib/vertex2', './node_modules/straightcurve/lib/line2', './node_modules/straightcurve/lib/circle2', './node_modules/straightcurve/lib/line2'], function() {
    return requirejs(['./node_modules/straightcurve/lib/distancer'], function() {
      var j, line, _i, _len, _results;

      j = $;
      root.layers = {
        main: new Layer('canvas'),
        toolLayer: new Layer('toolLayer')
      };
      j("#mouseTrap").click(function(e) {
        return typeof currentTool.click === "function" ? currentTool.click(e) : void 0;
      });
      j("#mouseTrap").mousemove(function(e) {
        return typeof currentTool.mousemove === "function" ? currentTool.mousemove(e) : void 0;
      });
      window.currentTool = new NodeTool();
      new Node(P(100, 10), P(200, 100), P(110, 50));
      _results = [];
      for (_i = 0, _len = lines.length; _i < _len; _i++) {
        line = lines[_i];
        _results.push(layers.main.drawLine(line));
      }
      return _results;
    });
  });

  hotkeys = {};

  $(window).keypress(function(e) {
    var _name;

    console.log(e.which);
    return typeof hotkeys[_name = event.which] === "function" ? hotkeys[_name]() : void 0;
  });

  registerHotkey = function(key, func) {
    return hotkeys[key] = func;
  };

  registerHotkey(49, function() {
    return window.currentTool = new NodeTool();
  });

  registerHotkey(50, function() {
    return window.currentTool = new BezierTool();
  });

  LineTool = (function() {
    function LineTool() {
      this.mousemove = __bind(this.mousemove, this);
      this.click = __bind(this.click, this);      this.p1 = null;
      this.p2 = null;
      this.step = 0;
    }

    LineTool.prototype.click = function(e) {
      var _ref;

      if ((_ref = this.clickSteps[this.step]) != null) {
        _ref.call(this, e);
      }
      return this.step++;
    };

    LineTool.prototype.clickSteps = {
      0: function(e) {
        return this.p1 = P(e);
      },
      1: function(e) {
        return this.p2 = P(e);
      },
      2: function(e) {
        layers.main.drawLine(L(this.p1, this.p2));
        return window.currentTool = new LineTool();
      }
    };

    LineTool.prototype.mousemove = function(e) {
      var _ref;

      return (_ref = this.mousemoveSteps[this.step]) != null ? _ref.call(this, e) : void 0;
    };

    LineTool.prototype.mousemoveSteps = {
      0: function(e) {},
      1: function(e) {
        layers.toolLayer.clear();
        if (this.p1 != null) {
          return layers.toolLayer.drawLine(L(this.p1, P(e)));
        }
      },
      2: function(e) {}
    };

    return LineTool;

  })();

  NodeTool = (function() {
    function NodeTool() {
      this.mousemove = __bind(this.mousemove, this);
      this.click = __bind(this.click, this);      this.p0 = null;
      this.p1 = null;
      this.step = 0;
    }

    NodeTool.prototype.click = function(e) {
      var _ref;

      if ((_ref = this.clickSteps[this.step]) != null) {
        _ref.call(this, e);
      }
      return this.step++;
    };

    NodeTool.prototype.clickSteps = {
      0: function(e) {
        return this.p0 = P(e);
      },
      1: function(e) {
        return this.p1 = P(e);
      },
      2: function(e) {
        new Node(this.p0, this.p1, P(e));
        return window.currentTool = new LineTool();
      }
    };

    NodeTool.prototype.mousemove = function(e) {
      var _ref;

      return (_ref = this.mousemoveSteps[this.step]) != null ? _ref.call(this, e) : void 0;
    };

    NodeTool.prototype.mousemoveSteps = {
      0: function(e) {},
      1: function(e) {
        var line;

        layers.toolLayer.clear();
        line = L(this.p0, P(e));
        layers.toolLayer.drawLine(line);
        return layers.toolLayer.drawLine(line.perp().grow(100));
      },
      2: function(e) {}
    };

    return NodeTool;

  })();

  ArcTool = (function() {
    function ArcTool() {
      this.mousemove = __bind(this.mousemove, this);
      this.click = __bind(this.click, this);      this.p1 = null;
      this.p2 = null;
      this.step = 0;
    }

    ArcTool.prototype.click = function(e) {
      var _ref;

      if ((_ref = this.clickSteps[this.step]) != null) {
        _ref.call(this, e);
      }
      return this.step++;
    };

    ArcTool.prototype.clickSteps = {
      0: function(e) {
        return this.p1 = P(e);
      },
      1: function(e) {
        return this.p2 = P(e);
      },
      2: function(e) {
        layers.main.drawArc(new Arc2(this.p1, P(e), this.p2));
        return window.currentTool = new ArcTool();
      }
    };

    ArcTool.prototype.mousemove = function(e) {
      var _ref;

      return (_ref = this.mousemoveSteps[this.step]) != null ? _ref.call(this, e) : void 0;
    };

    ArcTool.prototype.mousemoveSteps = {
      0: function(e) {},
      1: function(e) {},
      2: function(e) {
        layers.toolLayer.clear();
        return layers.toolLayer.drawArc(new Arc2(this.p1, P(e), this.p2));
      }
    };

    return ArcTool;

  })();

  BezierTool = (function() {
    function BezierTool() {
      this.mousemove = __bind(this.mousemove, this);
      this.click = __bind(this.click, this);      this.node = null;
      this.p1 = null;
      this.p2 = null;
      this.p3 = null;
      this.p4 = null;
      this.step = 0;
    }

    BezierTool.prototype.click = function(e) {
      var _ref;

      return (_ref = this.clickSteps[this.step]) != null ? _ref.call(this, e) : void 0;
    };

    BezierTool.prototype.clickSteps = {
      0: function(e) {
        if (this.node != null) {
          this.step++;
        }
        return console.log(this.node);
      },
      1: function(e) {},
      2: function(e) {
        this.p2 = P(e);
        return this.step++;
      },
      3: function(e) {
        return layers.main.drawBeizer({
          p0: this.p0,
          p1: P(e),
          p2: this.p2,
          p3: this.p1
        });
      }
    };

    BezierTool.prototype.mousemove = function(e) {
      var _ref;

      return (_ref = this.mousemoveSteps[this.step]) != null ? _ref.call(this, e) : void 0;
    };

    BezierTool.prototype.mousemoveSteps = {
      0: function(e) {
        var foundNode, p, x, y, _i, _j, _ref, _ref1, _ref2, _ref3;

        p = P(e);
        foundNode = false;
        for (x = _i = _ref = p.x - 5, _ref1 = p.x + 5; _ref <= _ref1 ? _i < _ref1 : _i > _ref1; x = _ref <= _ref1 ? ++_i : --_i) {
          if (nodes[x] != null) {
            for (y = _j = _ref2 = p.y - 5, _ref3 = p.y + 5; _ref2 <= _ref3 ? _j < _ref3 : _j > _ref3; y = _ref2 <= _ref3 ? ++_j : --_j) {
              this.node = nodes[x][y];
              if (this.node != null) {
                this.node.highLight();
                foundNode = true;
                break;
              }
            }
          }
          if (foundNode) {
            break;
          }
        }
        if (!foundNode) {
          layers.toolLayer.clear();
          return this.node = null;
        }
      },
      1: function(e) {
        layers.toolLayer.clear();
        this.node.highLight();
        layers.toolLayer.drawBeizer({
          p0: this.node.perp.p0,
          p1: this.node.perp.p1,
          p2: this.node.perp.p1,
          p3: P(e)
        });
        return layers.toolLayer.drawDot(this.node.perp.p1);
      },
      2: function(e) {
        layers.toolLayer.clear();
        return layers.toolLayer.drawArc(new Arc2(this.p0, P(e), this.p1));
      },
      3: function(e) {
        var currentTool;

        layers.toolLayer.clear();
        layers.toolLayer.drawBeizer({
          p0: this.p0,
          p1: P(e),
          p2: this.p2,
          p3: this.p1
        });
        return currentTool = new BezierTool();
      }
    };

    return BezierTool;

  })();

  Layer = (function() {
    function Layer(id) {
      this.ctx = document.getElementById(id).getContext('2d');
      this.clear();
    }

    Layer.prototype.clear = function() {
      return this.ctx.clearRect(0, 0, 500, 300);
    };

    Layer.prototype.drawLine = function(line) {
      this.ctx.beginPath();
      this.ctx.moveTo(line.p0.x, line.p0.y);
      this.ctx.lineTo(line.p1.x, line.p1.y);
      return this.ctx.stroke();
    };

    Layer.prototype.drawArc = function(arc) {
      var line, lines, _i, _len, _results;

      lines = arc.segmentize(30);
      _results = [];
      for (_i = 0, _len = lines.length; _i < _len; _i++) {
        line = lines[_i];
        _results.push(this.drawLine(line));
      }
      return _results;
    };

    Layer.prototype.drawBeizer = function(beizer) {
      this.ctx.beginPath();
      this.ctx.moveTo(beizer.p0.x, beizer.p0.y);
      this.ctx.bezierCurveTo(beizer.p1.x, beizer.p1.y, beizer.p2.x, beizer.p2.y, beizer.p3.x, beizer.p3.y);
      this.ctx.stroke();
      this.drawNode(beizer.p1);
      return this.drawNode(beizer.p2);
    };

    Layer.prototype.drawDot = function(point) {
      this.ctx.fillStyle = "#FFCC33";
      this.ctx.fillRect(point.x + 1, point.y + 1, 3, 3);
      return this.ctx.fillStyle = "black";
    };

    Layer.prototype.drawNode = function(rect, highLight) {
      if (highLight == null) {
        highLight = false;
      }
      this.ctx.fillStyle = "blue";
      if (highLight) {
        this.ctx.fillRect(rect.x - 2, rect.y - 2, rect.w + 4, rect.h + 4);
      } else {
        this.ctx.fillRect(rect.x, rect.y, rect.w, rect.h);
      }
      this.ctx.fillStyle = "red";
      this.ctx.fillRect(rect.x + 2, rect.y + 2, rect.w - 4, rect.h - 4);
      return this.ctx.fillStyle = "black";
    };

    return Layer;

  })();

  root.nodes = [];

  Node = (function() {
    function Node(p0, p1, p2) {
      var x, y;

      this.p0 = p0;
      this.p1 = p1;
      this.p2 = p2;
      console.log("Herp");
      this.line = L(this.p0, this.p1);
      this.perp = this.line.perp();
      this.x = x = this.perp.p0.x;
      this.y = y = this.perp.p0.y;
      layers.main.drawLine(this.line);
      layers.main.drawLine(this.perp.grow(this.perp.distance(this.p2)));
      layers.main.drawNode({
        x: this.perp.p0.x - 3,
        y: this.perp.p0.y - 3,
        w: 6,
        h: 6
      });
      if (nodes[x] == null) {
        root.nodes[x] = [];
      }
      root.nodes[x][y] = this;
    }

    Node.prototype.highLight = function() {
      return layers.toolLayer.drawNode({
        x: this.perp.p0.x - 3,
        y: this.perp.p0.y - 3,
        w: 6,
        h: 6
      }, true);
    };

    return Node;

  })();

  Bezier = (function() {
    function Bezier(start, end, controlpoints) {
      this.start = start;
      this.end = end;
      this.controlpoints = controlpoints != null ? controlpoints : [];
      this.cordinateArray = _.flatten([this.start, this.controllpoints, this.end]);
    }

    return Bezier;

  })();

}).call(this);

/*
//@ sourceMappingURL=main.map
*/
