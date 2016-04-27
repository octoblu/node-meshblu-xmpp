var Meshblu = require('../index.js');

var config = {
  hostname: 'meshblu-xmpp.octoblu.com',
  port: 5222,
  uuid:  process.env.MESHBLU_UUID,
  token: process.env.MESHBLU_TOKEN
}

var panic = function(error){
  console.error(error.stack);
  process.exit(1);
}
var conn = new Meshblu(config);

// Message handler
conn.on('message', function(message){
  console.log('Message Received: ', message);
});

conn.connect(function(error){
  if (error) {
    panic(error);
  }

  // Create Session token
  conn.createSessionToken(config.uuid, {"name": "my token"}, function(error, result){
    if (error) {
      panic(error);
    }
    console.log('Create Session Token: ', result);
  });

  // Check status of Meshblu
  conn.status(function(error, result){
    if (error) {
      panic(error);
    }
    console.log('Status:', result);
  });

  // Get the current authenticated device's registry
  conn.whoami(function(error, device){
    if (error) {
      panic(error);
    }
    console.log('Whoami: ', device);
  });

  // Update a specific device - you can add arbitrary json
  conn.update(config.uuid, { "$set": {"type": "device:generic"}}, function(error){
    if (error) {
      panic(error);
    }
    console.log('Updated the device');
  });

  // Register a new device
  conn.register({"type": "device:generic"}, function(error, device){
    if (error) {
      panic(error);
    }
    console.log('Registered a new Device: ', device);
  });

  // Send a message
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

  // Subscribe to your own messages to enable recieving them
  // conn.unsubscribe takes the same arguments
  var subscription = {
    "subscriberUuid" : config.uuid,
    "emitterUuid": config.uuid,
    "type": 'message.received'
  };
  conn.subscribe(config.uuid, subscription, function(error, result){
    if (error) {
      panic(error);
    }
    console.log('Subscribe: ', result);
  });

  // Search for devices by a query
  conn.searchDevices(config.uuid, {"type": "device:generic"}, function(error, devices){
    if (error) {
      panic(error);
    }
    console.log('Search Devices: ', devices);
  });
}); // conn.connect
