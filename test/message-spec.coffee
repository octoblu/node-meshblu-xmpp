_           = require 'lodash'
ltx         = require 'ltx'
xmpp        = require 'node-xmpp-server'
xml2js      = require('xml2js').parseString
MeshbluXMPP = require '../'

describe 'Message', ->
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

    describe 'when message responds with a 204', ->
      beforeEach (done) ->
        @client.on 'stanza', (@request) =>
          @client.send new xmpp.Stanza('iq',
            type: 'result'
            to: @request.attrs.from
            from: @request.attrs.to
            id: @request.attrs.id
          ).cnode(ltx.parse """
            <response xmlns="meshblu-xmpp:job-manager:response">
              <metadata>
                <code>204</code>
              </metadata>
            </response>
          """)
        @sut.message devices: ['uuid-2'], payload: 'hi', done

      it 'should send a stanza to the server', (done) ->
        expect(@request).to.exist
        options = {explicitArray: false}
        xml2js @request.toString(), options, (error, request) =>
          return done error if error?

          expect(request).to.containSubset
            message:
              $:
                type: 'normal'
                to: 'uuid-2@meshblu.octoblu.com'
              body:
                '{"devices":["uuid-2"],"payload":"hi"}'
          done()
