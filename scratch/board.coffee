t = THREE

class Board
  constructor: (scene, width, height, position, yaw, pitch) ->
    @geometry = new t.PlaneGeometry(width, height)
    @material = new t.MeshLambertMaterial( { color: "#FFFFFF" } )
    @mesh = new t.Mesh( @geometry, @material )
    @mesh.position.copy(position)
    @mesh.rotateOnAxis(new t.Vector3(0,1,0), yaw)
    @mesh.rotateOnAxis(new t.Vector3(1,0,0), pitch)
    @canvas = document.createElement("canvas")
    aspectRatio = height * 1.0 / (width * 1.0)
    @canvas.width = 1024
    @canvas.height = 1024.0 * aspectRatio

    scene.add(@mesh)

  draw: (f) ->
    ctx = @canvas.getContext('2d')
    f(ctx, @canvas.width, @canvas.height)
    image = new Image()
    ctx.save()
    image.src = @canvas.toDataURL()

    texture = new t.Texture(image)
    texture.needsUpdate = true
    @material.setValues(map: texture)

window.Board = Board
