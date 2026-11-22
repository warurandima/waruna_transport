import 'package:shared_preferences/shared_preferences.dart';

class PinService {
  static const String _pinKey = 'app_pin';
  static const String defaultPin = '0000';

  /// Verifies if [enteredPin] matches the stored PIN.
  /// If no PIN has been set yet, defaults to "0000".
  Future<bool> verifyPin(String enteredPin) async {
    final prefs = await SharedPreferences.getInstance();
    final savedPin = prefs.getString(_pinKey) ?? defaultPin;
    return enteredPin == savedPin;
  }

  /// Changes the stored PIN to [newPin] after validating [oldPin].
  /// Returns true on success, false if [oldPin] was incorrect.
  Future<bool> changePin(String oldPin, String newPin) async {
    final isOldCorrect = await verifyPin(oldPin);
    if (!isOldCorrect) {
      return false;
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_pinKey, newPin);
    return true;
  }
}
