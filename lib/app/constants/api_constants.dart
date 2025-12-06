// lib/app/constants/api_constants.dart
class ApiConstants {
  // Weather API
  static const String weatherApiKey = "cd8d43040072cb4f0dd994dcdd5892a4";
  static const String weatherBaseUrl = "https://api.openweathermap.org/data/2.5";
  
  // Plant API (Perenual)
  static const String plantApiKey = "sk-pIqP675d5961a23537800"; // Ganti dengan key Anda
  static const String plantBaseUrl = "https://perenual.com/api";
  
  // Timeouts
  static const Duration connectTimeout = Duration(seconds: 10);
  static const Duration receiveTimeout = Duration(seconds: 10);
}
