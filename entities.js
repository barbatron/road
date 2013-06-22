// Generated by CoffeeScript 1.6.2
(function() {
  var Edge, Entity, Handle, Leaf, Lot, Node, all, makeRoad, redrawAll, root, splitRoad,
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  root = this;

  root.validateEdgeIntegrity = function() {
    var edge, _i, _len, _ref;

    _ref = ents.edges;
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      edge = _ref[_i];
      if (edge.from.edge !== edge) {
        console.error("problemn in edge", edge);
      }
    }
    return _.delay(validateEdgeIntegrity, 1000);
  };

  redrawAll = function() {
    var ent, entityType, entityTypes, _i, _len, _results;

    layers.main.clear();
    entityTypes = [ents.edges, ents.nodes, ents.handels];
    _results = [];
    for (_i = 0, _len = entityTypes.length; _i < _len; _i++) {
      entityType = entityTypes[_i];
      _results.push((function() {
        var _j, _len1, _results1;

        _results1 = [];
        for (_j = 0, _len1 = entityType.length; _j < _len1; _j++) {
          ent = entityType[_j];
          _results1.push(ent.draw());
        }
        return _results1;
      })());
    }
    return _results;
  };

  all = {};

  Entity = (function() {
    function Entity() {
      this.id = _.uniqueId();
      all[this.id] = this;
    }

    return Entity;

  })();

  Node = (function(_super) {
    __extends(Node, _super);

    function Node(pos, target) {
      this.pos = pos;
      if (target == null) {
        target = null;
      }
      Node.__super__.constructor.call(this);
      this.handels = [];
      if (target != null) {
        new Handle(this, target);
      }
      layers.nodeSnap.addNodeSnapper(this);
      this.draw();
      ents.nodes.push(this);
    }

    Node.prototype.addHandle = function(handle) {
      if (this.handels.indexOf(handle === -1)) {
        this.handels.push(handle);
      }
      return handle;
    };

    Node.prototype.draw = function() {
      return layers.main.drawNode(this);
    };

    Node.prototype.over = function(e) {
      var _base;

      return typeof (_base = tools.current).over === "function" ? _base.over(this, e) : void 0;
    };

    Node.prototype.out = function(e) {
      var _base;

      if (typeof (_base = tools.current).out === "function") {
        _base.out(this, e);
      }
      return layers.tool.clear();
    };

    Node.prototype.edges = function() {
      return _.pluck(this.handles, "edge");
    };

    return Node;

  })(Entity);

  Handle = (function(_super) {
    __extends(Handle, _super);

    function Handle(node, pos, inverse) {
      this.node = node;
      this.pos = pos;
      this.inverse = inverse != null ? inverse : null;
      Handle.__super__.constructor.call(this);
      this.line = L(this.node.pos, this.pos);
      if (this.inverse == null) {
        this.inverse = new Handle(this.node, this.line.grow(-1).p1, this);
      }
      this.draw();
      this.node.addHandle(this);
      ents.handels.push(this);
    }

    Handle.prototype.updatePos = function(pos) {
      this.pos = pos;
      this.line = L(this.node.pos, this.pos);
      return this.draw();
    };

    Handle.prototype.draw = function() {
      return layers.main.drawHandle(this);
    };

    Handle.prototype.addEdge = function(edge) {
      if (!(edge instanceof Edge)) {
        console.error("wtf mate!");
        console.stack();
        throw new Error("HEY!");
      }
      return this.edge = edge;
    };

    Handle.prototype.removeEdge = function(edge) {
      if (this.edge === edge) {
        return this.edge = null;
      }
    };

    return Handle;

  })(Entity);

  Edge = (function(_super) {
    var defaults;

    __extends(Edge, _super);

    defaults = {
      color: "#777",
      width: 7
    };

    function Edge(from, to, curve) {
      this.from = from;
      this.to = to;
      this.curve = curve;
      Edge.__super__.constructor.call(this);
      this.opt = _.defaults(defaults);
      this.line = L(this.from.node.pos, this.to.node.pos);
      this.from.addEdge(this);
      this.to.addEdge(this);
      this.draw();
      ents.edges.push(this);
    }

    Edge.prototype.destroy = function() {
      this.from.removeEdge(this);
      this.to.removeEdge(this);
      ents.edges = _.without(ents.edges, this);
      return redrawAll();
    };

    Edge.prototype.same = function(edge) {
      if (this.to === edge.to || this.to === edge.from || this.from === edge.from) {
        return true;
      } else {
        return false;
      }
    };

    Edge.prototype.draw = function() {
      return layers.main.drawRoad(this);
    };

    return Edge;

  })(Entity);

  Leaf = (function(_super) {
    __extends(Leaf, _super);

    function Leaf(edge, rect, loc) {
      this.edge = edge;
      this.rect = rect;
      this.loc = loc;
      Leaf.__super__.constructor.call(this);
      this.draw();
      this.pos = this.rect.p0;
    }

    Leaf.prototype.draw = function() {
      return layers.main.drawLeaf(this.rect, "#777");
    };

    return Leaf;

  })(Entity);

  Lot = (function(_super) {
    __extends(Lot, _super);

    function Lot(path) {
      this.path = path;
      Lot.__super__.constructor.call(this);
      this.draw();
    }

    Lot.prototype.draw = function() {
      return layers.main.drawLot(this.path);
    };

    return Lot;

  })(Entity);

  makeRoad = function(oldHandle, curve, newNode, continous) {
    var newHandle, prevHandle;

    if (newNode == null) {
      newNode = null;
    }
    if (newNode == null) {
      newNode = new Node(curve.p3);
    }
    newHandle = new Handle(newNode, curve.p2);
    if (continous) {
      oldHandle.updatePos(curve.p1);
      prevHandle = oldHandle;
    } else {
      prevHandle = new Handle(oldHandle.node, curve.p1);
    }
    new Edge(prevHandle, newHandle, curve);
    return newHandle.inverse;
  };

  splitRoad = function(intersection) {
    var curve, curveToSplit, curves, edgeToSplit, handleIn, handleOut, newNode;

    edgeToSplit = intersection.edge;
    curveToSplit = intersection.edge.curve;
    curves = split(curveToSplit, intersection.location.parameter);
    newNode = new Node(curves.left.p3);
    handleIn = new Handle(newNode, curves.left.p1, "later");
    handleOut = new Handle(newNode, curves.right.p2, "later");
    handleIn.inverse = handleOut;
    handleOut.inverse = handleIn;
    edgeToSplit.from.updatePos(curves.left.p2);
    edgeToSplit.to.updatePos(curves.right.p1);
    curve = C({
      p0: edgeToSplit.from.node.pos,
      p1: curves.left.p2,
      p2: handleIn.pos,
      p3: newNode.pos
    });
    new Edge(edgeToSplit.from, handleIn, curve);
    curve = C({
      p0: newNode.pos,
      p1: handleOut.pos,
      p2: curves.right.p1,
      p3: edgeToSplit.to.node.pos
    });
    new Edge(handleOut, edgeToSplit.to, curve);
    edgeToSplit.destroy();
    return newNode;
  };

  root.test = function() {
    var c;

    c = C({
      p0: P(0, 0),
      p1: P(50, 0),
      p2: P(100, 50),
      p3: P(100, 100)
    });
    return console.log(split(c, 0.5));
  };

  root.ents = {};

  root.ents.makeRoad = makeRoad;

  root.ents.splitRoad = splitRoad;

  root.ents.Node = Node;

  root.ents.Handle = Handle;

  root.ents.Edge = Edge;

  root.ents.Leaf = Leaf;

  root.ents.Lot = Lot;

  root.ents.edges = [];

  root.ents.nodes = [];

  root.ents.handels = [];

  root.ents.all = all;

}).call(this);

/*
//@ sourceMappingURL=entities.map
*/
