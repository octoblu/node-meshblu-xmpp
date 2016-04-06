_ = require 'lodash'
xmpp = require 'node-xmpp-server'
MeshbluXMPP = require '../'

describe 'Connect', ->
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

    describe 'when status is called', ->
      beforeEach (done) ->
        @client.on 'stanza', (@request) =>
          @client.send new xmpp.Stanza('iq',
            type: 'result'
            to: @request.attrs.from
            from: @request.attrs.to
          ).c('meshblu').t('online')

        @sut.status (error, @response) => done error

      it 'should send a stanza to the server', ->
        expect(@request).to.exist
        expect(@request.toJSON()).to.containSubset
          name: 'iq'
          attrs:
            to: 'localhost'
            type: 'get'
          children: [{
            name: 'status'
          }]

      it 'should return a status of online: true', ->
        expect(@response).to.exist
        expect(@response).to.deep.equal meshblu: 'online'
