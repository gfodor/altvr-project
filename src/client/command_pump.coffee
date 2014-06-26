class CommandPump
  constructor: (@protocol, @socket) ->
    @PingCommand = @protocol.build("Ping")
    @Commands = @protocol.build("Commands")
    @Command = @protocol.build("Command")
    @CommandType = @protocol.build("CommandType")
    @clockSkew = 0

  init: ->

  push: (command) ->

  _send: (commands) ->
    if @socket.readyState == WebSocket.OPEN
      @socket.send((new @Commands(commands)).toArrayBuffer())

window.CommandPump = CommandPump
