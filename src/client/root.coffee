t = THREE

class Root
  constructor: (@protocol, @renderer, @hud, @userId, @roomId) ->
    @Commands = @protocol.build("Commands")
    @Command = @protocol.build("Command")
    @PingCommand = @protocol.build("Ping")
    @CommandType = @protocol.build("CommandType")
    @Color = @protocol.build("Color")

    @pickedObject = null
    @drawState = U.DRAW_STATE_NONE
    @scene = new t.Scene()
    @camera = new t.PerspectiveCamera( 75, window.innerWidth / window.innerHeight, 0.1, 1000 )
    @boards = []
    @clock = new t.Clock()
    @controls = new t.PointerLockControls(@camera)
    @controls.enabled = false
    @scene.add(@controls.getObject())
    this.setDrawColor(@Color.BLACK)

  addBoard: (board) ->
    @boards.push(board)

  getBoard: (boardId) ->
    for board in @boards
      return board if board.id == boardId

    return null

  setDrawColor: (drawColor) ->
    @drawColor = drawColor
    @hud.setReticleColor(@drawColor)

  connect: ->
    @socket = new WebSocket("ws://altvr.lulcards.com:8001/ws")
    @socket.binaryType = "arraybuffer"
    window.pp = @protocol

    @commandHandler = new CommandHandler(this)
    @commandPump = new CommandPump(@protocol, @socket, @commandHandler)
    @commandGenerator = new CommandGenerator(this, @protocol)

    @socket.onopen = =>
      console.log("Connect")
      joinCommand = @commandGenerator.generateJoin()
      @commandPump._send([joinCommand])

    @socket.onclose = =>
      console.log "Disconnect"

    @socket.onmessage = (e) =>
      commands = @Commands.decode e.data

      _.each commands.commands, (c) =>
        # When bootstrapping up scene, do not regenerate texture on boards until end so it's not slow.
        this.processIncomingCommand c, commands.is_bootstrap

      for board in @boards
        board.refresh()

  processIncomingCommand: (command, isBootstrap) ->
    switch command.type
      when @CommandType.PING
        this.processPing(command)
      else
        # Skip incoming commands that we performed since bootstrap period,
        # since (for now) these are always broadcast to the entire room.
        requiresServer = U.requiresServerResponse(@CommandType, command)

        if isBootstrap || requiresServer || command.user_id != @userId
          @commandHandler.executeCommand(command)
        else
          # Echo
 
  processPing: (command) ->
    # Retain timestamp on message; this is the only server-timestamped message.
    pong = new @Command(command.type, @userId, command.timestamp, @roomId)

    # Response includes client timestamp, for computing skew.
    pong.ping = new @PingCommand(new Date().getTime())
    console.log "PING #{command.timestamp}"
    @commandPump._send([pong])

  render: () ->
    U = window.U
    self = this
    delta = @clock.getDelta()
    @controls.update(delta)

    projector = new t.Projector()
    ray = projector.pickingRay(new t.Vector3(0.0, 0.0, 0.0), @camera)
    isects = ray.intersectObjects((_.map @boards, (b) -> b.mesh), false)

    requestAnimationFrame((-> self.render()))

    @renderer.autoClear = true
    @renderer.render(@scene, @camera)
    @pickedObject = null

    if isects.length > 0
      # Determine u,v coordinates by finding barycentric triangle coords
      # and then interpolating the u,v at the vertices
      #
      # The (u,-v) coordinate is the (x,y) coordinate on the canvas to draw
      # and is what we record to the server.
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

      if @drawState != U.DRAW_STATE_NONE
        command = @commandGenerator.generateDraw(@pickedObject, @drawState, @drawColor)

        if command
          # Force the command to the server unless we're in mid-stroke
          @commandPump.push(command, @drawState != U.DRAW_STATE_DURING)

        # If the user lifted the mouse, we're in END, so end the drawing
        unless @drawState == U.DRAW_STATE_END
          @drawState = U.DRAW_STATE_DURING
        else
          @drawState = U.DRAW_STATE_NONE

      @renderer.autoClear = false
      @renderer.render(@hud.scene, @hud.camera)
    else
      @pickedObject = null

  attachEvents: ->
    this.setupPointerLockHandler()

    $(document).keypress (e) =>
      this.handleKeyPress(e.which)

    $(document).mousedown =>
      @drawState = U.DRAW_STATE_START if this.isPointerLocked()

    $(document).mouseup =>
      @drawState = U.DRAW_STATE_END unless @drawState == U.DRAW_STATE_NONE

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

  handleKeyPress: (keyCode) ->
    switch keyCode
      when 98 # B, create board
        command = @commandGenerator.generateCreateBoard()
        @commandPump.push(command, true)
      when 99 # C, rotate color
        colors = [@Color.BLACK, @Color.RED, @Color.GREEN, @Color.BLUE]
        newDrawColor = colors[(_.indexOf(colors, @drawColor) + 1) % colors.length]
        this.setDrawColor(newDrawColor)
      when 101 # E, erase board
        console.log "hi"
        if @pickedObject && @pickedObject.object.__board?
          console.log @pickedObject
          command = @commandGenerator.generateErase()
          board = @pickedObject.object.__board
          command.board_id = board.id
          @commandPump.push(command, true)

window.Root = Root
