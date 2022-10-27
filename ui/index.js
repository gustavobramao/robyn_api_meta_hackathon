var StaticServer = require('static-server');
var server = new StaticServer({
  rootPath: '.',            // required, the root of the server file tree
  port: 1337,               // required, the port to listen
  name: 'robyn-api-ui',   // optional, will set "X-Powered-by" HTTP header
  host: '127.0.0.1',       // optional, defaults to any interface
  cors: '*',                // optional, defaults to undefined
  followSymlink: true,      // optional, defaults to a 404 error
  templates: {
    index: 'index.html',      // optional, defaults to 'index.html'
  },
  open: true
});

server.start(function () {
  console.log('Server Listening On : %s:%s', server.host, server.port);
});