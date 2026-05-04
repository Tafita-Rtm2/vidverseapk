import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/channel.dart';

class ApiService {
  // 1. L'URL de ton backend sur Hugging Face
  static const String backendUrl = 'https://tafitaniaina-tvserveur.hf.space';
  
  // 2. Ta clé de sécurité (identique à celle du backend)
  static const String authKey = 'rtm_secret_key_2024_ultra';

  // Fonction pour décoder le Base64 envoyé par ton serveur
  String _decodeResponse(String body) {
    try {
      // Si le texte ne commence pas par '{', c'est qu'il est encodé en Base64
      if (!body.trim().startsWith('{')) {
        return utf8.decode(base64.decode(body.trim()));
      }
      return body;
    } catch (e) {
      print("Erreur de décodage: $e");
      return body;
    }
  }

  Future<List<Channel>> fetchChannels() async {
    try {
      final response = await http.get(
        Uri.parse('$backendUrl/api/rtm/channels?limit=50000&auth=$authKey'),
        headers: {
          'x-rtm-auth': authKey,
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        // Décodage du Base64 avant de lire le JSON
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
        headers: {'x-rtm-auth': authKey},
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

  String getImageUrl(String? url) {
    if (url == null || url.isEmpty) return '';
    return '$backendUrl/api/rtm/img?u=${Uri.encodeComponent(url)}&auth=$authKey';
  }

  String getStreamUrl(String id) {
    return '$backendUrl/api/rtm/live?id=$id&auth=$authKey';
  }
}
