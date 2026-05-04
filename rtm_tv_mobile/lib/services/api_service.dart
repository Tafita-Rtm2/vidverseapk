import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/channel.dart';

class ApiService {
  // L'adresse de ton serveur
  static const String backendUrl = 'https://tafitaniaina-tvserveur.hf.space';
  
  // CETTE CLÉ DOIT ÊTRE LA MÊME QUE DANS TON BACKEND (RTM_GK ou AUTH_KEY)
  static const String authKey = 'rtm_secret_key_2024_ultra';

  Future<List<Channel>> fetchChannels() async {
    try {
      final response = await http.get(
        Uri.parse('$backendUrl/api/rtm/channels?limit=50000'),
        headers: {
          'x-rtm-auth': authKey,
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        // Ton backend utilise un encodage Base64 (fonction enc)
        // Mais pour les routes classiques, il semble envoyer du JSON direct
        final Map<String, dynamic> data = json.decode(response.body);
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
        Uri.parse('$backendUrl/api/rtm/countries'),
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
    // Pour les images, ton backend utilise le query param 'auth'
    return '$backendUrl/api/rtm/img?u=${Uri.encodeComponent(url)}&auth=$authKey';
  }

  String getStreamUrl(String id) {
    // Pour le live, ton backend utilise le query param 'auth' ou l'ID direct
    return '$backendUrl/api/rtm/live?id=$id&auth=$authKey';
  }
}
