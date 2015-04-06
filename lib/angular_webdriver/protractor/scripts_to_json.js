// run with: node scripts_to_json.js

var clientSideScripts = require('./clientsidescripts.js'),
    fs                = require('fs');

// Serialize client side scripts to JSON for reading into Ruby
var json = JSON.stringify(clientSideScripts, null, 2);

var fd = fs.openSync('clientSideScripts.json', 'w', '666');
fs.writeSync(fd, json);
fs.closeSync(fd);
