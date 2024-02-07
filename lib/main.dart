import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  static const channel = MethodChannel('channels.rly.network/wallet_manager');

  Future<dynamic> channelMethodHandler(MethodCall methodCall) async {
    switch (methodCall.method) {
      case 'performSomeAction':
        print('performSomeAction called');
        return 5;
      default:
        throw PlatformException(
            code: 'Unimplemented',
            details:
                'The method ${methodCall.method} is not implemented in WalletManager');
    }
  }

  @override
  Widget build(BuildContext context) {
    channel.setMethodCallHandler(channelMethodHandler);
    return const MaterialApp();
  }
}
