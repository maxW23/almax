import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';

class IsActiveGiftsManager {
  static final IsActiveGiftsManager _instance =
      IsActiveGiftsManager._internal();
  factory IsActiveGiftsManager() => _instance;

  IsActiveGiftsManager._internal() {
    _initialize();
  }

  final ValueNotifier<bool> isActiveNotifier = ValueNotifier<bool>(true);

  Future<void> _initialize() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final value = prefs.getBool('isActiveGifts') ?? true;
    isActiveNotifier.value = value;
  }

  Future<bool> getIsActiveGifts() async {
    return isActiveNotifier.value;
  }

  Future<void> setIsActiveGifts(bool value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isActiveGifts', value);
    isActiveNotifier.value = value;
  }
}

class IsMuteRoomManager {
  static final IsMuteRoomManager _instance = IsMuteRoomManager._internal();
  factory IsMuteRoomManager() => _instance;

  IsMuteRoomManager._internal() {
    _initialize();
  }

  final ValueNotifier<bool> isMuteNotifier = ValueNotifier<bool>(false);

  Future<void> _initialize() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final value = prefs.getBool('isMuteRoom') ?? false;
    isMuteNotifier.value = value;
  }

  Future<bool> getIsMute() async {
    return isMuteNotifier.value;
  }

  Future<void> setIsMute(bool value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isMuteRoom', value);
    isMuteNotifier.value = value;
  }
}

class IsActiveTopBarManager {
  static final IsActiveTopBarManager _instance =
      IsActiveTopBarManager._internal();
  factory IsActiveTopBarManager() => _instance;

  IsActiveTopBarManager._internal() {
    _initialize();
  }

  final ValueNotifier<bool> isActiveTopBarNotifier = ValueNotifier<bool>(true);

  Future<void> _initialize() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final value = prefs.getBool('isActiveTopBar') ?? true;
    isActiveTopBarNotifier.value = value;
  }

  Future<bool> getIsActiveTopBar() async {
    return isActiveTopBarNotifier.value;
  }

  Future<void> setIsActiveTopBar(bool value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isActiveTopBar', value);
    isActiveTopBarNotifier.value = value;
  }
}
