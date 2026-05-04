import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
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
  VideoPlayerController? _videoPlayerController;
  ChewieController? _chewieController;
  final ApiService _apiService = ApiService();
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _initializePlayer();
  }

  Future<void> _initializePlayer() async {
    final streamUrl = _apiService.getStreamUrl(widget.channel.id);
    _videoPlayerController = VideoPlayerController.networkUrl(Uri.parse(streamUrl));

    try {
      await _videoPlayerController!.initialize();
      _chewieController = ChewieController(
        videoPlayerController: _videoPlayerController!,
        autoPlay: true,
        isLive: true,
        aspectRatio: _videoPlayerController!.value.aspectRatio,
        materialProgressColors: ChewieProgressColors(
          playedColor: AppColors.accent,
          handleColor: AppColors.accent,
        ),
        errorBuilder: (context, errorMessage) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error, color: AppColors.red, size: 42),
                const SizedBox(height: 10),
                const Text('Erreur de lecture', style: TextStyle(color: Colors.white)),
                TextButton(
                  onPressed: () {
                    setState(() => _hasError = false);
                    _initializePlayer();
                  },
                  child: const Text('Réessayer', style: TextStyle(color: AppColors.accent)),
                )
              ],
            ),
          );
        },
      );
      setState(() {});
    } catch (e) {
      setState(() => _hasError = true);
    }
  }

  @override
  void dispose() {
    _videoPlayerController?.dispose();
    _chewieController?.dispose();
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
          if (_chewieController != null && _chewieController!.videoPlayerController.value.isInitialized)
            Chewie(controller: _chewieController!)
          else if (_hasError)
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error, color: AppColors.red, size: 42),
                  const SizedBox(height: 10),
                  const Text('Flux indisponible', style: TextStyle(color: Colors.white)),
                  ElevatedButton(
                    onPressed: _initializePlayer,
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.accent),
                    child: const Text('Réessayer'),
                  )
                ],
              ),
            )
          else
            const Center(child: CircularProgressIndicator(color: AppColors.accent)),
          _buildOverlay(),
        ],
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
                width: 36, height: 36,
                fit: BoxFit.contain,
              ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    widget.channel.name,
                    style: GoogleFonts.syne(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    widget.channel.group ?? '',
                    style: const TextStyle(fontSize: 10, color: Colors.white60),
                  ),
                ],
              ),
            ),
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
