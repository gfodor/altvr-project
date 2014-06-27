t = THREE

class CommandGenerator
  constructor: (@root, @protocol) ->
    @CommandType = @protocol.build("CommandType")
    @Command = @protocol.build("Command")
    @BoardCreateCommand = @protocol.build("BoardCreate")

  createCommand: (type) ->
    new @Command(type, @root.userId, (new Date()).getTime(), @root.roomId)

  generateJoin: ->
    this.createCommand(@CommandType.JOIN)

  generateCreateBoard: ->
    player = @root.controls.getObject()

    command = this.createCommand(@CommandType.BOARD_CREATE)
    command.board_create = new @BoardCreateCommand()
    command.board_create.width = 13
    command.board_create.height = 8
    command.board_create.x = player.position.x
    command.board_create.y = player.position.y
    command.board_create.z = player.position.z

    command.board_create.pitch = @root.controls.getPitchObject().rotation.x
    command.board_create.yaw = @root.controls.getYawObject().rotation.y
    
    command

window.CommandGenerator = CommandGenerator
