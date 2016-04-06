_               = require 'lodash'
{EventEmitter2} = require 'EventEmitter2'
Client          = require 'node-xmpp-client'
xml2js          = require 'xml2js'

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
      @_parseResponse stanza, (error, response) =>
        return callback error if error?
        return callback null, response.data

    @connection.send new Client.Stanza('iq',
      to: @hostname
      type: 'get'
    ).c('request').c('metadata').c('jobType').t('GetStatus')

  whoami: (callback) =>
    @connection.once 'stanza', (stanza) =>
      @_parseResponse stanza, (error, response) =>
        return callback error if error?
        return callback null, response.data

    @connection.send new Client.Stanza('iq', to: @hostname, type: 'get').c('whoami')
    stanza = new Client.Stanza('iq', to: @hostname, type: 'get')
      .c('request')
        .c('metadata')
          .c('jobType').t('GetDevice').up()
          .c('toUuid').t(@uuid).up()
    @connection.send stanza

  _parseResponse: (stanza, callback) =>
    rawData = stanza.toJSON().children[0].children[0].children[0]
    callback null, { data: JSON.parse rawData }

module.exports = MeshbluXMPP
