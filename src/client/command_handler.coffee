t = THREE

class CommandHandler
  ProtoBuf = dcodeIO.ProtoBuf

  constructor: (@root, @protocol) ->
    @protocol = ProtoBuf.loadProtoFile("/protocol.proto")
    @CommandType = @protocol.build("CommandType")

  executeCommand: (command) ->
    switch command.type
      when @CommandType.BOARD_CREATE
        {width, height, x, y, z, pitch, yaw} = command.board_create
        board_id = command.board_id

        board = new Board(board_id, width, height, new t.Vector3(x, y, z), yaw, pitch)
        board.addToScene(@root.scene)
        @root.addBoard(board)
      when @CommandType.DRAW
        #console.log("draw: #{command.user_id} #{command.board_id} #{command.draw.x} #{command.draw.y} #{command.draw.end_stroke}")

window.CommandHandler = CommandHandler