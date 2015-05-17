// run with: node scripts_to_json.js

var clientSideScripts = require('../protractor/lib/clientsidescripts.js'),
    path              = require('path'),
    fs                = require('fs');

// Serialize client side scripts to JSON for reading into Ruby
var json = JSON.stringify(clientSideScripts, null, 2);

var jsonPath = path.resolve(__dirname, 'clientSideScripts.json');

if (fs.existsSync(jsonPath)) fs.unlinkSync(jsonPath);

var fd = fs.openSync(jsonPath, 'w', '666');
fs.writeSync(fd, json);
fs.closeSync(fd);

if (!fs.existsSync(jsonPath)) throw new Error("json doesn't exist!");
console.log("Created " + jsonPath.replace(__dirname, "./" + path.basename(__dirname)));
