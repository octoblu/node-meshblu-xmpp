_ = require 'lodash'
xmpp = require 'node-xmpp-server'
MeshbluXMPP = require '../'

describe 'MeshbluXMPP', ->
  beforeEach (done) ->
    @server = new xmpp.C2S.TCPServer
      port: 5222
      domain: 'localhost'

    @server.on 'listening', done

  afterEach (done) ->
    @server.end done

  describe 'connecting to an XMPP server', ->
    beforeEach (done) ->
      @server.on 'connection', (@client) =>
        @client.on 'authenticate', (opts, callback) =>
          callback(null, opts)

      @sut = new MeshbluXMPP
        uuid:  'uuid'
        token: 'token'
        hostname: 'localhost'
        port: 5222

      @sut.connect done

    it 'should have a client', ->
      expect(@client).to.exist
