_ = require 'lodash'
xmpp = require 'node-xmpp-server'
MeshbluXMPP = require '../'

describe 'Connect', ->
  beforeEach (done) ->
    @server = new xmpp.C2S.TCPServer
      port: 5222
      domain: 'localhost'

    @server.on 'listening', done

  afterEach 'shutdown server', (done) ->
    @server.end done

  describe 'connecting to an XMPP server that lets us in', ->
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

    afterEach 'close client', ->
      @sut.close()

    it 'should have a client', ->
      expect(@client).to.exist

  describe 'connecting to an XMPP server that denies us', ->
    beforeEach (done) ->
      @server.on 'connection', (@client) =>
        @client.on 'authenticate', (opts, callback) =>
          callback(false)

      @sut = new MeshbluXMPP
        uuid:  'uuid'
        token: 'token'
        hostname: 'localhost'
        port: 5222

      @sut.connect (@error) => done()

    afterEach 'close client', ->
      @sut.close()

    it 'should yield an error', ->
      expect(=> throw @error).to.throw 'XMPP authentication failure'
