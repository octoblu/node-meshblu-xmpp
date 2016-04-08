_     = require 'lodash'
async = require 'async'
xmpp  = require 'node-xmpp-server'
MeshbluXMPP = require '../'

describe 'Subscribe', ->
  beforeEach (done) ->
    @server = new xmpp.C2S.TCPServer
      port: 5222
      domain: 'localhost'

    @server.on 'connection', (@client) =>
      @client.on 'authenticate', (opts, callback) =>
        callback(null, opts)

    @server.on 'listening', done

  afterEach (done) ->
    @server.end done

  describe 'with an active connection', ->
    beforeEach (done) ->
      @sut = new MeshbluXMPP uuid: 'uuid', token: 'token', hostname: 'localhost', port: 5222
      @sut.connect done

    afterEach 'close client', ->
      @sut.close()

    describe 'when subscribe is called', ->
      beforeEach (done) ->
        @client.on 'stanza', (@request) =>
          @rawData = JSON.parse(@request.getChild('request').getChild('rawData').getText())

          @client.send new xmpp.Stanza('iq',
            type: 'result'
            to: @request.attrs.from
            from: @request.attrs.to
            id: @request.attrs.id
          ).c('response').c('rawData').t JSON.stringify(@rawData)

        @opts =
          subscriberUuid: 'uuid'
          emitterUuid: 'uuid'
          type: 'received'

        @sut.subscribe 'uuid', @opts, (error, @response) => done error

      it 'should send a stanza to the server', ->
        expect(@request).to.exist
        expect(@request.toJSON()).to.containSubset
          name: 'iq'
          attrs:
            to: 'localhost'
            type: 'set'
          children: [{
            name: 'request'
            children: [{
              name: 'metadata'
              children: [{
                name: 'jobType'
                children: ['CreateSubscription']
              }]
            }]
          }]

      it 'should return something', ->
        expect(@response).to.exist
