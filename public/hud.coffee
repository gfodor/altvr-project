t = THREE

class HUD
  constructor: ->
    @scene = new t.Scene()
    @camera = new t.OrthographicCamera(window.innerWidth / -2, window.innerWidth / 2, window.innerHeight / 2, window.innerHeight / -2, 1, 1000)
    @scene.add(@camera)

    material = new t.MeshBasicMaterial( { color: "#00FF00" } )
    @reticle = new t.Mesh( new t.PlaneGeometry(5,5), material )
    @reticle.position.z = -10
    @scene.add(@reticle)
    @scene.add(@camera)


window.HUD = HUD
