fs = require "fs"
async = require "async"
hat = require "hat"
_ = require "lodash"
liburl = require "url"
libpath = require "path"
ws = require "ws"

class GameServer
  constructor: ->
    this.reset()

  reset: ->
    @rooms = {}
    @userConns = {}
    @connUsers = {}

  listen: (port) ->
    @ws = new ws.Server({ port: port })

    @ws.on "connection", (conn) ->
      sys.log "connected"

      conn.on "close", ->
        sys.log "closed"

      conn.on "message", ->
        sys.log "message"

  stats: ->
    { running: true }

  userIdForConn: (conn) ->
    connUsers[conn.id]

module.exports = new GameServer()
