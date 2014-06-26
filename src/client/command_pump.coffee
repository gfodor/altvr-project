class CommandPump
  constructor: (@protocol, @socket) ->
    @ready = false

    @PingCommand = @protocol.build("Ping")
    @Commands = @protocol.build("Commands")
    @Command = @protocol.build("Command")
    @CommandType = @protocol.build("CommandType")

  init: ->
    command = new @Command(@CommandType.PING, 0, (new Date()).getTime(), 0)
    command.ping = new @PingCommand()

    this._send([command])

  push: (command) ->
    return unless @ready

  _send: (commands) ->
    if @socket.readyState == WebSocket.OPEN
      @socket.send((new @Commands(commands)).toArrayBuffer())

window.CommandPump = CommandPump
