import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../utils/constants.dart';

class HeroCarousel extends StatefulWidget {
  final Function(int) onPlay;
  const HeroCarousel({super.key, required this.onPlay});

  @override
  State<HeroCarousel> createState() => _HeroCarouselState();
}

class _HeroCarouselState extends State<HeroCarousel> {
  int _currentIndex = 0;

  final List<Map<String, String>> heroData = [
    {
      'title': 'BeIN Sports 1',
      'cat': '⚽ Sport',
      'desc': 'Football, Ligue des Champions, NBA et tous les grands sports en direct',
      'bg': 'https://images.unsplash.com/photo-1540747913346-19e32dc3e97e?w=1200&q=80',
      'logo': 'https://upload.wikimedia.org/wikipedia/commons/thumb/e/e5/BeIN_Sports_logo.svg/200px-BeIN_Sports_logo.svg.png'
    },
    {
      'title': 'CNN International',
      'cat': '📰 Actualités',
      'desc': 'Informations mondiales en continu — analyses, reportages et breaking news 24h/24',
      'bg': 'https://images.unsplash.com/photo-1504711434969-e33886168f5c?w=1200&q=80',
      'logo': 'https://upload.wikimedia.org/wikipedia/commons/thumb/b/b1/CNN.svg/200px-CNN.svg.png'
    },
    {
      'title': 'Disney Channel',
      'cat': '🧒 Enfants',
      'desc': 'Dessins animés, aventures Disney et magie pour toute la famille',
      'bg': 'https://images.unsplash.com/photo-1611348586804-61bf6c080437?w=1200&q=80',
      'logo': 'https://upload.wikimedia.org/wikipedia/commons/thumb/3/36/Disney_Channel_logo.svg/200px-Disney_Channel_logo.svg.png'
    },
    {
      'title': 'Ciné+ Premier',
      'cat': '🎬 Films TV',
      'desc': 'Les plus grands films du cinéma mondial en exclusivité HD',
      'bg': 'https://images.unsplash.com/photo-1489599849927-2ee91cede3ba?w=1200&q=80',
      'logo': 'https://upload.wikimedia.org/wikipedia/commons/thumb/1/1e/Canal%2B_logo.svg/200px-Canal%2B_logo.svg.png'
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        CarouselSlider(
          options: CarouselOptions(
            height: 280,
            viewportFraction: 1.0,
            autoPlay: true,
            onPageChanged: (index, reason) {
              setState(() {
                _currentIndex = index;
              });
            },
          ),
          items: heroData.map((data) {
            return Builder(
              builder: (BuildContext context) {
                return Stack(
                  fit: StackFit.expand,
                  children: [
                    CachedNetworkImage(
                      imageUrl: data['bg']!,
                      fit: BoxFit.cover,
                      color: Colors.black.withOpacity(0.45),
                      colorBlendMode: BlendMode.darken,
                    ),
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [
                            AppColors.bg.withOpacity(0.9),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              },
            );
          }).toList(),
        ),
        Positioned(
          top: 12, left: 14,
          child: Container(
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.white.withOpacity(0.18)),
            ),
            child: CachedNetworkImage(
              imageUrl: heroData[_currentIndex]['logo']!,
              width: 56, height: 40,
              placeholder: (context, url) => const Icon(Icons.tv, color: Colors.white30),
              errorWidget: (context, url, error) => const Icon(Icons.tv, color: Colors.white30),
            ),
          ),
        ),
        Positioned(
          top: 12, right: 14,
          child: Row(
            children: heroData.asMap().entries.map((entry) {
              return Container(
                width: entry.key == _currentIndex ? 28 : 20,
                height: 3,
                margin: const EdgeInsets.symmetric(horizontal: 2.5),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(2),
                  color: entry.key == _currentIndex ? AppColors.accent : Colors.white.withOpacity(0.25),
                ),
              );
            }).toList(),
          ),
        ),
        Positioned(
          bottom: 20, left: 22, right: 22,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.accent,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.circle, size: 8, color: Colors.black),
                          const SizedBox(width: 4),
                          Text(
                            'EN DIRECT',
                            style: GoogleFonts.syne(
                              fontSize: 10, fontWeight: FontWeight.w800, color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      heroData[_currentIndex]['cat']!.toUpperCase(),
                      style: GoogleFonts.syne(
                        fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.accent, letterSpacing: 0.8,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      heroData[_currentIndex]['title']!,
                      style: GoogleFonts.syne(
                        fontSize: 20, fontWeight: FontWeight.w800, color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      heroData[_currentIndex]['desc']!,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 11, color: Colors.white60),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              ElevatedButton.icon(
                onPressed: () => widget.onPlay(_currentIndex),
                icon: const Icon(Icons.play_arrow, size: 18),
                label: const Text('Regarder'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accent,
                  foregroundColor: Colors.black,
                  textStyle: GoogleFonts.syne(fontWeight: FontWeight.w800, fontSize: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
