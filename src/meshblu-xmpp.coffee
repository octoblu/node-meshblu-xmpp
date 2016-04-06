_      = require 'lodash'
Client = require 'node-xmpp-client'

class MeshbluXMPP
  constructor: (options={}) ->
    {@hostname,@port,@uuid,@token} = options

  connect: (callback) =>
    callback = _.once callback

    @connection = new Client
      jid:  "#{@uuid}@meshblu.octoblu.com"
      password: @token
      host: @hostname
      port: @port

    @connection.on 'online', =>
      callback()

    @connection.on 'error', callback

module.exports = MeshbluXMPP
