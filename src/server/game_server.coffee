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
    @protocol = ProtoBuf.loadProtoFile("public/protocol.proto")
    @Commands = @protocol.build("Commands")
    @Command = @protocol.build("Command")
    @PingCommand = @protocol.build("Ping")
    @CommandType = @protocol.build("CommandType")

    @rooms = {}
    @userData = {}
    @userSockets = {}
    @allSockets = []
    setInterval((=> this.pingConnectedClients()), 3000)

  listen: (port) ->
    @ws = new ws.Server({ port: port })

    @ws.on "connection", (socket) =>
      @allSockets.push socket
      
      sys.log "connection now #{@allSockets.length}"

      socket.on "close", =>
        userId = this.userIdForSocket(socket)

        if userId?
          delete @userSockets[userId]
          delete @userData[userId]

        @allSockets.splice(@allSockets.indexOf(socket), 1)

        sys.log "closed user #{userId} remaining: #{@allSockets.length}"

      socket.on "message", (data, flags) =>
        if (flags.binary)
          try
            commands = @Commands.decode(data)

            _.each commands.commands, (command) =>
              this.processIncomingCommand(socket, command)

          catch err
            sys.log "failed parsing message #{err}"

  pingConnectedClients: ->
    for socket in @allSockets
      pingCommand = new @Command(@CommandType.PING, 0, (new Date()).getTime(), 0)
      pingCommand.ping = new @PingCommand()
      this._send(socket, [pingCommand])

  stats: ->
    { running: true }

  associateUserWithSocket: (userId, socket) ->
    @userSockets[userId] ?= socket

  processIncomingCommand: (socket, command) ->
    this.associateUserWithSocket(command.user_id, socket)

    switch command.type
      when @CommandType.PING
        this.processPing(socket, command)
 
  processPing: (socket, command) ->
    ping = command.ping
    sys.log "PONG #{command.timestamp}"

    userData = this.userDataForCommand(command)
    now = (new Date()).getTime()

    # Roundtrip latency estimated as difference between now and
    # original server timestamp.
    latency = now - command.timestamp

    # Clock skew estimated as difference in timestamps sans one-way
    # latency. (Since client timestamp is generated after receiving message.)
    skew = now - ping.client_timestamp - (latency / 2)

    sys.log "latency: #{latency} skew: #{skew}"

    # Policy is that messages that are timestamped on the client need to be
    # adjusted by +delta to adjust for latency and clock skew.
    userData.delta = Math.floor(latency + skew)

  userIdForSocket: (socket) ->
    for userId, s of @userSockets
      return userId if s == socket

  userDataForUserId: (userId) ->
    @userData[userId] ?= userId: userId

  userDataForCommand: (command) ->
    this.userDataForUserId(command.user_id)

  _send: (socket, commands) ->
    socket.send((new @Commands(commands)).toBuffer())

module.exports = new GameServer()
