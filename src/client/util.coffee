t = THREE

window.U = U = {}

# 3-state flag for drawing, we force the event to the server on the first
# and last draw just so the ends of the drawing are exact.
U.DRAW_STATE_NONE = 0
U.DRAW_STATE_START = 1
U.DRAW_STATE_DURING = 2
U.DRAW_STATE_END = 3

# Determines if this command must round-trip to the server, or if it can
# be fired immediatelly locally. Create board requires the server assign
# the board an id, so there must be a round trip.
U.requiresServerResponse = (commandType, command) ->
  return true if command.type == commandType.BOARD_CREATE
  return false

U.getBarycentricCoords = (ray, p0, p1, p2) ->
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

