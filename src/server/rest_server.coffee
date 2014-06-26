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
