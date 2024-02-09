import 'package:flutter/material.dart';
import 'package:rly_sdk/channel_handler.dart';

void main() => runApp(const MyApp());

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  MyAppState createState() => MyAppState();
}

class MyAppState extends State<MyApp> {
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
