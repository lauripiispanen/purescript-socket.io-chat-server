"use strict";

// module Control.SocketIO.Server
var io = require('socket.io')
var Rx = require('rx')


exports.listen = function listen(port) {
  return function() {
    return io.listen(port);
  };
}

exports.on = function(event) {
  return function(socket) {
    return Rx.Observable.create(function(observer) {
      socket.on(event, function(e) {
        observer.onNext({
          connection: socket,
          payload: e
        })
      })
      socket.on('disconnect', function() {
        observer.onCompleted()
      })
    })
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
