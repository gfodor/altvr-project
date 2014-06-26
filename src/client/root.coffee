t = THREE

class Root
  ProtoBuf = dcodeIO.ProtoBuf

  constructor: (@renderer, @hud, @userId, @roomId) ->
    @protocol = ProtoBuf.loadProtoFile("/protocol.proto")
    @Commands = @protocol.build("Commands")
    @Command = @protocol.build("Command")
    @PingCommand = @protocol.build("Ping")
    @CommandType = @protocol.build("CommandType")

    @pickedObject = null
    @scene = new t.Scene()
    @camera = new t.PerspectiveCamera( 75, window.innerWidth / window.innerHeight, 0.1, 1000 )
    @boards = []
    @clock = new t.Clock()
    @controls = new t.PointerLockControls(@camera)
    @controls.enabled = false
    @scene.add(@controls.getObject())

  addBoard: (board) ->
    @boards.push(board)

  connect: ->
    @socket = new WebSocket("ws://altvr.lulcards.com:8001/ws")
    @socket.binaryType = "arraybuffer"
    window.pp = @protocol
    @commandPump = new CommandPump(@protocol, @socket)

    @socket.onopen = =>
      @commandPump.init()
      console.log("Connect")
      joinCommand = this.createCommand(@CommandType.JOIN)
      @commandPump._send([joinCommand])

    @socket.onclose = =>
      console.log "Disconnect"

    @socket.onmessage = (e) =>
      try
        commands = @Commands.decode e.data

        _.each commands.commands, (c) =>
          this.processIncomingCommand c, commands.is_bootstrap

      catch err
        console.log "error parsing #{err}"

  processIncomingCommand: (command, isBootstrap) ->
    console.log(command)

    switch command.type
      when @CommandType.PING
        this.processPing(command)
 
  processPing: (command) ->
    # Retain timestamp on message; this is the only server-timestamped message.
    pong = new @Command(command.type, @userId, command.timestamp, @roomId)

    # Response includes client timestamp, for computing skew.
    pong.ping = new @PingCommand(new Date().getTime())
    console.log "PING #{command.timestamp}"
    @commandPump._send([pong])

  createCommand: (type) ->
    new @Command(type, @userId, (new Date()).getTime(), @roomId)

  renderLoop: () ->
    U = window.U
    self = this
    delta = @clock.getDelta()
    @controls.update(delta)

    projector = new t.Projector()
    ray = projector.pickingRay(new t.Vector3(0.0, 0.0, 0.0), @camera)
    isects = ray.intersectObjects((_.map @boards, (b) -> b.mesh), false)

    requestAnimationFrame((-> self.renderLoop()))

    @renderer.autoClear = true
    @renderer.render(@scene, @camera)
    @pickedObject = null

    if isects.length > 0
      obj = isects[0].object
      uv = obj.geometry.faceVertexUvs[0][isects[0].faceIndex]

      vertices = _.map ["a", "b", "c"], (faceName) ->
        v = new t.Vector3()
        v.copy(obj.geometry.vertices[isects[0].face[faceName]])
        obj.localToWorld(v)
        v

      [b1, b2, b3] = U.getBarycentricCoords(ray.ray, vertices[0], vertices[1], vertices[2])
      u = b1 * uv[0].x + b2 * uv[1].x + b3 * uv[2].x
      v = b1 * uv[0].y + b2 * uv[1].y + b3 * uv[2].y

      @pickedObject =
        object: isects[0].object
        u: u,
        v: 1.0 - v

      @renderer.autoClear = false
      @renderer.render(@hud.scene, @hud.camera)
    else
      @pickedObject = null

  attachEvents: ->
    this.setupPointerLockHandler()

    $(document).mousedown =>
      #unless this.isPointerLocked()
        #if pickedObject
          #clickedPoints.push [pickedObject.u, pickedObject.v]
          #updateBoards()

  setupPointerLockHandler: ->
    $(document).mousedown =>
      unless this.isPointerLocked()
        element = $("body")[0]
        element.requestPointerLock = element.requestPointerLock || element.mozRequestPointerLock || element.webkitRequestPointerLock
        element.requestPointerLock()

    pointerLockChangeHandler = =>
      @controls.enabled = this.isPointerLocked()

    _.each ["", "moz", "webkit"], (prefix) ->
      document.addEventListener("#{prefix}pointerlockchange", pointerLockChangeHandler, false)

  isPointerLocked: ->
    el = $("body")[0]
    document.pointerLockElement == el || document.mozPointerLockElement == el || document.webkitPointerLockElement == el

#updateBoards = ->
#  for board in boards
#    board.draw (ctx, width, height) ->
#      ctx.fillStyle = "#FFFFFF"
#      ctx.fillRect(0, 0, width, height)
#
#      _.each clickedPoints, (point) ->
#        ctx.fillStyle = "#FF0000"
#        ctx.fillRect(Math.floor(point[0] * width), Math.floor(point[1] * height), 10, 10)
#
#updateBoards()

window.Root = Root
