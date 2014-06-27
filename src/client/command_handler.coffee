t = THREE

class CommandHandler
  ProtoBuf = dcodeIO.ProtoBuf

  constructor: (@root, @protocol) ->
    @protocol = ProtoBuf.loadProtoFile("/protocol.proto")
    @CommandType = @protocol.build("CommandType")

  executeCommand: (command, localExecution) ->
    switch command.type
      when @CommandType.BOARD_CREATE
        {width, height, x, y, z, pitch, yaw} = command.board_create
        board_id = command.board_id

        board = new Board(board_id, width, height, new t.Vector3(x, y, z), yaw, pitch)
        board.addToScene(@root.scene)
        board.drawOn (ctx, width, height) ->
          ctx.fillStyle = "#FFFFFF"
          ctx.fillRect(0, 0, width, height)

        @root.addBoard(board)
      when @CommandType.DRAW
        board = @root.getBoard(command.board_id)

        if board
          board.drawOn (ctx, width, height) ->
            ctx.fillStyle = "#FF0000"
            ctx.fillRect(Math.floor(command.draw.x * width), Math.floor(command.draw.y * height), 10, 10)

          board.refresh() if localExecution

window.CommandHandler = CommandHandler
