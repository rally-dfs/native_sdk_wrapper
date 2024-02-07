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
    switch (action) {
      case "createWallet":
        return await createWallet();
      case "getWalletAddress":
        return await getWalletAddress();
      case "deleteWallet":
        return await deleteWallet();
      default:
        throw PlatformException(
            code: 'Unimplemented',
            details:
                'The method ${methodCall.method} is not implemented in WalletManager');
    }
  }

  Future<String> createWallet() async {
    print("calling createWallet");
    await WalletManager.getInstance().createWallet();
    return (await WalletManager.getInstance().getPublicAddress())!;
  }

  Future<String> getWalletAddress() async {
    print("calling getWalletAddress");
    String? address = await WalletManager.getInstance().getPublicAddress();
    return address ?? "no address";
  }

  Future<bool> deleteWallet() async {
    print("calling deleteWallet");
    await WalletManager.getInstance().permanentlyDeleteWallet();
    return true;
  }

  @override
  Widget build(BuildContext context) {
    print("Setting up channel");
    channel.setMethodCallHandler(channelMethodHandler);
    return const MaterialApp();
  }
}
