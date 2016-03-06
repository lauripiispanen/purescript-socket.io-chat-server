"use strict";

// module Control.SocketIO.Server
var io = require('socket.io')


exports.listen = function listen(port) {
  return function() {
    return io.listen(port);
  };
}

exports.onConnection = function(server) {
  return function(onConnection) {
    return function() {
      server.on('connect', function(socket) {
        onConnection(socket)()
      })
    }
  }
}

exports.on = function(socket) {
  return function(event) {
    return function(onEvent) {
      return function() {
        socket.on(event, function(data) {
          onEvent(data)()
        })
      }
    }
  }
}

exports.emit = function(socket) {
  return function(event) {
    return function(obj) {
      return function() {
        socket.emit(event, obj)
      }
    }
  }
}
