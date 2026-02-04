import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SeatPreferences {
  static ValueNotifier<bool> seatTakenNotifier = ValueNotifier<bool>(false);

  static const String seatTakenKey = "seat_taken";

  static Future<void> setSeatTaken(bool value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool(seatTakenKey, value);
    seatTakenNotifier.value = value; // Notify listeners
  }

  static Future<void> initializeSeatState() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    seatTakenNotifier.value = prefs.getBool(seatTakenKey) ?? false;
  }

  static bool get currentSeatTakenState => seatTakenNotifier.value;
}
