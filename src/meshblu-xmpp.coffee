_              = require 'lodash'
{EventEmitter2} = require 'EventEmitter2'
Client         = require 'node-xmpp-client'

class MeshbluXMPP extends EventEmitter2
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
    @connection.on 'error', (error) =>
      @emit 'error', error

  close: =>
    @connection.end()

  status: (callback) =>
    callback()

module.exports = MeshbluXMPP
