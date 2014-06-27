t = THREE

class CommandHandler
  ProtoBuf = dcodeIO.ProtoBuf

  constructor: (@root, @protocol) ->
    @protocol = ProtoBuf.loadProtoFile("/protocol.proto")
    @strokeBuffer = {}
    @CommandType = @protocol.build("CommandType")
    @Color = @protocol.build("Color")

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
      when @CommandType.ERASE
        board = @root.getBoard(command.board_id)

        if board
          board.drawOn (ctx, width, height) ->
            ctx.fillStyle = "#FFFFFF"
            ctx.fillRect(0, 0, width, height)

          board.refresh()

      when @CommandType.DRAW
        board = @root.getBoard(command.board_id)

        if board
          # Queue up three points and draw curve
          userId = command.user_id
          boardId = command.board_id

          @strokeBuffer[userId] ?= {}
          @strokeBuffer[userId][boardId] ?= []
          @strokeBuffer[userId][boardId].push [command.draw.x, command.draw.y]

          points = @strokeBuffer[userId][boardId]

          if points.length == 3 || command.draw.end_stroke
            if command.draw.end_stroke
              @strokeBuffer[userId][boardId] = []
            else
              @strokeBuffer[userId][boardId] = [points[points.length - 1]]

              board.drawOn (ctx, width, height) =>
                ctx.lineWidth = 4

                switch command.draw.color
                  when @Color.RED
                    ctx.strokeStyle = "#FF0000"
                  when @Color.GREEN
                    ctx.strokeStyle = "#00FF00"
                  when @Color.BLUE
                    ctx.strokeStyle = "#0000FF"
                  else
                    ctx.strokeStyle = "#000000"

                ctx.beginPath()

                if points.length == 3
                  midX = (points[1][0] + points[2][0]) / 2
                  midY = (points[1][1] + points[2][1]) / 2

                  ctx.moveTo(Math.floor(points[0][0] * width), Math.floor(points[0][1] * height))
                  ctx.quadraticCurveTo(Math.floor(midX * width),
                                       Math.floor(midY * height),
                                       Math.floor(points[2][0] * width),
                                       Math.floor(points[2][1] * height))

                ctx.stroke()

          board.refresh() if localExecution

window.CommandHandler = CommandHandler
