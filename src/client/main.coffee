t = THREE

renderer = new t.WebGLRenderer()
renderer.setSize( window.innerWidth, window.innerHeight )
document.body.appendChild( renderer.domElement )

protocol = dcodeIO.ProtoBuf.loadProtoFile("/protocol.proto")

hud = new HUD(protocol)
root = new Root(protocol, renderer, hud, window._userId, window._roomId)
root.attachEvents()
root.connect()

room = new Room()
room.addToScene(root.scene)

root.render()
