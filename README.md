# Node Meshblu XMPP
Node Meshblu client for XMPP

[![Build Status](https://travis-ci.org/octoblu/node-meshblu-xmpp.svg?branch=master)](https://travis-ci.org/octoblu/)
[![Code Climate](https://codeclimate.com/github/octoblu/node-meshblu-xmpp/badges/gpa.svg)](https://codeclimate.com/github/octoblu/)
[![Test Coverage](https://codeclimate.com/github/octoblu/node-meshblu-xmpp/badges/coverage.svg)](https://codeclimate.com/github/octoblu/)
[![npm version](https://badge.fury.io/js/meshblu-xmpp.svg)](http://badge.fury.io/js/)
[![Gitter](https://badges.gitter.im/octoblu/help.svg)](https://gitter.im/octoblu/help)

### Install

```bash
npm install meshblu-xmpp
```

### Example Usage

#### Set-up

```js
var Meshblu = require('meshblu-xmpp');

var config = {
  hostname: 'meshblu-xmpp.octoblu.com',
  port: 5222,
  uuid: 'cf2497d2-7426-46c4-a229-ad789063bf88',
  token: 'a0178530f1d15f17ddcae60ae7198fc954c2ef53'
}

var conn = new Meshblu(config);

conn.connect(function(error){
  if (error) {
    throw error;
  }
  console.log('Connected');
});
```

#### Send Message

```js
var message = {
  "devices": ["*"],
  "payload": "duuude"
};
conn.message(message, function(error){
  if (error) {
    panic(error);
  }
  console.log('Sent Message');
});
```

#### On Message

```js
// Message handler
conn.on('message', function(message){
  console.log('Message Received: ', message);
});
```

#### Create Session Token

```js
conn.createSessionToken(config.uuid, {"name": "my token"}, function(error, result){
  if (error) {
    panic(error);
  }
  console.log('Create Session Token: ', result);
});
```

#### Check status of Meshblu

```js
conn.status(function(error, result){
  if (error) {
    panic(error);
  }
  console.log('Status:', result);
});
```

#### Whoami

```js
conn.whoami(function(error, device){
  if (error) {
    panic(error);
  }
  console.log('Whoami: ', device);
});
```

#### Update

```js
  var update = {
    "$set": {
      "type": "device:generic"
    }
  };
  conn.update(config.uuid, update, function(error){
    if (error) {
      panic(error);
    }
    console.log('Updated the device');
  });
```

#### Register

```js
// Register a new device

conn.register({"type": "device:generic"}, function(error, device){
  if (error) {
    panic(error);
  }
  console.log('Registered a new Device: ', device);
});
```

#### Subscribe

```js
// Subscribe to your own messages to enable recieving them
// conn.unsubscribe takes the same arguments
var subscription = {
  "subscriberUuid" : config.uuid,
  "emitterUuid": config.uuid,
  "type": 'message.received'
};
conn.subscribe(config.uuid, subscription, function(err, result){
  console.log('Subscribe: ', result);
});
```

#### Search Devices
```js
// Search for devices by a query
var query = {
  "type": "device:generic"
};
conn.searchDevices(config.uuid, query, function(err, result){
  console.log('Search Devices: ', result);
  console.log(err);
});
```
