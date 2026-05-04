import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/channel.dart';

class ApiService {
  // 1. L'URL de ton backend sur Hugging Face
  static const String backendUrl = 'https://tafitaniaina-tvserveur.hf.space';

  // 2. Ta clé de sécurité (identique à celle du backend)
  static const String authKey = 'rtm_secret_key_2024_ultra';

  // Headers communs pour toutes les requêtes API (JSON)
  Map<String, String> get _apiHeaders => {
        'x-rtm-auth': authKey,
        'Accept': 'application/json',
      };

  // Headers spéciaux pour les requêtes de stream (force les URLs absolues)
  // Le serveur détecte X-RTM-Client: flutter et génère des URLs absolues
  // dans le M3U8 réécrit au lieu de chemins relatifs (/api/rtm/live?sid=...)
  Map<String, String> get _streamHeaders => {
        'x-rtm-auth': authKey,
        'X-RTM-Client': 'flutter',
        'X-Base-URL': backendUrl,
        'Accept': '*/*',
      };

  // Fonction pour décoder le Base64 envoyé par ton serveur
  String _decodeResponse(String body) {
    try {
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

  String getImageUrl(String? url) {
    if (url == null || url.isEmpty) return '';
    return '$backendUrl/api/rtm/img?u=${Uri.encodeComponent(url)}&auth=$authKey';
  }

  // URL du stream — le serveur recevra les headers _streamHeaders
  // via la méthode fetchStreamUrl() et retournera un M3U8 avec URLs absolues
  String getStreamUrl(String id) {
    return '$backendUrl/api/rtm/live?id=$id&auth=$authKey';
  }

  // NOUVELLE MÉTHODE : récupère le M3U8 avec URLs absolues pour Flutter
  // À utiliser dans le video player au lieu de passer getStreamUrl() directement
  Future<String> fetchStreamUrl(String id) async {
    final uri = Uri.parse('$backendUrl/api/rtm/live?id=$id&auth=$authKey');
    try {
      final response = await http.get(uri, headers: _streamHeaders);

      if (response.statusCode == 200) {
        final contentType = response.headers['content-type'] ?? '';
        final body = response.body;

        // Si c'est un M3U8 → on le reçoit déjà réécrit avec URLs absolues
        // grâce au header X-RTM-Client: flutter détecté côté serveur
        if (contentType.contains('mpegurl') ||
            contentType.contains('m3u') ||
            body.trimLeft().startsWith('#EXTM3U')) {
          // On retourne l'URL directe car le serveur va maintenant
          // générer des URLs absolues quand il voit X-RTM-Client: flutter
          return getStreamUrl(id);
        }

        return getStreamUrl(id);
      } else {
        throw Exception('Stream non disponible: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erreur stream: $e');
    }
  }

  // Headers à passer au video player natif Flutter (ex: video_player, better_player)
  // pour que chaque requête de segment M3U8 inclue le header d'auth
  Map<String, String> get videoPlayerHeaders => _streamHeaders;
}
