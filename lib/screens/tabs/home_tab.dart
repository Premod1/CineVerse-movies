import 'package:flutter/material.dart';
import '../../models/movie_model.dart';
import '../../services/tmdb_service.dart';
import '../movie_detail_screen.dart';

class HomeTab extends StatefulWidget {
  final String username;

  const HomeTab({super.key, required this.username});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  final TmdbService _service = TmdbService();

  late Future<List<Movie>> _trendingFuture;
  late Future<List<Movie>> _nowPlayingFuture;
  late Future<List<Movie>> _topRatedFuture;

  int _selectedGenreId = 0; // 0 means all

  final List<Map<String, dynamic>> _quickGenres = const [
    {'id': 0, 'name': 'All', 'icon': Icons.local_fire_department},
    {'id': 28, 'name': 'Action', 'icon': Icons.flash_on},
    {'id': 878, 'name': 'Sci-Fi', 'icon': Icons.rocket_launch},
    {'id': 16, 'name': 'Animation', 'icon': Icons.animation},
    {'id': 35, 'name': 'Comedy', 'icon': Icons.sentiment_very_satisfied},
    {'id': 27, 'name': 'Horror', 'icon': Icons.nightlight_round},
    {'id': 18, 'name': 'Drama', 'icon': Icons.theater_comedy},
  ];

  @override
  void initState() {
    super.initState();
    _fetchMovies();
  }

  void _fetchMovies() {
    setState(() {
      _trendingFuture = _service.getTrendingMovies();
      _nowPlayingFuture = _service.getNowPlayingMovies();
      _topRatedFuture = _service.getTopRatedMovies();
    });
  }

  Future<void> _handleRefresh() async {
    _fetchMovies();
    try {
      await Future.wait([
        _trendingFuture,
        _nowPlayingFuture,
        _topRatedFuture,
      ]);
    } catch (_) {
      // Ignore refresh error as UI states handle snapshot errors
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.movie_filter_rounded, color: theme.colorScheme.primary, size: 24),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'CineVerse',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                Text(
                  'Powered by TMDB',
                  style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                ),
              ],
            ),
          ],
        ),
        elevation: 0,
        actions: [
          IconButton(
            tooltip: 'Refresh',
            icon: const Icon(Icons.refresh_rounded),
            onPressed: _handleRefresh,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _handleRefresh,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.only(bottom: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome Banner
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Hello, ${widget.username} 👋',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Explore what to watch today',
                          style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                        ),
                      ],
                    ),
                    CircleAvatar(
                      backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.1),
                      child: Icon(Icons.person, color: theme.colorScheme.primary),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // Hero Featured Movie Banner
              _buildHeroFeaturedBanner(),

              const SizedBox(height: 20),

              // Quick Genre Filter Chips
              _buildGenreChips(theme),

              const SizedBox(height: 20),

              // Trending Movies Section
              _buildSection(
                title: '🔥 Trending This Week',
                subtitle: 'Most watched right now across the globe',
                future: _trendingFuture,
              ),

              const SizedBox(height: 24),

              // Now Playing Section
              _buildSection(
                title: '🍿 In Theatres Now',
                subtitle: 'Catch the latest releases on big screens',
                future: _nowPlayingFuture,
              ),

              const SizedBox(height: 24),

              // Top Rated Movies Section
              _buildSection(
                title: '⭐ All-Time Top Rated',
                subtitle: 'Masterpieces loved by critics and fans',
                future: _topRatedFuture,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGenreChips(ThemeData theme) {
    return SizedBox(
      height: 42,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _quickGenres.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final genre = _quickGenres[index];
          final isSelected = _selectedGenreId == genre['id'];
          final id = genre['id'] as int;

          return FilterChip(
            selected: isSelected,
            showCheckmark: false,
            avatar: Icon(
              genre['icon'] as IconData,
              size: 16,
              color: isSelected ? Colors.white : theme.colorScheme.primary,
            ),
            label: Text(genre['name'] as String),
            labelStyle: TextStyle(
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected ? Colors.white : Colors.grey[800],
            ),
            backgroundColor: Colors.grey.withValues(alpha: 0.08),
            selectedColor: theme.colorScheme.primary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: BorderSide(
                color: isSelected
                    ? theme.colorScheme.primary
                    : Colors.grey.withValues(alpha: 0.2),
              ),
            ),
            onSelected: (_) {
              setState(() {
                _selectedGenreId = id;
                if (id == 0) {
                  _trendingFuture = _service.getTrendingMovies();
                } else {
                  _trendingFuture = _service.getMoviesByGenre(id);
                }
              });
            },
          );
        },
      ),
    );
  }

  Widget _buildHeroFeaturedBanner() {
    return FutureBuilder<List<Movie>>(
      future: _trendingFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Container(
            height: 200,
            margin: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Center(child: CircularProgressIndicator.adaptive()),
          );
        }

        final movies = snapshot.data ?? [];
        if (movies.isEmpty) return const SizedBox.shrink();

        final featured = movies.first;

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => MovieDetailScreen(
                    movieId: featured.id,
                    initialMovie: featured,
                  ),
                ),
              );
            },
            borderRadius: BorderRadius.circular(16),
            child: Container(
              height: 210,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.15),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    if (featured.backdropUrl != null || featured.posterUrl != null)
                      Image.network(
                        featured.backdropUrl ?? featured.posterUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) => Container(
                          color: Colors.indigo.shade900,
                          child: const Icon(Icons.movie, size: 50, color: Colors.white30),
                        ),
                      )
                    else
                      Container(color: Colors.indigo.shade900),

                    // Gradient overlay
                    DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withValues(alpha: 0.3),
                            Colors.black.withValues(alpha: 0.9),
                          ],
                          stops: const [0.2, 0.5, 1.0],
                        ),
                      ),
                    ),

                    // Content overlay
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.amber.shade700,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text(
                              'FEATURED SPOTLIGHT',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            featured.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              const Icon(Icons.star_rounded, color: Colors.amber, size: 18),
                              const SizedBox(width: 4),
                              Text(
                                '${featured.formattedRating} / 10',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                featured.releaseYear,
                                style: const TextStyle(color: Colors.white70, fontSize: 13),
                              ),
                              const Spacer(),
                              ElevatedButton.icon(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => MovieDetailScreen(
                                        movieId: featured.id,
                                        initialMovie: featured,
                                      ),
                                    ),
                                  );
                                },
                                icon: const Icon(Icons.info_outline, size: 16),
                                label: const Text('Details'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  foregroundColor: Colors.black87,
                                  elevation: 0,
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  textStyle: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSection({
    required String title,
    required String subtitle,
    required Future<List<Movie>> future,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 250,
          child: FutureBuilder<List<Movie>>(
            future: future,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: 4,
                  separatorBuilder: (_, _) => const SizedBox(width: 14),
                  itemBuilder: (_, _) => Container(
                    width: 130,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                );
              }

              if (snapshot.hasError) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline, color: Colors.red, size: 32),
                        const SizedBox(height: 8),
                        Text(
                          'Failed to load movies',
                          style: TextStyle(fontSize: 13, color: Colors.grey[700]),
                        ),
                        TextButton(
                          onPressed: _handleRefresh,
                          child: const Text('Try Again'),
                        ),
                      ],
                    ),
                  ),
                );
              }

              final movies = snapshot.data ?? [];
              if (movies.isEmpty) {
                return const Center(child: Text('No movies found.'));
              }

              return ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: movies.length,
                separatorBuilder: (_, _) => const SizedBox(width: 14),
                itemBuilder: (context, index) {
                  final movie = movies[index];
                  return _buildMovieCard(context, movie);
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildMovieCard(BuildContext context, Movie movie) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MovieDetailScreen(
              movieId: movie.id,
              initialMovie: movie,
            ),
          ),
        );
      },
      borderRadius: BorderRadius.circular(12),
      child: SizedBox(
        width: 130,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Poster with Rating Badge
            Expanded(
              child: Stack(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: Colors.grey.shade300,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 6,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    clipBehavior: Clip.antiAlias,
                    width: double.infinity,
                    child: movie.posterUrl != null
                        ? Image.network(
                            movie.posterUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (_, _, _) => const Center(
                              child: Icon(Icons.broken_image, color: Colors.grey),
                            ),
                          )
                        : const Center(
                            child: Icon(Icons.movie, color: Colors.grey, size: 40),
                          ),
                  ),
                  // Rating Badge
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.75),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.star_rounded, size: 14, color: Colors.amber),
                          const SizedBox(width: 2),
                          Text(
                            movie.formattedRating,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),

            // Title
            Text(
              movie.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),

            // Year & Genre
            const SizedBox(height: 2),
            Row(
              children: [
                Text(
                  movie.releaseYear,
                  style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                ),
                if (movie.genreNames.isNotEmpty) ...[
                  Text(' • ', style: TextStyle(color: Colors.grey[400])),
                  Expanded(
                    child: Text(
                      movie.genreNames.first,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
