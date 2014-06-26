sys = require("sys")
net = require("net")
Server = require("./server")
http = require("http")
ws = require("ws")
exec = require("child_process").exec

module.exports = class Run
  run: ->
    port = 8000
    stat_port = 8002
    flash_port = 843

    hostname = "unknown"

    exec 'hostname', (error, stdout, stderr) ->
      hostname = stdout.replace(/\n/, "")
      sys.log("Hostname: #{hostname}")

    policy = net.createServer (socket) ->
      policyXml = '''
        <?xml version="1.0"?>
        <!DOCTYPE cross-domain-policy SYSTEM www.macromedia.com/xml/dtds/cross-domain-policy.dtd">
        <cross-domain-policy>
          <allow-access-from domain='altvr.lulcards.com' to-ports='*'/>
        </cross-domain-policy>
        '''
      socket.write(policyXml)
      socket.end()
    .listen(flash_port)

    server = new Server()
    server.init()
    server.listen(port, ->)

    stat_server = http.createServer (req, res) ->
      output = ""
      memUsage = process.memoryUsage()

      for k, v of memUsage
        output += "#{k}: #{v}\n"

      for k, v of server.stats()
        output += "#{k}: #{v}\n"

      res.writeHead(200, {})
      res.end(output)

    stat_server.listen(stat_port)

    sys.log("Flash Policy served on #{flash_port}.")
    sys.log("Listening on #{port}/#{stat_port}.")

    process.setuid("nobody")
