var Meshblu = require('../index.js');

var config = {
  'hostname': 'meshblu-xmpp.octoblu.com',
  'port': 5222,
  'uuid': '',
  'token': ''
}

var conn = new Meshblu(config);

conn.connect(function(data){

  // Create Session token
    conn.createSessionToken(config.uuid, {"createdAt": Date.now()},
    function(err, result){
      console.log('Create Session Token: ', result);
    });

  // Check status of Meshblu
    conn.status(function(err, result){
      console.log('Status:', result);
    });

  // Get the current authenticated device's registry
    conn.whoami(function(err, result){
      console.log('Whoami: ', result);
    });

  // Update a specific device - you can add arbitrary json
    conn.update(config.uuid, { "$set": {"type": "device:generic"}}, function(err, device){
      console.log('Update Device:', device);
    });

  // Register a new device
    conn.register({"type": "device:generic"}, function(err, device){
      console.log('Register Device: ', device);
    });

  // Send a message
    conn.message({"devices": ["*"], "payload": "duuude"}, function(result){
      console.log('Send Message: ', result);
    });

  // Subscribe to your own messages to enable recieving them
  // conn.unsubscribe takes the same arguments
    conn.subscribe(config.uuid,
      {
      "subscriberUuid" : config.uuid,
      "emitterUuid": config.uuid,
      "type": 'message.received'
    }, function(err, result){
      console.log('Subscribe: ', result);
    });

  // Search for devices by a query
    conn.searchDevices(config.uuid, {
      "type": "device:generic"
    },
      function(err, result){
      console.log('Search Devices: ', result);
      console.log(err);
    });

}); // conn.connect

// Message handler
  conn.on('message', function(message){
    console.log('Message Received: ', message);
  });
