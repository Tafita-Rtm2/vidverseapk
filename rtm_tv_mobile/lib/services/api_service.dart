import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/channel.dart';

static const String backendUrl = 'https://tafitaniaina-tvserveur.hf.space';
  static const String authKey = 'rtm_secret_key_2024_ultra';

  Future<List<Channel>> fetchChannels() async {
    try {
      final response = await http.get(
        Uri.parse('$backendUrl/api/rtm/channels?limit=50000&auth=$authKey'),
        headers: {'x-rtm-auth': authKey},
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final List<dynamic> channelsJson = data['channels'] ?? [];
        return channelsJson.map((json) => Channel.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load channels');
      }
    } catch (e) {
      throw Exception('Error fetching channels: $e');
    }
  }

  Future<List<String>> fetchCountries() async {
    try {
      final response = await http.get(
        Uri.parse('$backendUrl/api/rtm/countries?auth=$authKey'),
        headers: {'x-rtm-auth': authKey},
      );
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return List<String>.from(data['countries'] ?? []);
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  String getImageUrl(String? url) {
    if (url == null || url.isEmpty) return '';
    return '$backendUrl/api/rtm/img?u=${Uri.encodeComponent(url)}&auth=$authKey';
  }

  String getStreamUrl(String id) {
    return '$backendUrl/api/rtm/live?id=$id&auth=$authKey';
  }
}
