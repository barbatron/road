// Generated by CoffeeScript 1.6.2
(function() {
  var Edge, Handle, Node, Road, makeRoad, root;

  root = this;

  Node = (function() {
    function Node(pos, target) {
      this.pos = pos;
      if (target == null) {
        target = null;
      }
      this.handels = [];
      if (target != null) {
        new Handle(this, target);
      }
      layers.node.drawNode(this);
      layers.nodeSnap.addNodeSnapper(this);
    }

    Node.prototype.addHandle = function(handle) {
      if (this.handels.indexOf(handle === -1)) {
        this.handels.push(handle);
        this.handels.push(handle.inverse);
      }
      return handleqqqqqq;
    };

    Node.prototype.over = function(e) {
      var _base;

      if (typeof (_base = tools.current).over === "function") {
        _base.over(this, e);
      }
      return console.log("in", this);
    };

    Node.prototype.out = function(e) {
      var _base;

      if (typeof (_base = tools.current).out === "function") {
        _base.out(this, e);
      }
      layers.tool.clear();
      return console.log("out", this);
    };

    return Node;

  })();

  Handle = (function() {
    function Handle(node, pos, inverse) {
      this.node = node;
      this.pos = pos;
      this.inverse = inverse != null ? inverse : null;
      this.line = L(this.node.pos, this.pos);
      console.log(this.node, this.pos);
      this.edges = [];
      if (this.inverse == null) {
        this.inverse = new Handle(this.node, this.line.grow(-1).p1, this);
      }
      this.draw();
      this.node.addHandle(this);
    }

    Handle.prototype.draw = function() {
      return layers.main.drawHandle(this);
    };

    Handle.prototype.addEdge = function(edge) {
      return this.edges.push(edge);
    };

    return Handle;

  })();

  Edge = (function() {
    function Edge(from, to) {
      this.from = from;
      this.to = to;
      this.line = L(this.from.node.pos, this.to.node.pos);
      this.from.addEdge(this);
      this.to.addEdge(this);
    }

    return Edge;

  })();

  Road = (function() {
    var defaults;

    defaults = {
      color: "#777"
    };

    function Road(edge, shape, opt) {
      this.edge = edge;
      this.shape = shape;
      this.opt = opt;
      this.opt = _.defaults(this.opt, defaults);
      this.draw();
    }

    Road.prototype.draw = function() {
      return layers.main["drawRoad" + this.shape](this);
    };

    return Road;

  })();

  makeRoad = function(oldHandle, end, target, curve) {
    var edge, newHandle, newNode, shape;

    if (curve == null) {
      curve = null;
    }
    newNode = new Node(end);
    newHandle = new Handle(newNode, target);
    edge = new Edge(oldHandle, newHandle);
    if (curve != null) {
      shape = "Curve";
    } else {
      shape = "Line";
    }
    new Road(edge, shape, {
      curve: curve
    });
    return newHandle.inverse;
  };

  root.ents = {};

  root.ents.makeRoad = makeRoad;

  root.ents.Node = Node;

  root.ents.Handle = Handle;

}).call(this);
