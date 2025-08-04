import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/led_state.dart';

class ApiService {
  static const String defaultBaseUrl = 'http://192.168.1.100'; // Default IP
  String _baseUrl = defaultBaseUrl;
  static const Duration timeoutDuration = Duration(seconds: 10);

  // Getter for base URL
  String get baseUrl => _baseUrl;

  // Setter for base URL
  void setBaseUrl(String url) {
    _baseUrl = url.startsWith('http://') ? url : 'http://$url';
  }

  // Test connection to NodeMCU
  Future<bool> testConnection() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/status'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(timeoutDuration);

      return response.statusCode == 200;
    } catch (e) {
      print('Connection test failed: $e');
      return false;
    }
  }

  // Turn LED ON
  Future<LedState?> turnLedOn() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/led/on'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(timeoutDuration);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return LedState.fromJson(data);
      } else {
        throw HttpException(
            'HTTP ${response.statusCode}: ${response.reasonPhrase}');
      }
    } catch (e) {
      print('Error turning LED ON: $e');
      return null;
    }
  }

  // Turn LED OFF
  Future<LedState?> turnLedOff() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/led/off'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(timeoutDuration);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return LedState.fromJson(data);
      } else {
        throw HttpException(
            'HTTP ${response.statusCode}: ${response.reasonPhrase}');
      }
    } catch (e) {
      print('Error turning LED OFF: $e');
      return null;
    }
  }

  // Get LED status
  Future<LedState?> getLedStatus() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/status'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(timeoutDuration);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return LedState.fromJson(data);
      } else {
        throw HttpException(
            'HTTP ${response.statusCode}: ${response.reasonPhrase}');
      }
    } catch (e) {
      print('Error getting LED status: $e');
      return null;
    }
  }
}
