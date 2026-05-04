import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/channel.dart';

class ApiService {
  // 1. L'URL de ton backend sur Hugging Face
  // Note : Assure-toi que l'URL ne finit pas par un slash ici
  static const String backendUrl = 'https://tafitaniaina-tvserveur.hf.space';
  
  // 2. Ta clé de sécurité (doit être IDENTIQUE à celle du serveur)
  static const String authKey = 'rtm_secret_key_2024_ultra';

  // ═══════════════════════════════════════════════════════════════
  // ░░░ DÉCODEUR DE RÉPONSE (Base64 -> JSON) ░░░
  // ═══════════════════════════════════════════════════════════════
  String _decodeResponse(String body) {
    if (body.isEmpty) return body;
    
    try {
      final trimmedBody = body.trim();
      
      // Si le texte commence par '{', c'est déjà du JSON, on le renvoie tel quel
      if (trimmedBody.startsWith('{') || trimmedBody.startsWith('[')) {
        return trimmedBody;
      }
      
      // Sinon, on décode le Base64 de manière sécurisée
      return utf8.decode(base64Decode(trimmedBody));
    } catch (e) {
      print("❌ Erreur de décodage API: $e");
      // En cas d'erreur, on renvoie le corps original pour éviter le crash
      return body;
    }
  }

  // ═══════════════════════════════════════════════════════════════
  // ░░░ RÉCUPÉRATION DES CHAÎNES ░░░
  // ═══════════════════════════════════════════════════════════════
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
        final String decodedBody = _decodeResponse(response.body);
        final Map<String, dynamic> data = json.decode(decodedBody);
        
        final List<dynamic> channelsJson = data['channels'] ?? [];
        return channelsJson.map((json) => Channel.fromJson(json)).toList();
      } else {
        print('⚠️ Erreur serveur: ${response.statusCode}');
        throw Exception('Erreur serveur: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Erreur de connexion fetchChannels: $e');
      throw Exception('Erreur de connexion: $e');
    }
  }

  // ═══════════════════════════════════════════════════════════════
  // ░░░ RÉCUPÉRATION DES PAYS ░░░
  // ═══════════════════════════════════════════════════════════════
  Future<List<String>> fetchCountries() async {
    try {
      final response = await http.get(
        Uri.parse('$backendUrl/api/rtm/countries?auth=$authKey'),
        headers: {
          'x-rtm-auth': authKey,
        },
      );
      
      if (response.statusCode == 200) {
        final String decodedBody = _decodeResponse(response.body);
        final Map<String, dynamic> data = json.decode(decodedBody);
        return List<String>.from(data['countries'] ?? []);
      }
      return [];
    } catch (e) {
      print('❌ Erreur fetchCountries: $e');
      return [];
    }
  }

  // ═══════════════════════════════════════════════════════════════
  // ░░░ GÉNÉRATION DES URLS (IMAGE & STREAM) ░░░
  // ═══════════════════════════════════════════════════════════════
  
  // URL pour les logos via le proxy du serveur
  String getImageUrl(String? url) {
    if (url == null || url.isEmpty) return '';
    return '$backendUrl/api/rtm/img?u=${Uri.encodeComponent(url)}&auth=$authKey';
  }

  // URL pour le flux vidéo (C'est ici que la magie opère pour l'APK)
  String getStreamUrl(String id) {
    // On ajoute un faux paramètre .m3u8 pour aider les lecteurs Android (Ex: Better Player)
    return '$backendUrl/api/rtm/live?id=$id&auth=$authKey&ext=.m3u8';
  }
}
