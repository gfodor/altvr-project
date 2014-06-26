// Generated by CoffeeScript 1.5.0
(function() {
  var Root, t;

  t = THREE;

  Root = (function() {
    var ProtoBuf;

    ProtoBuf = dcodeIO.ProtoBuf;

    function Root(renderer, hud, userId, roomId) {
      this.renderer = renderer;
      this.hud = hud;
      this.userId = userId;
      this.roomId = roomId;
      this.protocol = ProtoBuf.loadProtoFile("/protocol.proto");
      this.Commands = this.protocol.build("Commands");
      this.Command = this.protocol.build("Command");
      this.PingCommand = this.protocol.build("Ping");
      this.CommandType = this.protocol.build("CommandType");
      this.pickedObject = null;
      this.scene = new t.Scene();
      this.camera = new t.PerspectiveCamera(75, window.innerWidth / window.innerHeight, 0.1, 1000);
      this.boards = [];
      this.clock = new t.Clock();
      this.controls = new t.PointerLockControls(this.camera);
      this.controls.enabled = false;
      this.scene.add(this.controls.getObject());
    }

    Root.prototype.addBoard = function(board) {
      return this.boards.push(board);
    };

    Root.prototype.connect = function() {
      var _this = this;
      this.socket = new WebSocket("ws://altvr.lulcards.com:8001/ws");
      this.socket.binaryType = "arraybuffer";
      window.pp = this.protocol;
      this.commandPump = new CommandPump(this.protocol, this.socket);
      this.socket.onopen = function() {
        var joinCommand;
        _this.commandPump.init();
        console.log("Connect");
        joinCommand = _this.createCommand(_this.CommandType.JOIN);
        return _this.commandPump._send([joinCommand]);
      };
      this.socket.onclose = function() {
        return console.log("Disconnect");
      };
      return this.socket.onmessage = function(e) {
        var commands;
        try {
          commands = _this.Commands.decode(e.data);
          return _.each(commands.commands, function(c) {
            return _this.processIncomingCommand(c, commands.is_bootstrap);
          });
        } catch (err) {
          return console.log("error parsing " + err);
        }
      };
    };

    Root.prototype.processIncomingCommand = function(command, isBootstrap) {
      console.log(command);
      switch (command.type) {
        case this.CommandType.PING:
          return this.processPing(command);
      }
    };

    Root.prototype.processPing = function(command) {
      var pong;
      pong = new this.Command(command.type, this.userId, command.timestamp, this.roomId);
      pong.ping = new this.PingCommand(new Date().getTime());
      console.log("PING " + command.timestamp);
      return this.commandPump._send([pong]);
    };

    Root.prototype.createCommand = function(type) {
      return new this.Command(type, this.userId, (new Date()).getTime(), this.roomId);
    };

    Root.prototype.renderLoop = function() {
      var U, b1, b2, b3, delta, isects, obj, projector, ray, self, u, uv, v, vertices, _ref;
      U = window.U;
      self = this;
      delta = this.clock.getDelta();
      this.controls.update(delta);
      projector = new t.Projector();
      ray = projector.pickingRay(new t.Vector3(0.0, 0.0, 0.0), this.camera);
      isects = ray.intersectObjects(_.map(this.boards, function(b) {
        return b.mesh;
      }), false);
      requestAnimationFrame((function() {
        return self.renderLoop();
      }));
      this.renderer.autoClear = true;
      this.renderer.render(this.scene, this.camera);
      this.pickedObject = null;
      if (isects.length > 0) {
        obj = isects[0].object;
        uv = obj.geometry.faceVertexUvs[0][isects[0].faceIndex];
        vertices = _.map(["a", "b", "c"], function(faceName) {
          var v;
          v = new t.Vector3();
          v.copy(obj.geometry.vertices[isects[0].face[faceName]]);
          obj.localToWorld(v);
          return v;
        });
        _ref = U.getBarycentricCoords(ray.ray, vertices[0], vertices[1], vertices[2]), b1 = _ref[0], b2 = _ref[1], b3 = _ref[2];
        u = b1 * uv[0].x + b2 * uv[1].x + b3 * uv[2].x;
        v = b1 * uv[0].y + b2 * uv[1].y + b3 * uv[2].y;
        this.pickedObject = {
          object: isects[0].object,
          u: u,
          v: 1.0 - v
        };
        this.renderer.autoClear = false;
        return this.renderer.render(this.hud.scene, this.hud.camera);
      } else {
        return this.pickedObject = null;
      }
    };

    Root.prototype.attachEvents = function() {
      var _this = this;
      this.setupPointerLockHandler();
      return $(document).mousedown(function() {});
    };

    Root.prototype.setupPointerLockHandler = function() {
      var pointerLockChangeHandler,
        _this = this;
      $(document).mousedown(function() {
        var element;
        if (!_this.isPointerLocked()) {
          element = $("body")[0];
          element.requestPointerLock = element.requestPointerLock || element.mozRequestPointerLock || element.webkitRequestPointerLock;
          return element.requestPointerLock();
        }
      });
      pointerLockChangeHandler = function() {
        return _this.controls.enabled = _this.isPointerLocked();
      };
      return _.each(["", "moz", "webkit"], function(prefix) {
        return document.addEventListener("" + prefix + "pointerlockchange", pointerLockChangeHandler, false);
      });
    };

    Root.prototype.isPointerLocked = function() {
      var el;
      el = $("body")[0];
      return document.pointerLockElement === el || document.mozPointerLockElement === el || document.webkitPointerLockElement === el;
    };

    return Root;

  })();

  window.Root = Root;

}).call(this);
