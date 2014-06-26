// Generated by CoffeeScript 1.5.0
(function() {
  var CommandPump;

  CommandPump = (function() {

    function CommandPump(protocol, socket) {
      this.protocol = protocol;
      this.socket = socket;
      this.PingCommand = this.protocol.build("Ping");
      this.Commands = this.protocol.build("Commands");
      this.Command = this.protocol.build("Command");
      this.CommandType = this.protocol.build("CommandType");
      this.clockSkew = 0;
    }

    CommandPump.prototype.init = function() {};

    CommandPump.prototype.push = function(command) {};

    CommandPump.prototype._send = function(commands) {
      if (this.socket.readyState === WebSocket.OPEN) {
        return this.socket.send((new this.Commands(commands)).toArrayBuffer());
      }
    };

    return CommandPump;

  })();

  window.CommandPump = CommandPump;

}).call(this);
