fs = require "fs"
async = require "async"
hat = require "hat"
_ = require "lodash"
liburl = require "url"
libpath = require "path"
ws = require "ws"
sys = require "sys"
ProtoBuf = require "protobufjs"

class GameServer
  constructor: ->
    this.reset()
    @protocol = ProtoBuf.loadProtoFile("public/protocol.proto")
    @Commands = @protocol.build("Commands")
    @Command = @protocol.build("Command")
    @PingCommand = @protocol.build("Ping")
    @CommandType = @protocol.build("CommandType")

  reset: ->
    @rooms = {}
    @userSockets = {}
    @socketUsers = {}

  listen: (port) ->
    @ws = new ws.Server({ port: port })

    @ws.on "connection", (socket) =>
      sys.log "connection"

      socket.on "close", =>
        sys.log "closed"

      socket.on "message", (data, flags) =>
        if (flags.binary)
          try
            commands = @Commands.decode(data)

            _.each commands.commands, (command) =>
              this.processIncomingCommand(socket, command)

          catch err
            sys.log "failed parsing message #{err}"

  stats: ->
    { running: true }

  processIncomingCommand: (socket, command) ->
    switch command.type
      when @CommandType.PING
        this.processPing(socket, command)
 
  processPing: (socket, command) ->
    ping = command.ping
    sys.log "PING #{command.timestamp}"
    pongCommand = new @Command(command.type, command.user_id, command.timestamp, command.room_id)
    pongCommand.ping = new @PingCommand((new Date()).getTime())

    this._send(socket, [pongCommand])

  userIdForsocket: (socket) ->
    socketUsers[socket.id]

  _send: (socket, commands) ->
    socket.send((new @Commands(commands)).toBuffer())

module.exports = new GameServer()
