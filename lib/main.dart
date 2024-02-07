import 'package:flutter/material.dart';
import 'package:rly_sdk/channel_handler.dart';

void main() => runApp(const MyApp());

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    ChannelHandler.getInstance().register();
  }

  @override
  Widget build(BuildContext context) {
    return const MaterialApp();
  }
}
