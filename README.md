# node-meshblu-xmpp
Node Meshblu client for XMPP

[![Build Status](https://travis-ci.org/octoblu/.svg?branch=master)](https://travis-ci.org/octoblu/)
[![Code Climate](https://codeclimate.com/github/octoblu//badges/gpa.svg)](https://codeclimate.com/github/octoblu/)
[![Test Coverage](https://codeclimate.com/github/octoblu//badges/coverage.svg)](https://codeclimate.com/github/octoblu/)
[![npm version](https://badge.fury.io/js/.svg)](http://badge.fury.io/js/)
[![Gitter](https://badges.gitter.im/octoblu/help.svg)](https://gitter.im/octoblu/help)

### Install
```bash
npm install meshblu-xmpp
```

### Example Usage

```js
var meshblu = require('meshblu-xmpp');

var config = {
  'hostname': 'meshblu-xmpp.octoblu.com',
  'port': 5222,
  'uuid': '',
  'token': ''
}

var conn = new meshblu(config);

conn.connect(function(data){
    conn.status(function(err, result){
      console.log(result);
    });

    conn.whoami(function(err, result){
      console.log(result);
    });

    conn.update(config.uuid, { "$set": {"type": "device:generic"}}, function(err, device){
      console.log(device);
    });

    conn.register({"type": "device:generic"}, function(err, device){
      console.log(device);
    });

    conn.message({"devices": ["*"], "payload": "duuude"}, function(result){
      console.log(result);
    });

});

```
