should = require('should')
assert = require('assert')
_ = require "lodash"

Server = require('../lib/server.js')

describe "Server", ->
  it "should do something", (done) ->
    server = new Server()
    assert.equal 1, server.foo()
    done()
