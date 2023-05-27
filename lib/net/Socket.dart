import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';

import '../model/Message.dart';

class BaseSocketCS {
  var msgStream = StreamController<Message>();

  void init() async {}

  void send(Message msg) {}

  @mustCallSuper
  void dispose() {
    msgStream.close();
  }
}

class SocketServer extends BaseSocketCS {
  ServerSocket serverSocket;
  List<Socket> clients = [];
  int port;

  SocketServer(this.port);

  @override
  void init() async {
    ServerSocket.bind(InternetAddress.anyIPv4, port)
        .then((bindSocket) {
          serverSocket = bindSocket;
          serverSocket.listen((clientSocket) {
            utf8.decoder.bind(clientSocket).listen((data) {
              msgStream.add(Message.fromJson(json.decode(data)));
              // 测试代码，联调完成后需删除
              debugPrint(data);
              send(Message(Message.TYPE_USER, "Hello, too", ""));
            });
            clients.add(clientSocket);
          });
    });
  }

  @override
  void send(Message msg) async {
    for (var client in clients) {
      client.add(utf8.encode(json.encode(msg)));
    }
  }

  @override
  void dispose() {
    super.dispose();
    for (var socket in clients) {
      socket.close();
    }
    serverSocket.close();
  }
}

class SocketClient extends BaseSocketCS {
  Socket clientSocket;
  String address;
  int port;

  SocketClient(this.address, this.port);

  @override
  void init() async {
    clientSocket = await Socket.connect(address, port);
    utf8.decoder.bind(clientSocket).listen((data) {
      msgStream.add(Message.fromJson(json.decode(data)));
      // 测试代码，联调完成后需删除
      debugPrint(data);
    });
    // 测试代码，联调完成后需删除
    send(Message(Message.TYPE_USER, "Hello", ""));
  }

  @override
  void send(Message msg) {
    clientSocket.add(utf8.encode(json.encode(msg)));
  }

  @override
  void dispose() {
    super.dispose();
    clientSocket.close();
  }
}