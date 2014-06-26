t = THREE

class Room
  constructor: (scene) ->
    @light = new t.AmbientLight(0x606060)

    material = new t.MeshLambertMaterial( { map: t.ImageUtils.loadTexture("/images/doge.jpeg") } )
    @floor = new t.Mesh( new t.PlaneGeometry(100,100), material )
    @floor.rotateOnAxis(new t.Vector3(1,0,0), - Math.PI / 2.0)

  addToScene: (scene) ->
    scene.add(@light)
    scene.add(@floor)

window.Room = Room
