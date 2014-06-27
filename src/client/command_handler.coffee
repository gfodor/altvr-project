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
        board = new Board(width, height, new t.Vector3(x, y, z), pitch, yaw)
        board.addToScene(@root.scene)
        @root.addBoard(board)

window.CommandHandler = CommandHandler
