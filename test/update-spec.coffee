_           = require 'lodash'
ltx         = require 'ltx'
xmpp        = require 'node-xmpp-server'
xml2js      = require('xml2js').parseString
MeshbluXMPP = require '../'

describe 'Update', ->
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

    describe 'when update responds with a 204', ->
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

        @sut.update 'uuid-2', {foo: 'bar'}, done

      it 'should send a stanza to the server', (done) ->
        expect(@request).to.exist
        options = {explicitArray: false, mergeAttrs: true}

        xml2js @request.toString(), options, (error, request) =>
          return done error if error?

          expect(request).to.containSubset
            iq:
              type: 'set'
              request:
                metadata:
                  jobType: 'UpdateDevice'
                  toUuid: 'uuid-2'
                rawData: '{"foo":"bar"}'
          done()

    describe 'when whoami responds with a 403', ->
      beforeEach (done) ->
        @client.on 'stanza', (@request) =>
          @client.send(new xmpp.Stanza('iq', {
            type: 'error'
            to: @request.attrs.from
            from: @request.attrs.to
            id: @request.attrs.id
          })
          .cnode(@request.getChild('request')).up()
          .cnode ltx.parse """
            <error type="cancel">
              <forbidden xmlns="urn:ietf:params:xml:ns:xmpp-stanzas" />
              <text xmlns='urn:ietf:params:xml:ns:xmpp-stanzas' xml:lang='en-US'>Forbidden</text>
              <response xmlns="meshblu-xmpp:job-manager:response">
                <metadata>
                  <code>403</code>
                </metadata>
              </response>
            </error>
          """)

        @sut.update 'uuid-2', {foo: 'bar'}, (@error) => done()

      it 'should yield an error', ->
        expect(=> throw @error).to.throw 'Forbidden'
