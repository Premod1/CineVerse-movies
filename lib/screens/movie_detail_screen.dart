import 'package:flutter/material.dart';
import '../models/movie_model.dart';
import '../services/tmdb_service.dart';

class MovieDetailScreen extends StatefulWidget {
  final int movieId;
  final Movie? initialMovie;

  const MovieDetailScreen({
    super.key,
    required this.movieId,
    this.initialMovie,
  });

  @override
  State<MovieDetailScreen> createState() => _MovieDetailScreenState();
}

class _MovieDetailScreenState extends State<MovieDetailScreen> {
  final TmdbService _service = TmdbService();
  late Future<MovieDetail> _movieDetailFuture;
  late Future<List<CastMember>> _castFuture;
  late Future<List<Movie>> _similarFuture;
  bool _isFavorite = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    _movieDetailFuture = _service.getMovieDetails(widget.movieId);
    _castFuture = _service.getMovieCredits(widget.movieId);
    _similarFuture = _service.getSimilarMovies(widget.movieId);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final fallbackPoster = widget.initialMovie?.posterUrl;
    final fallbackBackdrop = widget.initialMovie?.backdropUrl;
    final fallbackTitle = widget.initialMovie?.title ?? 'Movie Details';

    return Scaffold(
      body: FutureBuilder<MovieDetail>(
        future: _movieDetailFuture,
        builder: (context, snapshot) {
          final detail = snapshot.data;
          final title = detail?.title ?? fallbackTitle;
          final backdropUrl = detail?.backdropUrl ?? fallbackBackdrop;
          final posterUrl = detail?.posterUrl ?? fallbackPoster;
          final overview = detail?.overview ?? widget.initialMovie?.overview ?? '';
          final rating = detail?.formattedRating ?? widget.initialMovie?.formattedRating ?? '0.0';
          final year = detail?.releaseYear ?? widget.initialMovie?.releaseYear ?? '';
          final runtime = detail?.formattedRuntime ?? '';
          final genres = detail?.genres ?? widget.initialMovie?.genreNames ?? [];

          return CustomScrollView(
            slivers: [
              // Sliver App Bar with Backdrop Image
              SliverAppBar(
                expandedHeight: 320.0,
                pinned: true,
                stretch: true,
                backgroundColor: theme.colorScheme.surface,
                leading: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: CircleAvatar(
                    backgroundColor: Colors.black.withValues(alpha: 0.5),
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                ),
                actions: [
                  Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: CircleAvatar(
                      backgroundColor: Colors.black.withValues(alpha: 0.5),
                      child: IconButton(
                        icon: Icon(
                          _isFavorite ? Icons.favorite : Icons.favorite_border,
                          color: _isFavorite ? Colors.redAccent : Colors.white,
                          size: 20,
                        ),
                        onPressed: () {
                          setState(() {
                            _isFavorite = !_isFavorite;
                          });
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                _isFavorite ? 'Added to Watchlist' : 'Removed from Watchlist',
                              ),
                              duration: const Duration(seconds: 1),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      if (backdropUrl != null || posterUrl != null)
                        Image.network(
                          backdropUrl ?? posterUrl!,
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Container(
                              color: Colors.grey.shade900,
                              child: const Center(
                                child: CircularProgressIndicator.adaptive(strokeWidth: 2),
                              ),
                            );
                          },
                          errorBuilder: (context, error, stackTrace) => Container(
                            color: Colors.grey.shade900,
                            child: const Center(
                              child: Icon(Icons.movie, size: 64, color: Colors.white54),
                            ),
                          ),
                        )
                      else
                        Container(
                          color: Colors.grey.shade900,
                          child: const Center(
                            child: Icon(Icons.movie, size: 64, color: Colors.white54),
                          ),
                        ),
                      // Gradient Overlay for smooth transition to content
                      DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.black.withValues(alpha: 0.4),
                              Colors.transparent,
                              theme.scaffoldBackgroundColor.withValues(alpha: 0.8),
                              theme.scaffoldBackgroundColor,
                            ],
                            stops: const [0.0, 0.4, 0.85, 1.0],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Content Body
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header Card with Poster and Quick Stats
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Poster Image
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              width: 105,
                              height: 155,
                              decoration: BoxDecoration(
                                color: Colors.grey.shade800,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.25),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: posterUrl != null
                                  ? Image.network(
                                      posterUrl,
                                      fit: BoxFit.cover,
                                      loadingBuilder: (context, child, loadingProgress) {
                                        if (loadingProgress == null) return child;
                                        return Container(
                                          color: Colors.grey.shade800,
                                          child: const Center(
                                            child: CircularProgressIndicator.adaptive(strokeWidth: 2),
                                          ),
                                        );
                                      },
                                      errorBuilder: (_, _, _) => const Icon(
                                        Icons.broken_image,
                                        color: Colors.white54,
                                      ),
                                    )
                                  : const Icon(Icons.movie, color: Colors.white54),
                            ),
                          ),
                          const SizedBox(width: 16),

                          // Title and Metadata
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  title,
                                  style: theme.textTheme.headlineSmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                if (detail?.tagline.isNotEmpty == true) ...[
                                  const SizedBox(height: 4),
                                  Text(
                                    '"${detail!.tagline}"',
                                    style: TextStyle(
                                      fontStyle: FontStyle.italic,
                                      color: Colors.grey[600],
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                                const SizedBox(height: 12),

                                // Badges Row: Year, Runtime, Rating
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 6,
                                  children: [
                                    if (year.isNotEmpty)
                                      _buildBadge(
                                        context,
                                        icon: Icons.calendar_today,
                                        label: year,
                                        color: Colors.blue.shade700,
                                      ),
                                    if (runtime.isNotEmpty)
                                      _buildBadge(
                                        context,
                                        icon: Icons.access_time,
                                        label: runtime,
                                        color: Colors.teal.shade700,
                                      ),
                                    _buildBadge(
                                      context,
                                      icon: Icons.star_rounded,
                                      label: '$rating / 10',
                                      color: Colors.amber.shade800,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Genres Chips
                      if (genres.isNotEmpty) ...[
                        Wrap(
                          spacing: 8,
                          runSpacing: 6,
                          children: genres.map((g) {
                            return Chip(
                              label: Text(
                                g,
                                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                              ),
                              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
                              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.1),
                              side: BorderSide(color: theme.colorScheme.primary.withValues(alpha: 0.2)),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 20),
                      ],

                      // Overview Section
                      Text(
                        'Storyline',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        overview.isNotEmpty
                            ? overview
                            : 'No synopsis available for this movie at the moment.',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          height: 1.5,
                          color: Colors.grey[800],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Top Cast Section
                      Text(
                        'Top Cast',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildCastSection(),
                      const SizedBox(height: 24),

                      // Similar Movies Section
                      Text(
                        'You May Also Like',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildSimilarMoviesSection(),
                      const SizedBox(height: 36),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildBadge(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCastSection() {
    return FutureBuilder<List<CastMember>>(
      future: _castFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox(
            height: 110,
            child: Center(child: CircularProgressIndicator.adaptive()),
          );
        }
        final cast = snapshot.data ?? [];
        if (cast.isEmpty) {
          return Text('No cast information available.', style: TextStyle(color: Colors.grey[600]));
        }

        return SizedBox(
          height: 125,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: cast.length,
            separatorBuilder: (_, _) => const SizedBox(width: 14),
            itemBuilder: (context, index) {
              final member = cast[index];
              return SizedBox(
                width: 78,
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: Colors.grey[300],
                      backgroundImage: member.profileUrl != null
                          ? NetworkImage(member.profileUrl!)
                          : null,
                      child: member.profileUrl == null
                          ? const Icon(Icons.person, color: Colors.grey, size: 32)
                          : null,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      member.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                    ),
                    Text(
                      member.character,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 10, color: Colors.grey[600]),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildSimilarMoviesSection() {
    return FutureBuilder<List<Movie>>(
      future: _similarFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox(
            height: 180,
            child: Center(child: CircularProgressIndicator.adaptive()),
          );
        }
        final movies = snapshot.data ?? [];
        if (movies.isEmpty) {
          return Text('No recommendations available.', style: TextStyle(color: Colors.grey[600]));
        }

        return SizedBox(
          height: 200,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: movies.length,
            separatorBuilder: (_, _) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final movie = movies[index];
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
                borderRadius: BorderRadius.circular(10),
                child: SizedBox(
                  width: 110,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Container(
                          width: 110,
                          height: 150,
                          color: Colors.grey[300],
                          child: movie.posterUrl != null
                              ? Image.network(
                                  movie.posterUrl!,
                                  fit: BoxFit.cover,
                                  loadingBuilder: (context, child, loadingProgress) {
                                    if (loadingProgress == null) return child;
                                    return Container(
                                      color: Colors.grey.shade300,
                                      child: const Center(
                                        child: SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: CircularProgressIndicator.adaptive(strokeWidth: 2),
                                        ),
                                      ),
                                    );
                                  },
                                  errorBuilder: (_, _, _) => const Icon(Icons.broken_image),
                                )
                              : const Icon(Icons.movie),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        movie.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
