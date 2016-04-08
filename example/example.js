var meshblu = require('../index.js');

var config = {
  'hostname': 'meshblu-xmpp.octoblu.com',
  'port': 5222,
  'uuid': '',
  'token': ''
}

var conn = new meshblu(config);

conn.connect(function(data){

  // Check status of Meshblu
    conn.status(function(err, result){
      console.log(result);
    });

  // Get the current authenticated device's registry
    conn.whoami(function(err, result){
      console.log('Whoami', result);
    });

  // Update a specific device - you can add arbitrary json
    conn.update(config.uuid, { "$set": {"type": "device:generic"}}, function(err, device){
      console.log(device);
    });

  // Register a new device
    conn.register({"type": "device:generic"}, function(err, device){
      console.log(device);
    });

  // Send a message
    conn.message({"devices": ["*"], "payload": "duuude"}, function(result){
      console.log(result);
    });

  // Subscribe to your own messages to enable recieving them
    conn.subscribe(config.uuid,
      {
      "subscriberUuid" : config.uuid,
      "emitterUuid": config.uuid,
      "type": 'message.received'
    }, function(err, result){
      console.log('Subscribe Response', result);
      console.log('Config', config);
      console.log('Subscribe Error', err);
    });

  // Search for devices by a query
    conn.searchDevices(config.uuid, {
      "type": "device:generic"
    },
      function(err, result){
      console.log("search devices", result);
      console.log(err);
    });

}); // conn.connect

// Message handler
  conn.on('message', function(message){
    console.log(message);
  });
