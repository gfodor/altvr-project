t = THREE

# Helper class for generating commands. j4
class CommandGenerator
  constructor: (@root, @protocol) ->
    @CommandType = @protocol.build("CommandType")
    @Command = @protocol.build("Command")
    @DrawCommand = @protocol.build("Draw")
    @BoardCreateCommand = @protocol.build("BoardCreate")

  createCommand: (type) ->
    new @Command(type, @root.userId, (new Date()).getTime(), @root.roomId)

  generateJoin: ->
    this.createCommand(@CommandType.JOIN)

  generateErase: ->
    this.createCommand(@CommandType.ERASE)

  generateDraw: (pickedObject, drawState, drawColor) ->
    command = this.createCommand(@CommandType.DRAW)

    # Picked object was a board
    if pickedObject.object.__board?
      # Draw command has boolean determining if this was the last point.
      board = pickedObject.object.__board
      command.board_id = board.id
      endStroke = drawState == U.DRAW_STATE_END
      command.draw = new @DrawCommand(pickedObject.u, pickedObject.v, drawColor, endStroke)
      command
    else
      false

  generateCreateBoard: ->
    player = @root.controls.getObject()

    command = this.createCommand(@CommandType.BOARD_CREATE)
    command.board_create = new @BoardCreateCommand()
    command.board_create.width = 13
    command.board_create.height = 8

    # To determine the new board's position & orientation, we place it a few
    # units away from the camera in the direction of the camera's normal.
    #
    # We also orient it so it is facing towards the user.
    boardPosition = new t.Vector3()

    # Position is camera position + nudge in direction of ray casted from eye
    boardPosition.copy(player.position)
    projector = new t.Projector()
    @root.camera.updateMatrixWorld()
    ray = projector.pickingRay(new t.Vector3(0.0, 0.0, 0.0), @root.camera)
    nudge = new t.Vector3()
    nudge.copy(ray.ray.direction)
    nudge.multiplyScalar(10.0)
    boardPosition.add(nudge)

    command.board_create.x = boardPosition.x
    command.board_create.y = boardPosition.y
    command.board_create.z = boardPosition.z

    # Copy the pitch and yaw
    pitch = @root.controls.getPitchObject().rotation.x
    yaw = @root.controls.getYawObject().rotation.y

    command.board_create.pitch = pitch
    command.board_create.yaw = yaw
    
    command

window.CommandGenerator = CommandGenerator
