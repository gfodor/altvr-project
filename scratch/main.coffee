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
hudScene = new t.Scene()
camera = new t.PerspectiveCamera( 75, window.innerWidth / window.innerHeight, 0.1, 1000 )
hudCamera = new t.OrthographicCamera(window.innerWidth / -2, window.innerWidth / 2, window.innerHeight / 2, window.innerHeight / -2, 1, 1000)
hudScene.add(hudCamera)

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

geometry = new t.PlaneGeometry(13,8)
texture = new t.Texture(image)
texture.needsUpdate = true
material = new t.MeshLambertMaterial( { map: texture } )
board = new t.Mesh( geometry, material )
board.position.y = 12
board.position.z = -10
board.rotateOnAxis(new t.Vector3(0,1,0), 0.4)
scene.add( board )

boards = [board]

material = new t.MeshLambertMaterial( { map: t.ImageUtils.loadTexture("doge.jpeg") } )
floor = new t.Mesh( new t.PlaneGeometry(100,100), material )
floor.rotateOnAxis(new t.Vector3(1,0,0), - Math.PI / 2.0)
floor.position.x = 0
floor.position.y = 0
floor.position.z = 0
scene.add( floor )

clock = new t.Clock()
controls = new t.PointerLockControls(camera)
controls.enabled = true
scene.add(controls.getObject())

material = new t.MeshBasicMaterial( { color: "#00FF00" } )
hud = new t.Mesh( new t.PlaneGeometry(5,5), material )
hud.position.z = -10
hudScene.add(hud)
hudScene.add(hudCamera)
foo = true

getBarycentricCoords = (ray, p0, p1, p2) ->
  e1 = new t.Vector3()
  e1.subVectors(p1, p0)
  e2 = new t.Vector3()
  e2.subVectors(p2, p0)
  s = new t.Vector3()
  s.subVectors(ray.origin, p0)
  s1 = new t.Vector3()
  s1.crossVectors(ray.direction, e2)
  s2 = new t.Vector3()
  s2.crossVectors(s, e1)
  divisor = s1.dot(e1)
  b1 = s1.dot(s) / divisor
  b2 = s2.dot(ray.direction) / divisor
  [1.0 - b1 - b2, b1, b2]

render = ->
  delta = clock.getDelta()
  controls.update(delta)

  projector = new t.Projector()
  ray = projector.pickingRay(new t.Vector3(0.0, 0.0, 0.0), camera)
  isects = ray.intersectObjects(boards, false)

  requestAnimationFrame(render)
  renderer.autoClear = true
  renderer.render(scene, camera)

  if isects.length > 0
    obj = isects[0].object
    uv = obj.geometry.faceVertexUvs[0][isects[0].faceIndex]
    v1 = new t.Vector3()
    v1.copy(obj.geometry.vertices[isects[0].face.a])
    obj.localToWorld(v1)
    v2 = new t.Vector3()
    v2.copy(obj.geometry.vertices[isects[0].face.b])
    obj.localToWorld(v2)
    v3 = new t.Vector3()
    v3.copy(obj.geometry.vertices[isects[0].face.c])
    obj.localToWorld(v3)

    [b1, b2, b3] = getBarycentricCoords(ray.ray, v1, v2, v3)
    u = b1 * uv[0].x + b2 * uv[1].x + b3 * uv[2].x
    v = b1 * uv[0].y + b2 * uv[1].y + b3 * uv[2].y

    renderer.autoClear = false
    renderer.render(hudScene, hudCamera)

render()
