import 'package:flutter/material.dart' hide CarouselController;
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer/shimmer.dart';
import '../models/channel.dart';
import '../widgets/channel_card.dart';
import '../widgets/hero_carousel.dart';
import '../services/api_service.dart';
import '../utils/constants.dart';
import '../widgets/video_player_widget.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ApiService _apiService = ApiService();
  final ScrollController _scrollController = ScrollController();
  
  List<Channel> _allChannels = [];
  List<Channel> _filteredChannels = [];
  bool _isLoading = true;
  String _currentFilter = 'all';
  String _searchQuery = '';
  Channel? _selectedChannel;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    try {
      final channels = await _apiService.fetchChannels();
      setState(() {
        _allChannels = channels;
        _filteredChannels = channels;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e'), backgroundColor: AppColors.red),
        );
      }
    }
  }

  void _applyFilters() {
    setState(() {
      _filteredChannels = _allChannels.where((ch) {
        final matchesSearch = ch.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            (ch.group ?? '').toLowerCase().contains(_searchQuery.toLowerCase());

        bool matchesFilter = true;
        if (_currentFilter != 'all') {
          if (_currentFilter.startsWith('country:')) {
            matchesFilter = ch.country == _currentFilter.split(':')[1];
          } else {
            matchesFilter = (ch.group ?? '').toLowerCase().contains(_currentFilter.toLowerCase());
          }
        }
        return matchesSearch && matchesFilter;
      }).toList();
    });
  }

  void _playChannel(Channel ch) {
    setState(() {
      _selectedChannel = ch;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      drawer: _buildSidebar(),
      appBar: AppBar(
        backgroundColor: AppColors.bg.withOpacity(0.92),
        elevation: 0,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu, color: AppColors.accent),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        title: Row(
          children: [
            Image.asset('assets/logo.jpg', // Mis à jour en .jpg selon ton fichier
              width: 36, 
              height: 36, 
              errorBuilder: (c, e, s) => const Icon(Icons.tv, color: AppColors.accent)
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('TV LIVE', style: GoogleFonts.syne(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.accent)),
                Text('Rtm prod mg', style: GoogleFonts.syne(fontSize: 8, fontWeight: FontWeight.w700, color: AppColors.accent.withOpacity(0.7))),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.movie, color: AppColors.accent2),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          // ✅ FIX 1 : Le lecteur s'affiche au-dessus SI une chaîne est sélectionnée
          if (_selectedChannel != null)
            VideoPlayerWidget(
              channel: _selectedChannel!,
              onClose: () => setState(() => _selectedChannel = null),
            ),

          // ✅ FIX 2 : La barre de recherche est TOUJOURS présente ici
          _buildSearchBar(),

          Expanded(
            child: _isLoading
                ? _buildShimmerGrid()
                : CustomScrollView(
                    controller: _scrollController,
                    slivers: [
                      // Carrousel (uniquement si pas de vidéo pour gagner de la place)
                      if (_selectedChannel == null)
                        SliverToBoxAdapter(
                          child: HeroCarousel(onPlay: (idx) {
                             final ch = _allChannels.firstWhere((c) => (c.group ?? '').toLowerCase().contains('sport'), orElse: () => _allChannels.first);
                             _playChannel(ch);
                          }),
                        ),
                      
                      // ✅ FIX 3 : Les catégories deviennent "Sticky" (elles restent en haut au scroll)
                      SliverPersistentHeader(
                        pinned: true,
                        delegate: _StickyCategoryDelegate(
                          child: Container(
                            color: AppColors.bg, // Fond solide pour ne pas voir à travers au scroll
                            child: _buildCategoryPills(),
                          ),
                        ),
                      ),
                      
                      _buildGridHeader(),
                      _buildChannelGrid(),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
      child: TextField(
        onChanged: (val) {
          _searchQuery = val;
          _applyFilters();
        },
        style: const TextStyle(color: AppColors.text, fontSize: 13),
        decoration: InputDecoration(
          hintText: 'Rechercher une chaîne...',
          hintStyle: const TextStyle(color: AppColors.textTertiary),
          prefixIcon: const Icon(Icons.search, color: AppColors.accent, size: 18),
          filled: true,
          fillColor: Colors.white.withOpacity(0.04),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(50), borderSide: BorderSide(color: AppColors.accent.withOpacity(0.18))),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(50), borderSide: BorderSide(color: AppColors.accent.withOpacity(0.18))),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(50), borderSide: BorderSide(color: AppColors.accent.withOpacity(0.55))),
        ),
      ),
    );
  }

  Widget _buildCategoryPills() {
    final categories = ['all', 'sport', 'news', 'movies', 'kids', 'music', 'nature', 'radio'];
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final cat = categories[index];
          final isActive = _currentFilter == cat;
          return Padding(
            padding: const EdgeInsets.only(right: 5),
            child: ChoiceChip(
              label: Text(cat == 'all' ? 'Toutes' : cat.toUpperCase()),
              selected: isActive,
              onSelected: (selected) {
                setState(() => _currentFilter = cat);
                _applyFilters();
              },
              labelStyle: GoogleFonts.syne(fontSize: 11, fontWeight: FontWeight.w600, color: isActive ? Colors.black : AppColors.textSecondary),
              selectedColor: AppColors.accent,
              backgroundColor: Colors.transparent,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50), side: BorderSide(color: isActive ? Colors.transparent : Colors.white.withOpacity(0.08))),
              showCheckmark: false,
            ),
          );
        },
      ),
    );
  }

  Widget _buildGridHeader() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 5),
        child: Row(
          children: [
            Text(_currentFilter == 'all' ? '📺 Toutes les chaînes' : '📺 ${_currentFilter.toUpperCase()}', style: GoogleFonts.syne(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.text)),
            const SizedBox(width: 10),
            Text('${_filteredChannels.length} chaînes', style: TextStyle(fontSize: 11, color: AppColors.accent.withOpacity(0.45), fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }

  Widget _buildChannelGrid() {
    if (_filteredChannels.isEmpty) {
      return const SliverFillRemaining(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.search_off, size: 52, color: AppColors.accent),
              SizedBox(height: 10),
              Text('Aucun résultat', style: TextStyle(color: AppColors.textSecondary)),
            ],
          ),
        ),
      );
    }
    return SliverPadding(
      padding: const EdgeInsets.all(14),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, mainAxisSpacing: 10, crossAxisSpacing: 10, childAspectRatio: 4 / 3),
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final ch = _filteredChannels[index];
            return ChannelCard(channel: ch, isNowPlaying: _selectedChannel?.id == ch.id, onTap: () => _playChannel(ch));
          },
          childCount: _filteredChannels.length,
        ),
      ),
    );
  }

  Widget _buildShimmerGrid() {
    return Shimmer.fromColors(
      baseColor: AppColors.sf,
      highlightColor: AppColors.s2,
      child: GridView.builder(
        padding: const EdgeInsets.all(14),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, mainAxisSpacing: 10, crossAxisSpacing: 10, childAspectRatio: 4 / 3),
        itemCount: 10,
        itemBuilder: (context, index) => Container(decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14))),
      ),
    );
  }

  Widget _buildSidebar() {
    return Drawer(
      backgroundColor: AppColors.bg2,
      child: Column(
        children: [
          const SizedBox(height: 50),
          _sidebarHeader('Navigation'),
          _sidebarItem(Icons.live_tv, 'Toutes', 'all'),
          _sidebarItem(Icons.satellite_alt, 'Madagascar', 'country:MG'),
          const Divider(color: Colors.white10),
          _sidebarHeader('Catégories'),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _sidebarItem(Icons.sports_soccer, 'Sport', 'sport'),
                _sidebarItem(Icons.newspaper, 'Actualités', 'news'),
                _sidebarItem(Icons.child_care, 'Enfants', 'kids'),
                _sidebarItem(Icons.theaters, 'Films TV', 'movies'),
                _sidebarItem(Icons.music_note, 'Musique', 'music'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _sidebarHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 5),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(title.toUpperCase(), style: GoogleFonts.syne(fontSize: 9, fontWeight: FontWeight.w700, color: AppColors.accent.withOpacity(0.45), letterSpacing: 1.4)),
      ),
    );
  }

  Widget _sidebarItem(IconData icon, String title, String filter) {
    final isActive = _currentFilter == filter;
    return ListTile(
      leading: Icon(icon, size: 18, color: isActive ? AppColors.accent : AppColors.textSecondary),
      title: Text(title, style: GoogleFonts.dmSans(fontSize: 13, fontWeight: isActive ? FontWeight.w600 : FontWeight.w500, color: isActive ? AppColors.accent : AppColors.textSecondary)),
      onTap: () {
        setState(() => _currentFilter = filter);
        _applyFilters();
        Navigator.pop(context);
      },
      selected: isActive,
      selectedTileColor: AppColors.accent.withOpacity(0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
      dense: true,
    );
  }
}

// ✅ CLASSE POUR RENDRE LES CATÉGORIES "STICKY"
class _StickyCategoryDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;
  _StickyCategoryDelegate({required this.child});

  @override
  double get minExtent => 50.0;
  @override
  double get maxExtent => 50.0;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return child;
  }

  @override
  bool shouldRebuild(_StickyCategoryDelegate oldDelegate) => false;
}
