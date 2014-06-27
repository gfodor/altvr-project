express = require "express"
hat = require "hat"
fs = require "fs"
url = require "url"
_ = require "lodash"

#PhorkWriter = require '../../lib/phork_writer'

module.exports = app = express()

#temp.track()

#app.use express.urlencoded()
#app.use express.json()
#app.use express.compress()

app.use "/", express.static("public")
app.set 'view engine', 'jade'

roomKeyToRoomId = {}
lastId = 13 * 13 * 13

# Fake ID generator, in the real world we'd use a database or something.
genId = ->
  lastId += 13 + Math.floor(Math.random() * 1024)

app.get "/", (req, res) ->
  # Generate a 64-bit room id for the room key, and redirect.
  #roomKey = hat 64, 36
  roomKey = hat 5, 36
  res.redirect "/rooms/#{roomKey}"

app.get "/rooms/:room_key", (req, res) ->
  roomKey = req.params.room_key

  roomKeyToRoomId[roomKey] ||= genId()
  roomId = roomKeyToRoomId[roomKey]

  # Generate a new user id on each page refresh.
  # In the real world we'd authenticate & set a cookie.
  userId = genId()

  res.render "room", { room_id: roomId, room_key: roomKey, user_id: userId }
