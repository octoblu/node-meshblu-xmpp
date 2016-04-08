_               = require 'lodash'
{EventEmitter2} = require 'eventemitter2'
Client          = require 'node-xmpp-client'
jsontoxml       = require 'jsontoxml'
ltx             = require 'ltx'
uuid            = require 'uuid'
xml2js          = require('xml2js').parseString

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

    @connection.connection.socket.setTimeout(0)
    @connection.connection.socket.setKeepAlive(true, 10000)

    @connection.once 'online', =>
      callback()

    @connection.once 'error', callback
    @connection.on 'error', (error) =>
      @emit 'error', error
    @connection.on 'stanza', @onStanza

  close: =>
    @connection.end()
    delete @connection

  onStanza: (stanza) =>
    if stanza.name == 'message'
      @_parseMessage stanza, (error, message) =>
        return @emit 'message', message
    @callbacks[stanza.attrs.id]?(null, stanza)

  message: (message, callback) =>
    request =
      metadata:
        jobType: 'SendMessage'
      rawData: JSON.stringify message

    @_sendRequest request, 'set', callback

  register: (opts, callback) =>
    @_JobSetRequest {}, opts, 'RegisterDevice', callback

  status: (callback) =>
    request =
      metadata:
        jobType: 'GetStatus'

    @_sendRequest request, 'get', callback

  subscribe: (uuid, opts, callback) =>
    metadata =
      toUuid: uuid
    @_JobSetRequest metadata, opts, 'CreateSubscription', callback

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

  _JobSetRequest: (metadata, opts, jobType, callback) =>
    request =
      metadata:
        jobType: jobType
      rawData: JSON.stringify opts

    request.metadata = _.merge request.metadata, metadata

    @_sendRequest request, 'set', callback

  _buildStanza: (responseId, type, request) =>
    new Client.Stanza('iq', to: @hostname, type: type, id: responseId)
      .cnode(ltx.parse jsontoxml {request})

  _parseError: (stanza, callback) =>
    error = new Error stanza.getChild('error').getChild('text').getText()
    error.response =  stanza.getChild('error').toString()
    callback error

  _parseResponse: (stanza, callback) =>
    rawData = stanza.getChild('response').getChild('rawData')
    return callback null unless rawData?
    callback null, JSON.parse(rawData.getText())

  _sendRequest: (request, type, callback) =>
    return callback new Error('MeshbluXMPP is not connected') unless @connection?

    responseId = uuid.v1()

    @callbacks[responseId] = (error, stanza) =>
      delete @callbacks[responseId]
      return callback error if error?
      return @_parseError stanza, callback if stanza.attrs.type == 'error'
      return @_parseResponse stanza, callback

    @connection.send @_buildStanza(responseId, type, request)

  _parseMessage: (stanza, callback) =>
    options =
      explicitArray: false
      mergeAttrs: true

    xml2js stanza.toString(), options, (error, data) =>
      return callback error if error?
      message =
        metadata: data.message?.metadata

      if message.metadata.route?
        unless _.isArray message.metadata.route
          message.metadata.route = [message.metadata.route]

        message.metadata.route = _.map message.metadata.route, (hip) => hip.hop

      if data.message?['raw-data']?
        try
          message.data = JSON.parse data.message['raw-data']
        catch
          message.rawData = data.message['raw-data']

      callback null, message



module.exports = MeshbluXMPP
