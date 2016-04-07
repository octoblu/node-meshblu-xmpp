_               = require 'lodash'
{EventEmitter2} = require 'EventEmitter2'
Client          = require 'node-xmpp-client'
jsontoxml       = require 'jsontoxml'
ltx             = require 'ltx'
uuid            = require 'uuid'

class MeshbluXMPP extends EventEmitter2
  constructor: (options={}) ->
    {@hostname,@port,@uuid,@token} = options
    @callbacks = {}

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
    @connection.on 'stanza', @onStanza

  close: =>
    @connection.end()

  onStanza: (stanza) =>
    @callbacks[stanza.attrs.id]?(null, stanza)

  status: (callback) =>
    request =
      metadata:
        jobType: 'GetStatus'

    @_sendRequest request, 'get', callback

  update: (uuid, query, callback) =>
    request =
      metadata:
        jobType: 'UpdateDevice'
        toUuid: uuid
      rawData: JSON.stringify query

    @_sendRequest request, 'set', callback


  whoami: (callback) =>
    request =
      metadata:
        jobType: 'GetDevice'
        toUuid: @uuid

    @_sendRequest request, 'get', callback

  _buildStanza: (responseId, type, request) =>
    new Client.Stanza('iq', to: @hostname, type: type, id: responseId)
      .cnode(ltx.parse jsontoxml {request})

  _parseError: (stanza, callback) =>
    message = stanza.getChild('error').getChild('text').getText()
    callback new Error(message)

  _parseResponse: (stanza, callback) =>
    rawData = stanza.getChild('response').getChild('rawData')
    return callback null unless rawData?
    callback null, JSON.parse(rawData.getText())

  _sendRequest: (request, type, callback) =>
    responseId = uuid.v1()

    @callbacks[responseId] = (error, stanza) =>
      delete @callbacks[responseId]
      return callback error if error?
      return @_parseError stanza, callback if stanza.attrs.type == 'error'
      return @_parseResponse stanza, callback

    @connection.send @_buildStanza(responseId, type, request)


module.exports = MeshbluXMPP
