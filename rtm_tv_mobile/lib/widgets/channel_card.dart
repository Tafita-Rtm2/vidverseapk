import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/channel.dart';
import '../utils/constants.dart';
import '../services/api_service.dart';

class ChannelCard extends StatelessWidget {
  final Channel channel;
  final VoidCallback onTap;
  final bool isNowPlaying;
  final ApiService _apiService = ApiService();

  ChannelCard({
    super.key,
    required this.channel,
    required this.onTap,
    this.isNowPlaying = false,
  });

  @override
  Widget build(BuildContext context) {
    final flag = countryFlags[channel.country?.toUpperCase()] ?? '';
    final logoUrl = _apiService.getImageUrl(channel.logo);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        decoration: BoxDecoration(
          color: isNowPlaying ? AppColors.s2 : AppColors.sf,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isNowPlaying
                ? AppColors.green.withOpacity(0.4)
                : Colors.white.withOpacity(0.05),
            width: 1,
          ),
          boxShadow: isNowPlaying ? [
            BoxShadow(
              color: AppColors.green.withOpacity(0.12),
              blurRadius: 2,
              spreadRadius: 0,
            )
          ] : null,
        ),
        child: Stack(
          children: [
            if (isNowPlaying)
              Positioned(
                top: 0, left: 0, right: 0,
                child: Container(
                  height: 2,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppColors.green, AppColors.accent],
                    ),
                  ),
                ),
              ),
            if (flag.isNotEmpty)
              Positioned(
                top: 5, right: 6,
                child: Text(flag, style: const TextStyle(fontSize: 12)),
              ),
            Padding(
              padding: const EdgeInsets.fromLTRB(7, 14, 7, 10),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (logoUrl.isNotEmpty)
                    Expanded(
                      flex: 3,
                      child: CachedNetworkImage(
                        imageUrl: logoUrl,
                        fit: BoxFit.contain,
                        width: 46,
                        height: 32,
                        placeholder: (context, url) => _buildFallbackLogo(),
                        errorWidget: (context, url, error) => _buildFallbackLogo(),
                      ),
                    )
                  else
                    Expanded(flex: 3, child: _buildFallbackLogo()),
                  const SizedBox(height: 6),
                  Expanded(
                    flex: 2,
                    child: Text(
                      channel.name,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.syne(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: AppColors.text,
                        height: 1.3,
                      ),
                    ),
                  ),
                  Text(
                    channel.group ?? '',
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 9,
                      color: AppColors.textTertiary,
                    ),
                  ),
                ],
              ),
            ),
            if (isNowPlaying)
              Positioned(
                bottom: 4, right: 4,
                child: Icon(Icons.play_circle, size: 12, color: AppColors.green),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildFallbackLogo() {
    return Container(
      width: 46, height: 32,
      decoration: BoxDecoration(
        color: AppColors.s3,
        borderRadius: BorderRadius.circular(6),
      ),
      child: const Icon(Icons.tv, size: 22, color: AppColors.textSecondary),
    );
  }
}
