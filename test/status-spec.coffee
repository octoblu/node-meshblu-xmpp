_     = require 'lodash'
async = require 'async'
xmpp  = require 'node-xmpp-server'
MeshbluXMPP = require '../'

describe 'Status', ->
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

  describe 'without an active connection', ->
    beforeEach ->
      @sut = new MeshbluXMPP uuid: 'uuid', token: 'token', hostname: 'localhost', port: 5222

    describe 'when status is called', ->
      beforeEach (done) ->
        @sut.status (@error) => done()

      it 'should yield an error', ->
        expect(=> throw @error).to.throw 'MeshbluXMPP is not connected'

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
            id: @request.attrs.id
          ).c('response').c('rawData').t JSON.stringify({
            meshblu: 'online'
          })

        @sut.status (error, @response) => done error

      it 'should send a stanza to the server', ->
        expect(@request).to.exist
        expect(@request.toJSON()).to.containSubset
          name: 'iq'
          attrs:
            to: 'localhost'
            type: 'get'
          children: [{
            name: 'request'
            children: [{
              name: 'metadata'
              children: [{
                name: 'jobType'
                children: ['GetStatus']
              }]
            }]
          }]

      it 'should return a status of online: true', ->
        expect(@response).to.exist
        expect(@response).to.deep.equal meshblu: 'online'

    describe 'when status is called twice', ->
      beforeEach (done) ->
        wait = (delay, fn) -> setTimeout fn, delay

        @client.on 'stanza', (@request) =>
          @client.send new xmpp.Stanza('iq',
            type: 'result'
            to: @request.attrs.from
            from: @request.attrs.to
            id: @request.attrs.id
          ).c('response').c('rawData').t JSON.stringify({
            meshblu: 'online'
          })

        async.times 2, ((i, callback) => @sut.status callback), done

      it 'should return a status of online: true', ->
        expect(true).to.be.true
