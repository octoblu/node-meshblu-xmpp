var meshblu = require('../index.js');

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
