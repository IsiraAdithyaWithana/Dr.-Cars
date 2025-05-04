class OBD2 {
  static bool isConnected = false;

  static Future<bool> connect() async {
    await Future.delayed(Duration(seconds: 1)); // Simulate connection
    isConnected = true;
    return true;
  }

  static void disconnect() {
    isConnected = false;
  }

  static double getRPM() =>
      2500 + (100 * (DateTime.now().second % 10)).toDouble();
  static double getCoolantTemp() => 85 + (DateTime.now().second % 5).toDouble();
  static double getSpeed() => 60 + (DateTime.now().second % 15).toDouble();
  static double getFuelConsumption() =>
      6.5 + (DateTime.now().second % 3).toDouble();

  static Future<Map<String, String>> getFreezeFrameData() async {
    return {
      'RPM': '2500 RPM',
      'Speed': '60 km/h',
      'Coolant Temp': '90°C',
      'Throttle Position': '20%',
      'Fuel Pressure': '45 PSI',
    };
  }

  static Future<void> clearDTC() async {
    await Future.delayed(Duration(seconds: 2));
  }
}
