"use strict";

// module Control.SocketIO.Server
var io = require('socket.io')
var Rx = require('rx')


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

exports.connections = function(server) {
  return Rx.Observable.create(function(observer) {
    server.on('connect', function(socket) {
      observer.onNext(socket)
    })
  })
}

exports.messages = function(socket) {
  return Rx.Observable.create(function(observer) {
    socket.on('msg', function(msg) {
      observer.onNext({
        conn: socket,
        msg: msg
      })
    })
    socket.on('disconnect', function() {
      observer.onCompleted()
    })
  })
}

exports.disconnect = function(socket) {
  return Rx.Observable.create(function(observer) {
    socket.on('disconnect', function() {
      observer.onNext(socket)
      observer.onCompleted()
    })
  })
}

exports.connectionId = function(connection) {
  return connection.id
}
