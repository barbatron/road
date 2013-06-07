// Generated by CoffeeScript 1.6.2
(function() {
  var CommonTool, EdgeTool, Tool, colorSpeed, root,
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
    __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

  root = this;

  colorSpeed = {
    15: 0,
    30: 0.05,
    55: 0.10,
    90: 0.15,
    135: 0.20,
    195: 0.25,
    250: 0.30,
    335: 0.35,
    435: 0.40,
    560: 0.45,
    755: 0.50
  };

  Tool = (function() {
    function Tool() {
      console.log("setting tool", this);
      tools.current = this;
    }

    return Tool;

  })();

  CommonTool = (function(_super) {
    __extends(CommonTool, _super);

    function CommonTool() {
      CommonTool.__super__.constructor.call(this);
      layers.tool.clear();
    }

    CommonTool.prototype.click = function() {
      if (this.closestHandle != null) {
        return new EdgeTool(this.closestHandle);
      }
    };

    CommonTool.prototype.over = function(ent, e) {
      if (ent instanceof ents.Node) {
        return this.node = ent;
      }
    };

    CommonTool.prototype.move = function(e) {
      var dist, edge, edges, handle, nearestPoint, point, shortest, _i, _len, _ref, _results;

      if (this.node != null) {
        point = P(e);
        edges = [];
        shortest = null;
        layers.tool.clear();
        _ref = this.node.handels;
        _results = [];
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          handle = _ref[_i];
          _results.push((function() {
            var _j, _len1, _ref1, _results1;

            _ref1 = handle.edges;
            _results1 = [];
            for (_j = 0, _len1 = _ref1.length; _j < _len1; _j++) {
              edge = _ref1[_j];
              nearestPoint = edge.curve.getNearestPoint(point);
              if (nearestPoint == null) {
                break;
              }
              nearestPoint = P(nearestPoint);
              dist = point.distance(nearestPoint);
              layers.tool.drawDot(nearestPoint, "rgba(255,30,30,0.5)");
              if (dist < shortest || (shortest == null)) {
                shortest = dist;
                if (edge.from.node === this.node) {
                  this.closestHandle = edge.from.inverse;
                } else {
                  this.closestHandle = edge.to.inverse;
                }
                layers.tool.clear();
                _results1.push(layers.tool.drawRoad(edge, "rgba(255,30,30,0.5)"));
              } else {
                _results1.push(void 0);
              }
            }
            return _results1;
          }).call(this));
        }
        return _results;
      }
    };

    CommonTool.prototype.keyDown = function(e) {
      if (e.which === 119) {
        return console.log(this.node);
      }
    };

    return CommonTool;

  })(Tool);

  EdgeTool = (function(_super) {
    __extends(EdgeTool, _super);

    function EdgeTool(handle) {
      this.handle = handle != null ? handle : null;
      this.click = __bind(this.click, this);
      EdgeTool.__super__.constructor.call(this);
      this.endNode = null;
    }

    EdgeTool.prototype.click = function(e) {
      var nextHandle;

      if (this.curve != null) {
        if ((this.intersection != null) && (this.endNode == null)) {
          this.endNode = ents.splitRoad(this.intersection);
        }
        nextHandle = ents.makeRoad(this.handle, this.curve, this.endNode);
        return tools.current = new EdgeTool(nextHandle);
      }
    };

    EdgeTool.prototype.over = function(ent, e) {
      var curve;

      if (ent instanceof ents.Node) {
        if (ent === this.handle.node) {
          return;
        }
        curve = C.fromHandle(this.handle, ent.pos);
        this.settle(curve);
        return this.draw();
      }
    };

    EdgeTool.prototype.out = function(ent, e) {
      if (ent instanceof ents.Node) {
        return this.endNode = null;
      }
    };

    EdgeTool.prototype.move = function(e) {
      var closest, curve, dist, edge, nearestPoint, newPoint, point, _i, _len, _ref;

      if (this.endNode != null) {
        if (L(this.endNode.pos, P(e)).length() > 10) {
          this.endNode = null;
        } else {
          return;
        }
      }
      if (P(e).distance(this.handle.node.pos) <= 0) {
        return;
      }
      point = P(e);
      _ref = ents.edges;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        edge = _ref[_i];
        nearestPoint = edge.curve.getNearestPoint(P(e));
        if (nearestPoint == null) {
          break;
        }
        newPoint = P(nearestPoint);
        dist = newPoint.distance(P(e));
        if (dist < 10) {
          if (dist < closest || (typeof closest === "undefined" || closest === null)) {
            closest = dist;
            point = newPoint;
          }
        }
      }
      curve = C.fromHandle(this.handle, point);
      this.settle(curve);
      return this.draw();
    };

    EdgeTool.prototype.settle = function(curve) {
      var curveBefore, edge1, edge2, endNodeBefore, intersectingNodeLength, intersectingRoadLength, iteration, unsettled, _i, _j, _len, _len1, _ref, _ref1;

      curveBefore = this.curve;
      endNodeBefore = this.endNode;
      this.check(curve);
      this.intersection = null;
      this.endNode = null;
      if (this.curve != null) {
        iteration = 0;
        unsettled = true;
        while (unsettled) {
          curve = this.curve;
          curve = this.intersecting(curve);
          if (curve != null) {
            this.check(curve, true);
          }
          intersectingRoadLength = curveLen(this.curve);
          curve = this.intersectingNode(curve);
          if (curve != null) {
            this.check(curve, true);
          }
          intersectingNodeLength = curveLen(this.curve);
          if (intersectingNodeLength === intersectingRoadLength) {
            unsettled = false;
          }
          iteration++;
          if (iteration > 16) {
            console.warn("Can't settle, let's agree to disagree");
            this.curve = null;
            unsettled = false;
          }
        }
      }
      if (this.endNode === this.handle.node) {
        this.curve = null;
      }
      if ((this.curve != null) && curveLen(this.curve) < 20) {
        this.curve = null;
      }
      if (this.endNode != null) {
        _ref = this.handle.node.edges();
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          edge1 = _ref[_i];
          _ref1 = this.endNode.edges();
          for (_j = 0, _len1 = _ref1.length; _j < _len1; _j++) {
            edge2 = _ref1[_j];
            if (edge1.same(edge2)) {
              this.curve = null;
              this.endNode = null;
              break;
            }
          }
          if (this.curve == null) {
            break;
          }
        }
      }
      if (this.curve == null) {
        this.curve = curveBefore;
        return this.endNode = endNodeBefore;
      }
    };

    EdgeTool.prototype.intersectingNode = function(curve) {
      var distFromCurveStart, distPntToNode, node, point, selected, shortest, _i, _len, _ref;

      this.endNode = null;
      selected = null;
      _ref = ents.nodes;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        node = _ref[_i];
        if (node === this.handle.node) {
          continue;
        }
        point = this.curve.getNearestPoint(node.pos);
        distPntToNode = L(point, node.pos).length();
        if (distPntToNode < 10) {
          distFromCurveStart = L(this.handle.node.pos, point).length();
          if (distFromCurveStart < shortest || (typeof shortest === "undefined" || shortest === null)) {
            selected = node;
            shortest = distFromCurveStart;
          }
        }
      }
      if (selected != null) {
        this.endNode = selected;
        return C.fromHandle(this.handle, selected.pos);
      } else {
        return null;
      }
    };

    EdgeTool.prototype.intersecting = function(curve) {
      var cross, dist, edge, inter, intersections, pos, selected, shortest, _i, _j, _k, _len, _len1, _len2, _ref, _ref1;

      this.intersection = null;
      intersections = [];
      _ref = ents.edges;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        edge = _ref[_i];
        _ref1 = curve.getIntersections(edge.curve);
        for (_j = 0, _len1 = _ref1.length; _j < _len1; _j++) {
          inter = _ref1[_j];
          if (!this.intersectingPrevRoad(edge)) {
            inter.edge = edge;
            intersections.push(inter);
          }
        }
      }
      selected = null;
      for (_k = 0, _len2 = intersections.length; _k < _len2; _k++) {
        cross = intersections[_k];
        if ((cross != null ? cross._point : void 0) != null) {
          cross.p = P(cross._point.x, cross._point.y);
          dist = P(cross._point.x, cross._point.y).distance(this.handle.node.pos);
          if (dist < 1) {
            continue;
          }
          if (dist < shortest || (typeof shortest === "undefined" || shortest === null)) {
            shortest = dist;
            selected = cross;
          }
        }
      }
      if (selected != null) {
        pos = P(selected.p.x, selected.p.y);
        this.intersection = selected;
        return C.fromHandle(this.handle, pos);
      } else {
        return null;
      }
    };

    EdgeTool.prototype.intersectingPrevRoad = function(otherEdge) {
      var edge, _i, _len, _ref;

      _ref = this.handle.node.edges();
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        edge = _ref[_i];
        if (edge === otherEdge) {
          return true;
        }
      }
      return false;
    };

    EdgeTool.prototype.color = function() {
      var hue, k, v;

      hue = 0;
      for (k in colorSpeed) {
        v = colorSpeed[k];
        if (this.rad > new Number(k)) {
          hue = Math.max(v, hue);
        }
      }
      return "hsb(" + hue + ", 0.9, 0.5)";
    };

    EdgeTool.prototype.check = function(curve, skipBackward) {
      var angle, isBackward, len;

      if (skipBackward == null) {
        skipBackward = false;
      }
      isBackward = L(curve.p1, curve.p2).length() > L(curve.p0, curve.p3).length();
      angle = Math.abs(L(curve.p0, curve.p1).signedAngle(L(curve.p2, curve.p3)));
      if (angle > Math.PI / 2 || (skipBackward && isBackward)) {
        this.curve = L(this.handle.node.pos, curve.p3).toCurve();
        this.rad = 99999;
        this.continous = false;
        return;
      }
      if (isBackward) {
        new EdgeTool(this.handle.inverse);
      }
      len = curveLen(curve);
      this.rad = (len * ((2 * Math.PI) / angle)) / (2 * Math.PI);
      if (this.rad > 15) {
        this.curve = curve;
        return this.continous = true;
      }
    };

    EdgeTool.prototype.draw = function() {
      var edge, _i, _len, _ref, _results;

      if (this.curve != null) {
        layers.tool.clear();
        layers.tool.drawBeizer(this.curve, this.color());
        _ref = this.handle.inverse.edges;
        _results = [];
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          edge = _ref[_i];
          _results.push(layers.tool.drawRoad(edge, "rgba(255,30,30,0.5)"));
        }
        return _results;
      }
    };

    return EdgeTool;

  })(Tool);

  root.tools = {};

  root.tools.EdgeTool = EdgeTool;

  root.tools.CommonTool = CommonTool;

}).call(this);

/*
//@ sourceMappingURL=tools.map
*/
