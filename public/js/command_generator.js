// Generated by CoffeeScript 1.5.0
(function() {
  var CommandGenerator, t;

  t = THREE;

  CommandGenerator = (function() {

    function CommandGenerator(root, protocol) {
      this.root = root;
      this.protocol = protocol;
      this.CommandType = this.protocol.build("CommandType");
      this.Command = this.protocol.build("Command");
      this.BoardCreateCommand = this.protocol.build("BoardCreate");
    }

    CommandGenerator.prototype.createCommand = function(type) {
      return new this.Command(type, this.root.userId, (new Date()).getTime(), this.root.roomId);
    };

    CommandGenerator.prototype.generateJoin = function() {
      return this.createCommand(this.CommandType.JOIN);
    };

    CommandGenerator.prototype.generateCreateBoard = function() {
      var boardPosition, command, nudge, pitch, player, projector, ray, yaw;
      player = this.root.controls.getObject();
      command = this.createCommand(this.CommandType.BOARD_CREATE);
      command.board_create = new this.BoardCreateCommand();
      command.board_create.width = 13;
      command.board_create.height = 8;
      boardPosition = new t.Vector3();
      boardPosition.copy(player.position);
      projector = new t.Projector();
      this.root.camera.updateMatrixWorld();
      ray = projector.pickingRay(new t.Vector3(0.0, 0.0, 0.0), this.root.camera);
      nudge = new t.Vector3();
      nudge.copy(ray.ray.direction);
      nudge.multiplyScalar(10.0);
      boardPosition.add(nudge);
      command.board_create.x = boardPosition.x;
      command.board_create.y = boardPosition.y;
      command.board_create.z = boardPosition.z;
      pitch = this.root.controls.getPitchObject().rotation.x;
      yaw = this.root.controls.getYawObject().rotation.y;
      command.board_create.pitch = pitch;
      command.board_create.yaw = yaw;
      return command;
    };

    return CommandGenerator;

  })();

  window.CommandGenerator = CommandGenerator;

}).call(this);
