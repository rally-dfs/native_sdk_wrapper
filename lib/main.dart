import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:rly_network_flutter_sdk/wallet_manager.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  static const channel = MethodChannel('channels.rly.network/wallet_manager');

  Future<dynamic> channelMethodHandler(MethodCall methodCall) async {
    String action = methodCall.method;
    if (action == "createWallet") {
      print("Going to create a wallet");
      await WalletManager.getInstance().createWallet();
      return await WalletManager.getInstance().getPublicAddress();
    }
    if (action == "getWalletAddress") {
      print("calling getWalletAddress");
      String? address = await WalletManager.getInstance().getPublicAddress();
      return address ?? "no address";
    }

    if (action == "deleteWallet") {
      print("calling deleteWallet");
      await WalletManager.getInstance().permanentlyDeleteWallet();
      return true;
    }

    throw PlatformException(
        code: 'Unimplemented',
        details:
            'The method ${methodCall.method} is not implemented in WalletManager');
  }

  @override
  Widget build(BuildContext context) {
    print("Setting up channel");
    channel.setMethodCallHandler(channelMethodHandler);
    return const MaterialApp();
  }
}
