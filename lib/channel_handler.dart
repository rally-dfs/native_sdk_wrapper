import 'dart:convert';

import 'package:convert/convert.dart';
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
    _channel.setMethodCallHandler(_handleChannelMethodCall);
  }

  Future<dynamic> _handleChannelMethodCall(MethodCall methodCall) async {
    String action = methodCall.method;
    switch (action) {
      case "createWallet":
        return await createWallet(methodCall.arguments);
      case "getWalletAddress":
        return await getWalletAddress();
      case "getAccountPhrase":
        return await getAccountPhrase();
      case "deleteWallet":
        return await deleteWallet();
      case "signMessage":
        return await signMessage(methodCall.arguments);
      case "configureEnvironment":
        return await configureEnvironment(methodCall.arguments);
      case "claimRly":
        return await claimRly();
      case "transferPermit":
        return await transferPermit(methodCall.arguments);
      case "getBalance":
        return await getBalance(methodCall.arguments);
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
    } else if (channelArgs[1] == "amoy") {
      _currentNetwork = rlyAmoyNetwork;
    } else {
      // ignore: avoid_print
      print("The network ${channelArgs[1]} is not valid");
    }

    _currentNetwork!.setApiKey(_apiKey!);

    return true;
  }

  Future<String> createWallet(dynamic channelArgs) async {
    bool saveToCloud = channelArgs["saveToCloud"] ?? true;
    bool rejectOnCloudSaveFailure =
        channelArgs["rejectOnCloudSaveFailure"] ?? saveToCloud;

    await WalletManager.getInstance().createWallet(
        storageOptions: KeyStorageConfig(
            saveToCloud: saveToCloud,
            rejectOnCloudSaveFailure: rejectOnCloudSaveFailure));

    return (await WalletManager.getInstance().getPublicAddress())!;
  }

  Future<String> getWalletAddress() async {
    String? address = await WalletManager.getInstance().getPublicAddress();
    return address ?? "no address";
  }

  /// Returns the mnemonic phrase of the current wallet.
  /// If no wallet exists, returns "no phrase"
  Future<String> getAccountPhrase() async {
    String? phrase = await WalletManager.getInstance().getAccountPhrase();
    return phrase ?? "no phrase";
  }

  Future<bool> deleteWallet() async {
    await WalletManager.getInstance().permanentlyDeleteWallet();
    return true;
  }

  Future<String> signMessage(dynamic channelArgs) async {
    String message = channelArgs["message"];
    Uint8List messageBytes = utf8.encode(message);
    Wallet? wallet = await WalletManager.getInstance().getWallet();
    if (wallet == null) {
      throw Exception(
          "Can not sign message without a wallet. Please create a wallet first.");
    }
    Uint8List rawSignature =
        wallet.signPersonalMessageToUint8List(messageBytes);

    String signatureAsHex = '0x${hex.encode(rawSignature)}';
    return signatureAsHex;
  }

  Future<dynamic> claimRly() async {
    if (_currentNetwork == null) {
      // ignore: avoid_print
      print("Missing network config");
      return false;
    }
    String txnHash = "";
    try {
      txnHash = await _currentNetwork!.claimRly();
    } catch (e) {
      // ignore: avoid_print
      print("Error: $e");
    }
    return txnHash;
  }

  /// Returns the balance of a given ERC-20 token held by the current wallet
  /// Defaults to using the RLY token if no token address is provided
  /// channelArgs is expected to be a hash, with the key "tokenAddress" used to configred which token to query.
  Future<String> getBalance(dynamic channelArgs) async {
    if (_currentNetwork == null) {
      return "Missing network config";
    }
    String? tokenAddress = channelArgs["tokenAddress"];
    String balance = "";
    try {
      balance =
          (await _currentNetwork!.getExactBalance(tokenAddress: tokenAddress))
              .toString();
    } catch (e) {
      // ignore: avoid_print
      print("Error: $e");
    }
    return balance;
  }

  /// Transfer ERC-20 tokens using permit
  /// Expects the channel call to include arguments in the form of a map with the following keys:
  /// destinationAddress: String
  /// amount: String
  /// tokenAddress: String (optional, default is RLY token address)
  /// wrapperType (optional, default is ExecuteMetaTransaction)
  Future<String?> transferPermit(dynamic channelArgs) async {
    if (_currentNetwork == null) {
      // ignore: avoid_print
      print("Missing network config");
      return null;
    }
    String destinationAddress = channelArgs["destinationAddress"];
    String amount = channelArgs["amount"];
    String? tokenAddress = channelArgs["tokenAddress"];

    MetaTxMethod method = channelArgs["wrapperType"] == "Permit"
        ? MetaTxMethod.Permit
        : MetaTxMethod.ExecuteMetaTransaction;

    String txnHash = "";
    try {
      txnHash = await _currentNetwork!.transferExact(
          destinationAddress, BigInt.parse(amount), method,
          tokenAddress: tokenAddress);
    } catch (e) {
      // ignore: avoid_print
      print("Error: $e");
    }
    return txnHash;
  }
}
