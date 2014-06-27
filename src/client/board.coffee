t = THREE

# Class representing board entity. It contains all the three.js meshes
# as well as an HTML canvas to draw on the board.
class Board
  constructor: (@id, @width, @height, position, yaw, pitch) ->
    this.buildBoardMesh(position, yaw, pitch)

    # Stash a back-reference to the board inside of the mesh
    @mesh.__board = this

    # Create HTML canvas
    @canvas = document.createElement("canvas")
    aspectRatio = @height * 1.0 / (@width * 1.0)
    @canvas.width = 1024
    @canvas.height = 1024.0 * aspectRatio

    true

  buildBoardMesh: (position, yaw, pitch) ->
    @geometry = new t.PlaneGeometry(@width, @height)
    @material = new t.MeshLambertMaterial( { color: "#FFFFFF" } )
    @mesh = new t.Mesh( @geometry, @material )

    # Apply the pitch and yaw properly by applying two rotation matrices
    # in the proper order, first rotate around Y by yaw then 
    # first transform X axis by yaw then rotate by pitch on that axis.
    #
    # Apply matrices in *opposite order* due to matrix multiply.
    axis = new t.Vector3(Math.cos(yaw),0,-Math.sin(yaw))
    @mesh.rotateOnAxis(axis, pitch)
    @mesh.rotateOnAxis(new t.Vector3(0,1,0), yaw)
    @mesh.position.copy(position)

  addToScene: (scene) ->
    scene.add(@mesh)
    this.createPointLight(scene)
    this.createBoardFrame(scene)

  # Each board has a small point light in front of it, so we can see the contents.
  createPointLight: (scene) ->
    @light = new t.PointLight(0xFFFFFF, Math.floor(@width * @height / 10), 10)
    @light.position.copy(@mesh.position)
    this.nudgeFromBoard(@light, 3)
    scene.add(@light)

  # Each board has a wood frame behind it.
  createBoardFrame: (scene) ->
    geometry = new t.BoxGeometry(@width + 0.2, @height + 0.2, 0.2)
    material = new t.MeshLambertMaterial( { map: t.ImageUtils.loadTexture("/images/wood2.jpg") } )
    @frame = new t.Mesh( geometry, material )
    @frame.position.copy(@mesh.position)
    @frame.rotation.copy(@mesh.rotation)
    this.nudgeFromBoard(@frame, -0.15)
    scene.add(@frame)

  # Nudges the specified target along the board's plane normal by the specified amount.
  nudgeFromBoard: (target, amount) ->
    norm = new t.Vector3()
    norm.copy(@geometry.faces[0].normal)
    @mesh.updateMatrixWorld()

    # Transform the normal of the plane and then push the light along it.
    normalMatrix = new t.Matrix3()
    normalMatrix.getNormalMatrix(@mesh.matrixWorld)
    norm.applyMatrix3(normalMatrix)
    norm.multiplyScalar(amount)
    target.position.add(norm)

  # Helper function to draw on the HTML canvas for the board.
  # Callback receives drawing context, width, height
  drawOn: (f) ->
    ctx = @canvas.getContext('2d')
    f(ctx, @canvas.width, @canvas.height)

  # Update the texture on the mesh for the board.
  # Performance intensive, run after finished updating the canvas.
  refresh: ->
    ctx = @canvas.getContext('2d')
    image = new Image()
    ctx.save()
    texture = new t.Texture(ctx.getImageData(0, 0, @canvas.width, @canvas.height))
    texture.needsUpdate = true
    @material.setValues(map: texture)

window.Board = Board
