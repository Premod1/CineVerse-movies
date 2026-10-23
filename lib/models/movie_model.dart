import '../config/tmdb_config.dart';

class Movie {
  final int id;
  final String title;
  final String overview;
  final String? posterPath;
  final String? backdropPath;
  final String releaseDate;
  final double voteAverage;
  final int voteCount;
  final List<int> genreIds;
  final double popularity;

  Movie({
    required this.id,
    required this.title,
    required this.overview,
    this.posterPath,
    this.backdropPath,
    required this.releaseDate,
    required this.voteAverage,
    required this.voteCount,
    required this.genreIds,
    required this.popularity,
  });

  factory Movie.fromJson(Map<String, dynamic> json) {
    return Movie(
      id: json['id'] ?? 0,
      title: json['title'] ?? json['name'] ?? 'Untitled',
      overview: json['overview'] ?? '',
      posterPath: json['poster_path'],
      backdropPath: json['backdrop_path'],
      releaseDate: json['release_date'] ?? json['first_air_date'] ?? '',
      voteAverage: (json['vote_average'] as num?)?.toDouble() ?? 0.0,
      voteCount: json['vote_count'] ?? 0,
      genreIds: (json['genre_ids'] as List<dynamic>?)
              ?.map((e) => (e as num).toInt())
              .toList() ??
          [],
      popularity: (json['popularity'] as num?)?.toDouble() ?? 0.0,
    );
  }

  String? get posterUrl => posterPath != null
      ? '${TmdbConfig.imageUrlW500}$posterPath'
      : null;

  String? get backdropUrl => backdropPath != null
      ? '${TmdbConfig.imageUrlW780}$backdropPath'
      : null;

  String get releaseYear {
    if (releaseDate.isEmpty) return 'N/A';
    try {
      return DateTime.parse(releaseDate).year.toString();
    } catch (_) {
      if (releaseDate.length >= 4) {
        return releaseDate.substring(0, 4);
      }
      return 'N/A';
    }
  }

  String get formattedRating => voteAverage.toStringAsFixed(1);

  List<String> get genreNames =>
      genreIds.map((id) => TmdbConfig.getGenreName(id)).toList();
}

class MovieDetail {
  final int id;
  final String title;
  final String overview;
  final String? posterPath;
  final String? backdropPath;
  final String releaseDate;
  final double voteAverage;
  final int voteCount;
  final int runtime;
  final String tagline;
  final String status;
  final List<String> genres;
  final int budget;
  final int revenue;

  MovieDetail({
    required this.id,
    required this.title,
    required this.overview,
    this.posterPath,
    this.backdropPath,
    required this.releaseDate,
    required this.voteAverage,
    required this.voteCount,
    required this.runtime,
    required this.tagline,
    required this.status,
    required this.genres,
    required this.budget,
    required this.revenue,
  });

  factory MovieDetail.fromJson(Map<String, dynamic> json) {
    return MovieDetail(
      id: json['id'] ?? 0,
      title: json['title'] ?? 'Untitled',
      overview: json['overview'] ?? '',
      posterPath: json['poster_path'],
      backdropPath: json['backdrop_path'],
      releaseDate: json['release_date'] ?? '',
      voteAverage: (json['vote_average'] as num?)?.toDouble() ?? 0.0,
      voteCount: json['vote_count'] ?? 0,
      runtime: json['runtime'] ?? 0,
      tagline: json['tagline'] ?? '',
      status: json['status'] ?? 'Unknown',
      genres: (json['genres'] as List<dynamic>?)
              ?.map((g) => (g['name'] as String? ?? ''))
              .where((name) => name.isNotEmpty)
              .toList() ??
          [],
      budget: json['budget'] ?? 0,
      revenue: json['revenue'] ?? 0,
    );
  }

  String? get posterUrl => posterPath != null
      ? '${TmdbConfig.imageUrlW500}$posterPath'
      : null;

  String? get backdropUrl => backdropPath != null
      ? '${TmdbConfig.imageUrlW780}$backdropPath'
      : null;

  String get releaseYear {
    if (releaseDate.isEmpty) return 'N/A';
    try {
      return DateTime.parse(releaseDate).year.toString();
    } catch (_) {
      if (releaseDate.length >= 4) return releaseDate.substring(0, 4);
      return 'N/A';
    }
  }

  String get formattedRuntime {
    if (runtime <= 0) return 'N/A';
    final hours = runtime ~/ 60;
    final minutes = runtime % 60;
    if (hours > 0 && minutes > 0) return '${hours}h ${minutes}m';
    if (hours > 0) return '${hours}h';
    return '${minutes}m';
  }

  String get formattedRating => voteAverage.toStringAsFixed(1);
}

class CastMember {
  final int id;
  final String name;
  final String character;
  final String? profilePath;

  CastMember({
    required this.id,
    required this.name,
    required this.character,
    this.profilePath,
  });

  factory CastMember.fromJson(Map<String, dynamic> json) {
    return CastMember(
      id: json['id'] ?? 0,
      name: json['name'] ?? 'Unknown',
      character: json['character'] ?? '',
      profilePath: json['profile_path'],
    );
  }

  String? get profileUrl => profilePath != null
      ? '${TmdbConfig.imageUrlW500}$profilePath'
      : null;
}
