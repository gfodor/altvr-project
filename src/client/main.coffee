t = THREE

renderer = new t.WebGLRenderer()
renderer.setSize( window.innerWidth, window.innerHeight )
document.body.appendChild( renderer.domElement )

hud = new HUD()
root = new Root(renderer, hud, window._userId, window._roomId)
root.attachEvents()
root.connect()

room = new Room()
room.addToScene(root.scene)

board = new Board(13, 8, new t.Vector3(0, 12, -10), 0.1, 0.0)
board.addToScene(root.scene)
root.addBoard(board)
board = new Board(13, 8, new t.Vector3(-14, 12, 5), Math.PI * 0.4, 0.4)
board.addToScene(root.scene)
root.addBoard(board)
board = new Board(8, 5, new t.Vector3(14, 5, 5), -Math.PI * 0.4, -0.4)
board.addToScene(root.scene)
root.addBoard(board)

root.renderLoop()
