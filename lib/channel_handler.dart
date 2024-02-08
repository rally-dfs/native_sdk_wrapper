import 'package:flutter/services.dart';
import 'package:rly_network_flutter_sdk/rly_network_flutter_sdk.dart';

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
    print("Register called");
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
      case "configureEnvironment":
        return await configureEnvironment(methodCall.arguments);
      case "claimRly":
        return await claimRly();
      default:
        throw PlatformException(
            code: 'Unimplemented',
            details:
                'The method ${methodCall.method} is not implemented in WalletManager');
    }
  }

  Future<bool> configureEnvironment(dynamic channelArgs) async {
    _apiKey = channelArgs[0] as String;

    if (channelArgs[1] == "mainnet") {
      _currentNetwork = rlyPolygonNetwork;
    } else if (channelArgs[1] == "mumbai") {
      _currentNetwork = rlyMumbaiNetwork;
    } else {
      print("The network ${channelArgs[1]} is not valid");
    }

    _currentNetwork!.setApiKey(_apiKey!);

    return true;
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
    if (_currentNetwork == null) {
      print("Missing network config");
      return false;
    }
    String txnHash = "";
    try {
      txnHash = await _currentNetwork!.claimRly();
    } catch (e) {
      print("Error: $e");
    }
    return txnHash;
  }
}
