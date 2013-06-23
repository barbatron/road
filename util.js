// Generated by CoffeeScript 1.6.2
(function() {
  var EdgeSnapper, HandleSnapper, NodeSnapper, Snapper, root, _ref, _ref1, _ref2,
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  root = this;

  Snapper = (function() {
    function Snapper(p, opts) {
      var defs;

      this.p = p;
      if (opts == null) {
        opts = {};
      }
      defs = {
        snapRange: 10,
        callback: function() {},
        items: null,
        comparer: function(a, b) {
          return a < b;
        }
      };
      this.options = _.defaults(opts, defs);
    }

    Snapper.prototype.snap = function() {
      var result, snapResult,
        _this = this;

      snapResult = this.nearest(this.items(), function(i) {
        return _this.distFunc(i);
      });
      result = void 0;
      if ((snapResult != null) && snapResult.distance < this.options.snapRange) {
        result = snapResult;
      }
      return result;
    };

    Snapper.prototype.nearest = function(items, distFunc) {
      var item, itemDist, nearest, _i, _len, _ref;

      nearest = null;
      for (_i = 0, _len = items.length; _i < _len; _i++) {
        item = items[_i];
        itemDist = distFunc(item);
        ((_ref = this.options) != null ? typeof _ref.callback === "function" ? _ref.callback(itemDist) : void 0 : void 0) != null;
        if ((itemDist != null) && (!nearest || itemDist.distance < nearest.distance)) {
          nearest = {
            item: item,
            itemDist: itemDist,
            point: itemDist.point,
            distance: itemDist.distance
          };
        }
      }
      return nearest;
    };

    return Snapper;

  })();

  EdgeSnapper = (function(_super) {
    __extends(EdgeSnapper, _super);

    function EdgeSnapper() {
      _ref = EdgeSnapper.__super__.constructor.apply(this, arguments);
      return _ref;
    }

    EdgeSnapper.prototype.items = function() {
      return ents.edges;
    };

    EdgeSnapper.prototype.distFunc = function(edge) {
      var edgeResult, nearestLocation, newPoint;

      nearestLocation = edge.curve().getNearestLocation(this.p);
      if (nearestLocation == null) {
        return;
      }
      newPoint = P(edge.curve().getPointAt(nearestLocation.parameter, true));
      edgeResult = {
        edge: edge,
        point: newPoint,
        distance: newPoint.distance(this.p)
      };
      return edgeResult;
    };

    return EdgeSnapper;

  })(Snapper);

  NodeSnapper = (function(_super) {
    __extends(NodeSnapper, _super);

    function NodeSnapper() {
      _ref1 = NodeSnapper.__super__.constructor.apply(this, arguments);
      return _ref1;
    }

    NodeSnapper.prototype.items = function() {
      return ents.nodes;
    };

    NodeSnapper.prototype.distFunc = function(node) {
      return {
        node: node,
        point: node.pos,
        distance: node.pos.distance(this.p)
      };
    };

    return NodeSnapper;

  })(Snapper);

  HandleSnapper = (function(_super) {
    __extends(HandleSnapper, _super);

    function HandleSnapper() {
      _ref2 = HandleSnapper.__super__.constructor.apply(this, arguments);
      return _ref2;
    }

    HandleSnapper.prototype.items = function() {
      return this.options.items;
    };

    HandleSnapper.prototype.distFunc = function(handle) {
      var pl, res;

      pl = L(handle.node.pos, this.p);
      res = {
        selectedHandle: handle,
        point: handle.line.p1,
        handle: handle,
        distance: handle.line.angle(pl) * 5
      };
      return res;
    };

    return HandleSnapper;

  })(Snapper);

  root.util = {
    Snapper: Snapper,
    EdgeSnapper: EdgeSnapper,
    NodeSnapper: NodeSnapper,
    HandleSnapper: HandleSnapper
  };

}).call(this);

/*
//@ sourceMappingURL=util.map
*/
