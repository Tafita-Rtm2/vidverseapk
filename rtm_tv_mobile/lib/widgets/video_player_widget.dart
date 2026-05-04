import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:better_player_plus/better_player_plus.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/channel.dart';
import '../utils/constants.dart';
import '../services/api_service.dart';

class VideoPlayerWidget extends StatefulWidget {
  final Channel channel;
  final VoidCallback onClose;

  const VideoPlayerWidget({
    super.key,
    required this.channel,
    required this.onClose,
  });

  @override
  State<VideoPlayerWidget> createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  BetterPlayerController? _betterPlayerController;
  final ApiService _apiService = ApiService();
  bool _hasError = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializePlayer();
  }

  @override
  void didUpdateWidget(VideoPlayerWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Si on change de chaîne → on recharge le player
    if (oldWidget.channel.id != widget.channel.id) {
      _disposePlayer();
      _initializePlayer();
    }
  }

  void _disposePlayer() {
    _betterPlayerController?.dispose();
    _betterPlayerController = null;
  }

  Future<void> _initializePlayer() async {
    if (!mounted) return;

    setState(() {
      _hasError = false;
      _isLoading = true;
    });

    final streamUrl = _apiService.getStreamUrl(widget.channel.id);

    // ✅ Headers envoyés avec chaque requête HLS (manifest + segments)
    // Le serveur détecte X-RTM-Client: flutter → retourne URLs absolues
    final headers = {
      'x-rtm-auth': ApiService.authKey,
      'X-RTM-Client': 'flutter',
      'X-Base-URL': ApiService.backendUrl,
      'User-Agent': 'Mozilla/5.0 (Linux; Android 10) AppleWebKit/537.36',
      'Accept': '*/*',
      'Connection': 'keep-alive',
    };

    // ✅ Source HLS avec headers
    final dataSource = BetterPlayerDataSource(
      BetterPlayerDataSourceType.network,
      streamUrl,
      headers: headers,
      liveStream: true,
      // Notifie better_player que c'est du HLS
      videoFormat: BetterPlayerVideoFormat.hls,
      // Cache désactivé pour le live
      cacheConfiguration: const BetterPlayerCacheConfiguration(
        useCache: false,
      ),
      // Notifications désactivées
      notificationConfiguration: const BetterPlayerNotificationConfiguration(
        showNotification: false,
      ),
    );

    // ✅ Configuration du player — robuste pour le live IPTV
    final betterPlayerConfiguration = BetterPlayerConfiguration(
      autoPlay: true,
      looping: false,
      aspectRatio: 16 / 9,
      fit: BoxFit.contain,
      handleLifecycle: true,
      autoDispose: true,

      // Placeholder pendant le chargement
      placeholder: Container(
        color: Colors.black,
        child: const Center(
          child: CircularProgressIndicator(color: AppColors.accent),
        ),
      ),

      // ✅ Contrôles personnalisés
      controlsConfiguration: BetterPlayerControlsConfiguration(
        enableFullscreen: true,
        enablePlayPause: true,
        enableSkips: false,
        enableMute: true,
        enableProgressBar: false, // Pas de progress bar sur le live
        liveTextColor: AppColors.accent,
        progressBarPlayedColor: AppColors.accent,
        progressBarHandleColor: AppColors.accent,
        controlBarColor: Colors.black54,
        iconsColor: Colors.white,
        loadingColor: AppColors.accent,
        showControlsOnInitialize: false,
        enableOverflowMenu: false,
      ),

   // ✅ Buffering optimisé par défaut pour IPTV
    _betterPlayerController = BetterPlayerController(
      const BetterPlayerConfiguration(
        aspectRatio: 16 / 9,
        fit: BoxFit.contain,
        autoPlay: true,
        looping: false,
        deviceOrientationsAfterFullScreen: [
          DeviceOrientation.portraitUp,
        ],
      ),
      betterPlayerDataSource: dataSource,
    );

      // Callback erreur
      errorBuilder: (context, errorMessage) {
        return _buildErrorWidget();
      },
    );

    try {
      final controller = BetterPlayerController(betterPlayerConfiguration);

      // ✅ Écouter les events du player
      controller.addEventsListener((event) {
        if (!mounted) return;
        if (event.betterPlayerEventType == BetterPlayerEventType.initialized) {
          setState(() => _isLoading = false);
        }
        if (event.betterPlayerEventType == BetterPlayerEventType.exception) {
          setState(() {
            _hasError = true;
            _isLoading = false;
          });
        }
        if (event.betterPlayerEventType == BetterPlayerEventType.bufferingStart) {
          setState(() => _isLoading = true);
        }
        if (event.betterPlayerEventType == BetterPlayerEventType.bufferingEnd) {
          setState(() => _isLoading = false);
        }
      });

      await controller.setupDataSource(dataSource);

      if (mounted) {
        setState(() {
          _betterPlayerController = controller;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _hasError = true;
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _disposePlayer();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 280,
      width: double.infinity,
      color: Colors.black,
      child: Stack(
        children: [

          // ── Player ──
          if (_betterPlayerController != null && !_hasError)
            BetterPlayer(controller: _betterPlayerController!)
          else if (_hasError)
            _buildErrorWidget()
          else
            const Center(
              child: CircularProgressIndicator(color: AppColors.accent),
            ),

          // ── Overlay info chaîne (haut) ──
          _buildOverlay(),

          // ── Indicateur buffering ──
          if (_isLoading && !_hasError && _betterPlayerController != null)
            const Center(
              child: CircularProgressIndicator(color: AppColors.accent),
            ),

        ],
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Container(
      color: Colors.black,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error, color: AppColors.red, size: 42),
            const SizedBox(height: 10),
            const Text(
              'Flux indisponible',
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
            const SizedBox(height: 6),
            Text(
              widget.channel.name,
              style: const TextStyle(color: Colors.white54, fontSize: 12),
            ),
            const SizedBox(height: 14),
            ElevatedButton.icon(
              onPressed: () {
                _disposePlayer();
                _initializePlayer();
              },
              icon: const Icon(Icons.refresh, size: 16),
              label: const Text('Réessayer'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accent,
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(50),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOverlay() {
    return Positioned(
      top: 0, left: 0, right: 0,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.black.withOpacity(0.8), Colors.transparent],
          ),
        ),
        child: Row(
          children: [
            if (widget.channel.logo != null)
              CachedNetworkImage(
                imageUrl: _apiService.getImageUrl(widget.channel.logo),
                width: 36,
                height: 36,
                fit: BoxFit.contain,
                errorWidget: (c, e, s) => const Icon(
                  Icons.tv,
                  color: AppColors.accent,
                  size: 28,
                ),
              ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    widget.channel.name,
                    style: GoogleFonts.syne(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    widget.channel.group ?? '',
                    style: const TextStyle(fontSize: 10, color: Colors.white60),
                  ),
                ],
              ),
            ),
            // Badge LIVE
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: AppColors.red,
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text(
                'LIVE',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1,
                ),
              ),
            ),
            const SizedBox(width: 4),
            IconButton(
              icon: const Icon(Icons.close, color: Colors.white),
              onPressed: widget.onClose,
            ),
          ],
        ),
      ),
    );
  }
}
