class CommandPump
  ENQUEUE_RATE_LIMIT = 50
  FLUSH_RATE = 250

  constructor: (@protocol, @socket, @handler) ->
    @PingCommand = @protocol.build("Ping")
    @Commands = @protocol.build("Commands")
    @Command = @protocol.build("Command")
    @CommandType = @protocol.build("CommandType")
    @clockSkew = 0
    @pendingCommands = []
    @lastEnqueueTime = 0
    @lastFlushTime = 0
    setInterval((=> this.flushIfReady()), 50)

  push: (command, force) ->
    now = ((new Date()).getTime()

    # Enqueue it if we are seeing too many non-forced events (like cursor tracking)
    shouldEnqueue = force || now - @lastEnqueueTime) > ENQUEUE_RATE_LIMIT

    if shouldEnqueue
      # Enqueue it for the server to receive it, and execute it locally
      @lastEnqueueTime = now
      @pendingCommands.push command
      @handler.executeCommand command

    if force
      this.flush()
    else
      this.flushIfReady()

  flushIfReady: ->
    return unless @pendingCommands.length > 0

    if ((new Date()).getTime() - @lastFlushTime ) > FLUSH_RATE
      this.flush()

  flush: ->
    return unless @pendingCommands.length > 0
    return unless @socket.readyState == WebSocket.OPEN

    @lastFlushTime = (new Date()).getTime()
    this._send(@pendingCommands)
    @pendingCommands = []

  _send: (commands) ->
    if @socket.readyState == WebSocket.OPEN
      @socket.send((new @Commands(commands)).toArrayBuffer())

window.CommandPump = CommandPump
