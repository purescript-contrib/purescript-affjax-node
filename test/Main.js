import express from "express";
import bodyParser from "body-parser";
import https from "https";
import { readFileSync } from "fs";
import XHR from "xhr2";

import { fileURLToPath } from 'url'
import { dirname } from 'path'
const __dirname = dirname(fileURLToPath(import.meta.url));

export function logAny(a) {
  return function () {
    console.log(a);
    return {};
  };
}

export function startServer(errback, callback) {
  var app = express();

  // Always make req.body available as a String
  app.use(bodyParser.text(function() { return true; }));

  app.use(express.static(__dirname));

  app.get('/', function (req, res) {
    res.send('<html><script src="tmp/test.js"></script></html>');
  });

  app.get('/arrayview', function(req, res) {
    res.send('TODO');
  });

  app.get('/not-json', function(req, res) {
    res.header({'content-type': 'text/plain'});
    res.send('This is not JSON');
  });

  app.all('/mirror', function(req, res) {
    res.json({
      headers: req.headers,
      body: req.body,
      query: req.query,
      method: req.method,
    });
  });

  app.get('/slow', function(req, res) {
    var date = Date.now();
    var currentDate = null;
    do {
      currentDate = Date.now();
    } while (currentDate - date < 2000);
    res.header({'content-type': 'text/plain'});
    res.send('I hope I am not late!');
  });

  // Public, test-only credentials. Keep TLS verification enabled and trust only
  // this fixture for the local HTTPS request.
  var cert = readFileSync("test/fixtures/localhost-cert.pem");
  var key = readFileSync("test/fixtures/localhost-key.pem");
  var secureServer = https.createServer({ key, cert }, app);
  var previousAgent = XHR.prototype.nodejsHttpsAgent;
  var agent = new https.Agent({ ca: cert });
  XHR.nodejsSet({ httpsAgent: agent });

  var server = app.listen(function () {
    secureServer.listen(0, "localhost", function () {
      callback({
        port: server.address().port,
        httpsPort: secureServer.address().port,
        server: { http: server, https: secureServer, agent, previousAgent }
      });
    });
  });
  server.on('error', function (error) {
    errback(error);
  });
  secureServer.on('error', function (error) {
    server.close();
    agent.destroy();
    XHR.nodejsSet({ httpsAgent: previousAgent });
    errback(error);
  });

  return function (cancelError, onCancelerError, onCancelerSuccess) {
    onCancelerSuccess();
  };
}

export function stopServer(server) {
  return function (errback, callback) {
    server.agent.destroy();
    XHR.nodejsSet({ httpsAgent: server.previousAgent });
    server.http.close(function (err) {
      server.https.close(function (httpsErr) {
        if (err || httpsErr) errback(err || httpsErr);
        else callback();
      });
    });
    return function (cancelError, onCancelerError, onCancelerSuccess) {
      onCancelerSuccess();
    };
  };
}
