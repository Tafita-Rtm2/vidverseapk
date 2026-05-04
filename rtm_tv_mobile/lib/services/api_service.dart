import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/channel.dart';

class ApiService {
  // ✅ static const → accessibles depuis video_player_widget.dart sans instance
  static const String backendUrl = 'https://tafitaniaina-tvserveur.hf.space';
  static const String authKey = 'rtm_secret_key_2024_ultra';

  // Headers pour les requêtes JSON (fetchChannels, fetchCountries)
  Map<String, String> get _apiHeaders => {
        'x-rtm-auth': authKey,
        'Accept': 'application/json',
      };

  // Décode le Base64 retourné par le serveur
  String _decodeResponse(String body) {
    try {
      if (!body.trim().startsWith('{')) {
        return utf8.decode(base64.decode(body.trim()));
      }
      return body;
    } catch (e) {
      print('Erreur décodage: $e');
      return body;
    }
  }

  Future<List<Channel>> fetchChannels() async {
    try {
      final response = await http.get(
        Uri.parse('$backendUrl/api/rtm/channels?limit=50000&auth=$authKey'),
        headers: _apiHeaders,
      );
      if (response.statusCode == 200) {
        final String decodedBody = _decodeResponse(response.body);
        final Map<String, dynamic> data = json.decode(decodedBody);
        final List<dynamic> channelsJson = data['channels'] ?? [];
        return channelsJson.map((json) => Channel.fromJson(json)).toList();
      } else {
        throw Exception('Erreur serveur: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erreur de connexion: $e');
    }
  }

  Future<List<String>> fetchCountries() async {
    try {
      final response = await http.get(
        Uri.parse('$backendUrl/api/rtm/countries?auth=$authKey'),
        headers: _apiHeaders,
      );
      if (response.statusCode == 200) {
        final String decodedBody = _decodeResponse(response.body);
        final Map<String, dynamic> data = json.decode(decodedBody);
        return List<String>.from(data['countries'] ?? []);
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  // URL de l'image proxifiée par le backend
  String getImageUrl(String? url) {
    if (url == null || url.isEmpty) return '';
    return '$backendUrl/api/rtm/img?u=${Uri.encodeComponent(url)}&auth=$authKey';
  }

  // ✅ URL du stream — better_player envoie automatiquement les headers
  // à chaque requête (manifest M3U8 + tous les segments .ts)
  // Le serveur détecte X-RTM-Client: flutter → retourne URLs absolues dans le M3U8
  String getStreamUrl(String id) {
    return '$backendUrl/api/rtm/live?id=$id&auth=$authKey';
  }
}
