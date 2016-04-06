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

    @connection.once 'online', =>
      callback()

    @connection.once 'error', callback
    @connection.on 'error', (error) =>
      @emit 'error', error

  close: =>
    @connection.end()

  status: (callback) =>
    @connection.once 'stanza', (stanza) =>
      callback null, @_parseResponse stanza

    @connection.send new Client.Stanza('iq', to: @hostname, type: 'get').c('status')

  _parseResponse: (stanza) =>
    response = {}
    _.each stanza.toJSON().children, (child) =>
      response[child.name] = _.first child.children
    response

module.exports = MeshbluXMPP
