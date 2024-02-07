import 'package:flutter/services.dart';
import 'package:rly_network_flutter_sdk/network.dart';
import 'package:rly_network_flutter_sdk/wallet_manager.dart';

class ChannelHandler {
  final MethodChannel _channel;
  String? _apiKey;
  Network? _currentNetwork;

  static final ChannelHandler _instance = ChannelHandler();

  ChannelHandler()
      : _channel = const MethodChannel('channels.rly.network/wallet_manager');

  factory ChannelHandler.getInstance() {
    return _instance;
  }

  void register() {
    _channel.setMethodCallHandler(_handleChannelMethodCall);
  }

  Future<dynamic> _handleChannelMethodCall(MethodCall methodCall) async {
    String action = methodCall.method;
    switch (action) {
      case "createWallet":
        return await createWallet();
      case "getWalletAddress":
        return await getWalletAddress();
      case "deleteWallet":
        return await deleteWallet();
      case "claimRly":
        return await claimRly();
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

  Future<dynamic> claimRly() async {
    Network mumbai = rlyMumbaiNetwork;
    print("calling claimRly");
    String txnHash = await mumbai.claimRly();
    return txnHash;
  }
}
