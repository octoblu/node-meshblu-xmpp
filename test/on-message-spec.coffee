_           = require 'lodash'
ltx         = require 'ltx'
xmpp        = require 'node-xmpp-server'
xml2js      = require('xml2js').parseString
MeshbluXMPP = require '../'

describe 'on: message', ->
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

    describe 'when a message is received', ->
      beforeEach (done) ->
        @sut.on 'message', (@message) => done()

        @client.send new xmpp.Stanza('message',
          type: 'normal'
          to: 'uuid@meshblu.octoblu.com'
          from: 'meshblu.octoblu.com'
        ).cnode(ltx.parse """
        <metadata />
        <raw-data />
        """)

      it 'should get a message', ->
        expect(@message).to.exist
