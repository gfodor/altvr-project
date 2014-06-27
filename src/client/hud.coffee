t = THREE

# The HUD just shows a small reticle with the currently active draw color.
class HUD
  constructor: (@protocol) ->
    @scene = new t.Scene()
    @camera = new t.OrthographicCamera(window.innerWidth / -2, window.innerWidth / 2, window.innerHeight / 2, window.innerHeight / -2, 1, 1000)
    @scene.add(@camera)

    @material = new t.MeshBasicMaterial( { color: "#00FF00" } )
    @reticle = new t.Mesh( new t.PlaneGeometry(5,5), @material )
    @reticle.position.z = -10
    @scene.add(@reticle)
    @scene.add(@camera)
    @Color = @protocol.build("Color")

  setReticleColor: (color) ->
    switch color
      when @Color.RED
        @material.setValues(color: "#FF0000")
      when @Color.BLUE
        @material.setValues(color: "#0000FF")
      when @Color.GREEN
        @material.setValues(color: "#00FF00")
      else
        @material.setValues(color: "#000000")


window.HUD = HUD
