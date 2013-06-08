// Generated by CoffeeScript 1.6.2
(function() {
  var CommonTool, EdgeTool, LeafTool, Tool, colorSpeed, root,
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

    function CommonTool(edgeTool) {
      this.edgeTool = edgeTool != null ? edgeTool : true;
      CommonTool.__super__.constructor.call(this);
      layers.tool.clear();
    }

    CommonTool.prototype.click = function() {
      if (this.edgeTool) {
        if (this.closestHandle != null) {
          return new EdgeTool(this.closestHandle);
        }
      } else {
        if (this.closestEdge != null) {
          return new LeafTool(this.closestEdge);
        }
      }
    };

    CommonTool.prototype.over = function(ent, e) {
      if (ent instanceof ents.Node) {
        return this.node = ent;
      }
    };

    CommonTool.prototype.move = function(e) {
      var dist, edge, edges, handle, nearestPoint, point, shortest, _i, _j, _len, _len1, _ref, _ref1;

      if (this.node != null) {
        point = P(e);
        edges = [];
        shortest = null;
        layers.tool.clear();
        _ref = this.node.handels;
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          handle = _ref[_i];
          _ref1 = handle.edges;
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
              this.closestEdge = edge;
              if (edge.from.node === this.node) {
                this.closestHandle = edge.from.inverse;
              } else {
                this.closestHandle = edge.to.inverse;
              }
            }
          }
        }
        if (this.closestEdge != null) {
          return layers.tool.drawRoad(this.closestEdge, "rgba(255,30,30,0.5)");
        }
      }
    };

    CommonTool.prototype.keyDown = function(e) {
      if (e.which === 119) {
        return console.log(this.node);
      }
    };

    return CommonTool;

  })(Tool);

  LeafTool = (function(_super) {
    __extends(LeafTool, _super);

    function LeafTool(edge, leaf1, modifier) {
      this.edge = edge;
      this.leaf1 = leaf1 != null ? leaf1 : null;
      this.modifier = modifier != null ? modifier : null;
      LeafTool.__super__.constructor.call(this);
    }

    LeafTool.prototype.click = function(e) {
      var leaf, lot, rect, _i, _j, _len, _len1, _ref, _ref1;

      if (this.rects.length > 0) {
        _ref = this.rects;
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          rect = _ref[_i];
          leaf = new ents.Leaf(this.edge, rect, this.loc);
        }
        _ref1 = this.lots;
        for (_j = 0, _len1 = _ref1.length; _j < _len1; _j++) {
          lot = _ref1[_j];
          new ents.Lot(lot);
        }
        return new CommonTool();
      }
    };

    LeafTool.prototype.move = function(e) {
      var curve, curveLength, driveWay, i, loc, lotWidth, n, nearestLoc, normal, normal2, point, point2, rect, s, tangent, tangent2, _i, _j, _len, _ref, _results;

      layers.tool.clear();
      nearestLoc = this.edge.curve.getNearestLocation(P(e).pa());
      if (nearestLoc == null) {
        return;
      }
      point = this.edge.curve.getPointAt(nearestLoc._parameter, true);
      normal = this.edge.curve.getNormalAt(nearestLoc._parameter, true);
      tangent = this.edge.curve.getTangentAt(nearestLoc._parameter, true);
      this.loc = nearestLoc;
      this.modifier = this.checkSide(P(e), P(point), normal);
      this.rects = [];
      curve = C(split(this.edge.curve, nearestLoc._parameter).left);
      curveLength = curve.getLength();
      n = this.edge.curve.getLength() / curveLength;
      n = Math.min(n, this.edge.curve.getLength() / 10);
      lotWidth = this.edge.curve.getLength() / n;
      this.lots = [];
      for (i = _i = 0; 0 <= n ? _i <= n : _i >= n; i = 0 <= n ? ++_i : --_i) {
        s = split(this.edge.curve, (1 / n) * i);
        loc = this.edge.curve.getNearestLocation(s.left.p3);
        point2 = this.edge.curve.getPointAt(loc._parameter, true);
        normal2 = this.edge.curve.getNormalAt(loc._parameter, true);
        tangent2 = this.edge.curve.getTangentAt(loc._parameter, true);
        this.modifier = this.modifier * -1;
        driveWay = this.makeRect(point2, normal2, tangent2);
        if (!(P(point2).distance(this.edge.curve.p0) < lotWidth / 2 || P(point2).distance(this.edge.curve.p3) < lotWidth / 2)) {
          this.rects.push(driveWay);
          this.lots.push(this.makeLot(driveWay, lotWidth));
        }
      }
      _ref = this.rects;
      _results = [];
      for (_j = 0, _len = _ref.length; _j < _len; _j++) {
        rect = _ref[_j];
        _results.push(layers.tool.drawLeaf(rect, "#00FF00"));
      }
      return _results;
    };

    LeafTool.prototype.adjustLots = function(lots) {
      var intersection, intersections, lot, lot1, lot2, _i, _j, _len, _len1, _results;

      for (_i = 0, _len = lots.length; _i < _len; _i++) {
        lot = lots[_i];
        lot.path = new paper.Path();
        path.moveTo(lot.p0);
        path.lineTo(lot.p1);
        path.lineTo(lot.p2);
        path.lineTo(lot.p3);
        path.closePath();
      }
      _results = [];
      for (_j = 0, _len1 = lots.length; _j < _len1; _j++) {
        lot1 = lots[_j];
        _results.push((function() {
          var _k, _len2, _results1;

          _results1 = [];
          for (_k = 0, _len2 = lots.length; _k < _len2; _k++) {
            lot2 = lots[_k];
            if (lot1 !== lot2) {
              intersections = lot1.path.getIntersections(lot2);
              _results1.push((function() {
                var _l, _len3, _results2;

                _results2 = [];
                for (_l = 0, _len3 = intersections.length; _l < _len3; _l++) {
                  intersection = intersections[_l];
                  _results2.push(intersection.segment.point.linkTo = intersection.point);
                }
                return _results2;
              })());
            } else {
              _results1.push(void 0);
            }
          }
          return _results1;
        })());
      }
      return _results;
    };

    LeafTool.prototype.makeLot = function(driveWay, width) {
      var height, lot, p0, p1, p2, p3, pp0, pp1;

      driveWay.tangent.length = width;
      driveWay.normal.length = width * 4;
      height = 700 / width;
      pp0 = this.edge.curve.getNearestLocation(driveWay.p0.add(P(driveWay.tangent)));
      pp1 = this.edge.curve.getNearestLocation(driveWay.p0.sub(P(driveWay.tangent)));
      p0 = P(pp0._point);
      p1 = P(pp1._point);
      p2 = P(pp1._point).add(P(pp1.getNormal().setLength(height * this.modifier)));
      p3 = P(pp0._point).add(P(pp0.getNormal().setLength(height * this.modifier)));
      lot = {
        p0: p0,
        p1: p1,
        p2: p2,
        p3: p3
      };
      layers.tool.drawLot(lot);
      return lot;
    };

    LeafTool.prototype.makeRect = function(point, normal, tangent) {
      var offset, p0, p1, p2, p3;

      offset = this.edge.opt.width / 2;
      normal.length = (offset - 1) * this.modifier;
      p0 = P(point).add(P(normal));
      if (this.modifier > 0) {
        normal.length = offset + (5 * this.modifier);
      } else {
        normal.length = offset - (5 * this.modifier);
      }
      p1 = P(point).add(P(normal));
      tangent.length = 5;
      p2 = p1.add(P(tangent));
      p3 = p0.add(P(tangent));
      return {
        p0: p0,
        p1: p1,
        p2: p2,
        p3: p3,
        tangent: tangent,
        normal: normal
      };
    };

    LeafTool.prototype.checkSide = function(mousePos, point, normal) {
      var lowerDist, lowerNormal, upperNormal, uppperDist;

      normal.length = 5;
      upperNormal = P(normal);
      uppperDist = mousePos.distance(point.add(upperNormal));
      normal.length = -5;
      lowerNormal = P(normal);
      lowerDist = mousePos.distance(point.add(lowerNormal));
      if (uppperDist < lowerDist) {
        return -1;
      } else {
        return 1;
      }
    };

    return LeafTool;

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
          console.log("splitting at", this.intersection);
          this.endNode = ents.splitRoad(this.intersection);
        }
        nextHandle = ents.makeRoad(this.handle, this.curve, this.endNode, this.continous);
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
      var curve, point, snapPoint;

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
      snapPoint = this.snap(point);
      if (snapPoint != null) {
        point = snapPoint.point;
      }
      curve = C.fromHandle(this.handle, point);
      this.settle(curve);
      return this.draw();
    };

    EdgeTool.prototype.snap = function(orig) {
      var closest, dist, edge, location, nearestLocation, newPoint, _i, _len, _ref;

      location = null;
      _ref = ents.edges;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        edge = _ref[_i];
        nearestLocation = edge.curve.getNearestLocation(orig);
        if (nearestLocation == null) {
          continue;
        }
        newPoint = P(edge.curve.getPointAt(nearestLocation.parameter, true));
        dist = newPoint.distance(orig);
        if (dist < 10) {
          if (dist < closest || (typeof closest === "undefined" || closest === null)) {
            closest = dist;
            location = {
              point: newPoint,
              edge: edge,
              location: nearestLocation
            };
          }
        }
      }
      if (location != null) {
        return location;
      } else {
        return null;
      }
    };

    EdgeTool.prototype.settle = function(curve) {
      var edge1, edge2, intersectingNodeLength, intersectingRoadLength, iteration, unsettled, _i, _j, _len, _len1, _ref, _ref1, _results;

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
        _results = [];
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
          } else {
            _results.push(void 0);
          }
        }
        return _results;
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
        if (distPntToNode < 20) {
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
      var cross, dist, edge, inter, intersections, pos, selected, shortest, snapPoint, _i, _j, _k, _len, _len1, _len2, _ref, _ref1;

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
            inter.location = {};
            inter.location.parameter = edge.curve.getParameterOf(inter._point);
            intersections.push(inter);
          }
        }
      }
      snapPoint = this.snap(curve.p3);
      if (snapPoint != null) {
        snapPoint._point = new paper.Point(snapPoint.point);
        intersections.push(snapPoint);
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

  root.tools.LeafTool = LeafTool;

}).call(this);

/*
//@ sourceMappingURL=tools.map
*/
