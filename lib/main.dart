import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:rly_sdk/channel_handler.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  static const channel = MethodChannel('channels.rly.network/wallet_manager');

  @override
  Widget build(BuildContext context) {
    print("Setting up channel");
    ChannelHandler.getInstance().register();
    return const MaterialApp();
  }
}
