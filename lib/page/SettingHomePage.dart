import 'dart:io';

import 'package:flutter/material.dart';

class SettingHomePage extends StatefulWidget {
  Function(int port) _createServerCallback;
  Function(String address, int port) _createClientCallback;
  Function(BuildContext childContext) _goToChatPage;

  SettingHomePage(this._createServerCallback, this._createClientCallback, this._goToChatPage);

  @override
  State<StatefulWidget> createState() {
    return _SettingHomeState();
  }
}

class _SettingHomeState extends State<SettingHomePage> {
  String ipAddress = "";

  var _serverPortController = TextEditingController();
  var _clientAddressController = TextEditingController();
  var _clientPortController = TextEditingController();

  @override
  void initState() {
    super.initState();
    getIpAddress();
  }

  @override
  void dispose() {
    super.dispose();
    _serverPortController.dispose();
    _clientAddressController.dispose();
    _clientPortController.dispose();
  }

  void getIpAddress() {
    NetworkInterface.list(
      includeLoopback: false,
      type: InternetAddressType.any
    ).then((List<NetworkInterface> interfaces) => {
      setState(() {
        ipAddress = "";
        for (var interface in interfaces) {
          ipAddress += " ${interface.name} \n";
          for (var element in interface.addresses) {
            ipAddress += " ${element.address} \n";
          }
        }
      })
    });
  }

  Widget getDeviceInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Text(
            "本机 IP 地址",
            style: TextStyle(fontSize: 26),
          ),
          Text(ipAddress)
        ],
    );
  }

  Widget getServerConfig() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const Text(
          "Socket Server 模式运行",
          style: TextStyle(fontSize: 26),
        ),
        Row(
          children: <Widget>[
            const Text("端口号:"),
            Expanded(child: TextField(
              controller: _serverPortController,
              keyboardType: TextInputType.number,
            ))
          ],
        ),
        OutlinedButton(child:const Text("启动"), onPressed: () {
          widget._createServerCallback.call(int.parse(_serverPortController.text));
          widget._goToChatPage(context);
        },)
      ],
    );
  }

  Widget getClientConfig() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const Text(
          "Socket Client 模式运行",
          style: TextStyle(fontSize: 26),
        ),
        Row(
          children: <Widget>[
            const Text("Server IP:"),
            Expanded(child: TextField(
              controller: _clientAddressController,
              keyboardType: TextInputType.number,
            ))
          ],
        ),
        Row(
          children: <Widget>[
            const Text("Server 端口号:"),
            Expanded(child: TextField(
              controller: _clientPortController,
              keyboardType: TextInputType.number,
            ))
          ],
        ),
        OutlinedButton(child: const Text("启动"), onPressed: () {
          widget._createClientCallback.call(
            _clientAddressController.text,
            int.parse(_clientPortController.text)
          );
          widget._goToChatPage(context);
        })
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("设置首页"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              getDeviceInfo(),
              const SizedBox(height: 12),
              getServerConfig(),
              const SizedBox(height: 12),
              getClientConfig(),
              const SizedBox(height: 12),
              const Text("注：需先在一台设备上启动 Server,再用另一台设备连接"),
            ],
          ),
        ),
      ),
    );
  }
}
