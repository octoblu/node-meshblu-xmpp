_               = require 'lodash'
{EventEmitter2} = require 'EventEmitter2'
Client          = require 'node-xmpp-client'
uuid            = require 'uuid'
xml2js          = require 'xml2js'

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
    responseId = uuid.v1()
    
    @callbacks[responseId] = (error, stanza) =>
      delete @callbacks[responseId]
      return callback error if error?
      @_parseResponse stanza, (error, response) =>
        return callback error if error?
        return callback null, response.data

    @connection.send(
      new Client.Stanza('iq', to: @hostname, type: 'get', id: responseId)
        .c('request')
          .c('metadata')
            .c('jobType').t('GetStatus')
    )

  whoami: (callback) =>
    responseId = uuid.v1()

    @callbacks[responseId] = (error, stanza) =>
      delete @callbacks[responseId]
      return callback error if error?
      @_parseResponse stanza, (error, response) =>
        return callback error if error?
        return callback null, response.data

    @connection.send(
      new Client.Stanza('iq', to: @hostname, type: 'get', id: responseId)
        .c('request')
          .c('metadata')
            .c('jobType').t('GetDevice').up()
            .c('toUuid').t(@uuid).up()
    )

  _parseResponse: (stanza, callback) =>
    rawData = stanza.toJSON().children[0].children[0].children[0]
    callback null, { data: JSON.parse rawData }

module.exports = MeshbluXMPP
