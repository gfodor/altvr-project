t = THREE

$("body").click ->
  element = $("body")[0]
  element.requestPointerLock = element.requestPointerLock || element.mozRequestPointerLock || element.webkitRequestPointerLock
  element.requestPointerLock()

renderImage = (w, h, f) ->
  canvas = document.createElement("canvas")
  canvas.width = w
  canvas.height = h
  ctx = canvas.getContext('2d')
  f(ctx)
  image = new Image()
  ctx.save()
  image.src = canvas.toDataURL()
  return image

image = renderImage 500, 500, (ctx) ->
  ctx.fillStyle = "#FFFFFF"
  ctx.fillRect(0, 0, 500, 500)
  ctx.fillStyle = "#FF0000"
  ctx.fillRect(50, 50, 100, 100)

scene = new t.Scene()
camera = new t.PerspectiveCamera( 75, window.innerWidth / window.innerHeight, 0.1, 1000 )

renderer = new t.WebGLRenderer()
renderer.setSize( window.innerWidth, window.innerHeight )
document.body.appendChild( renderer.domElement )

light = new t.DirectionalLight(0xFFFFFF, 3)
#light = new t.Mesh( new t.BoxGeometry(2,1,2), new t.MeshLambertMaterial( { color: 0xff0000 } ))
light.position.set(0.0, 20, 4)
light.rotateOnAxis(new t.Vector3(1,0,0), - Math.PI * 0.15)
scene.add(light)

light = new t.AmbientLight(0x202020)
scene.add(light)

geometry = new t.BoxGeometry(10,8,0.1)
texture = new t.Texture(image)
texture.needsUpdate = true
material = new t.MeshLambertMaterial( { map: texture } )
cube = new t.Mesh( geometry, material )
cube.position.y = 12
cube.position.z = -10
scene.add( cube )

material = new t.MeshLambertMaterial( { map: t.ImageUtils.loadTexture("doge.jpeg") } )
floor = new t.Mesh( new t.BoxGeometry(100,0.1,100), material )
floor.position.x = 0
floor.position.y = 0
floor.position.z = 0
scene.add( floor )

clock = new t.Clock()
controls = new t.PointerLockControls(camera)
controls.enabled = true
scene.add(controls.getObject())

render = ->
  delta = clock.getDelta()
  controls.update(delta)
  camera.updateMatrix()
  camera.updateMatrixWorld()

  requestAnimationFrame(render)
  renderer.render(scene, camera)

render()
