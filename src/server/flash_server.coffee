net = require("net")

class FlashServer
  constructor: ->

  listen: (port) ->
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
    .listen(port)

module.exports = new FlashServer()
