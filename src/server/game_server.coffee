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
    @roomData = {}

    @allSockets = []
    setInterval((=> this.pingConnectedClients()), 15000)
    setInterval((=> this.flushAllUsers()), 250)

  # Starts listening for connections.
  listen: (port) ->
    @ws = new ws.Server({ port: port })

    @ws.on "connection", (socket) =>
      @allSockets.push socket

      # When a new socket connects, send a ping
      this.pingClient(socket)
      
      sys.log "connection now #{@allSockets.length}"

      socket.on "close", =>
        # When socket closes, leave all rooms and remove from socket lookup tables
        userId = this.userIdForSocket(socket)

        if userId?
          this.leaveAllRooms(userId)
          delete @userSockets[userId]
          delete @userData[userId]

          # TODO after last person leaves a room, after some time clean up room

        @allSockets.splice(@allSockets.indexOf(socket), 1)

        sys.log "closed user #{userId} remaining: #{@allSockets.length}"

      socket.on "message", (data, flags) =>
        if (flags.binary)
          commands = @Commands.decode(data)

          _.each commands.commands, (command) =>
            this.processIncomingCommand(socket, command)


  pingConnectedClients: ->
    for socket in @allSockets
      this.pingClient(socket)

  pingClient: (socket) ->
    # Ping commands originate on the server, so their timestamps are 
    # server based. The latency is determined by checking timestamp deltas.
    pingCommand = new @Command(@CommandType.PING, 0, (new Date()).getTime(), 0)
    pingCommand.ping = new @PingCommand()
    this._send(socket, [pingCommand])

  associateUserWithSocket: (userId, socket) ->
    @userSockets[userId] ?= socket

  processIncomingCommand: (socket, command) ->
    this.associateUserWithSocket(command.user_id, socket)

    if command.type == @CommandType.PING
      this.processPing(socket, command)
    else
      this.withRoomAndUserData command, (roomData, userData) =>
        # Adjust timestamp based upon latency
        if userData? && userData.latency?
          command.timestamp += (new Date()).getTime() - userData.latency

        switch command.type
          when @CommandType.JOIN
            this.processJoin(socket, command)

        if command.board_id?
          board = this.boardDataForBoardId(command.board_id, roomData.roomId)

          if board?
            board.commands.push command
        else
          roomData.commands.push command

        this.broadcastCommandToRoom(command, roomData.roomId)

  boardDataForBoardId: (boardId, roomId) ->
    roomData = this.roomDataForRoomId(roomId)
    roomData.boardData[boardId] ?=
      commands: []

  leaveAllRooms: (userId) ->
    sys.log "#{userId} leaves all rooms"

    for roomId, roomData of @roomData
      delete roomData.users[userId]

  processJoin: (socket, command) ->
    this.withRoomAndUserData command, (roomData, userData) =>
      sys.log "#{userData.userId} joined #{roomData.roomId}"
      roomData.users[userData.userId] = true

      # Build bootstrap commands by aggregating the room-level commands
      # and the commands for each board, and then sorting by timestamp.
      commands = []

      for command in roomData.commands
        commands.push command

      for boardId, boardData of roomData.boardData
        for command in boardData.commands
          commands.push command

      commands.sort (x, y) ->
        x.timestamp - y.timestamp

      this._send(socket, commands, true)

  processPing: (socket, command) ->
    ping = command.ping
    sys.log "PONG #{command.timestamp}"

    userData = this.userDataForUserId(command.user_id)
    now = (new Date()).getTime()

    # Roundtrip latency estimated as difference between now and
    # original server timestamp.
    userData.latency = now - command.timestamp

    # Clock skew estimated as difference in timestamps sans one-way
    # latency. (Since client timestamp is generated after receiving message.)
    # (unused right now.)
    userData.skew = now - ping.client_timestamp - (userData.latency / 2)

  # Broadcasts a command to everyone in the room by pushing it onto
  # the users' outgoing command queues.
  broadcastCommandToRoom: (command, roomId) ->
    roomData = this.roomDataForRoomId(roomId)

    for userId, flag of roomData.users
      userData = this.userDataForUserId(userId)
      userData.outgoingCommands.push command
 
  # Flush the command queues to all users.
  flushAllUsers: ->
    for userId, userData of @userData
      this.flushCommandsForUser(userId)

  # Flush the commands of the specified user.
  flushCommandsForUser: (userId) ->
    socket = @userSockets[userId]
    userData = this.userDataForUserId(userId)

    if socket? && userData.outgoingCommands.length > 0
      this._send(socket, userData.outgoingCommands)
      userData.outgoingCommands = []

  _send: (socket, commands, isBootstrap) ->
    return unless commands.length > 0
    return unless socket.readyState == ws.OPEN

    socket.send((new @Commands(commands, isBootstrap)).toBuffer())

  # Look up the user id for a socket.
  userIdForSocket: (socket) ->
    for userId, s of @userSockets
      return userId if s == socket

  # Get the user data for a user id.
  # User data includes their outgoing command queue.
  userDataForUserId: (userId) ->
    @userData[userId] ?=
      userId: userId
      outgoingCommands: []

    @userData[userId]

  # Gets the room data for a given room.
  #
  # Room data includes who is in the room, what room-level commands
  # have been done so far (adding boards, people joining) and the list
  # of boards in the room.
  roomDataForRoomId: (roomId) ->
    @roomData[roomId] ?= roomId: roomId, users: {}, boardData: {}, commands: []

  # Looks up the room & user for the message and passes it forward to the callback
  withRoomAndUserData: (message, callback) ->
    userData = this.userDataForUserId(message.user_id)
    roomData = this.roomDataForRoomId(message.room_id)
    callback(roomData, userData)

module.exports = new GameServer()
