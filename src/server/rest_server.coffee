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

genId = ->
  lastId += 13 + Math.floor(Math.random() * 1024)

app.get "/", (req, res) ->
  roomKey = hat 64, 36
  roomKeyToRoomId[roomKey] = genId()
  res.redirect "/rooms/#{roomKey}"

app.get "/rooms/:room_key", (req, res) ->
  roomKey = req.params.room_key
  roomId = roomKeyToRoomId[roomKey]
  userId = genId()

  res.render "room", { room_id: roomId, room_key: roomKey, user_id: userId }
