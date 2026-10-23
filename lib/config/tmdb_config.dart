import 'package:flutter_dotenv/flutter_dotenv.dart';

class TmdbConfig {
  static String get apiKey =>
      dotenv.env['TMDB_API_KEY'] ?? 'd4d9e8262a0550c7b076be81d300fedc';

  static String get readAccessToken =>
      dotenv.env['TMDB_READ_ACCESS_TOKEN'] ??
      'eyJhbGciOiJIUzI1NiJ9.eyJhdWQiOiJkNGQ5ZTgyNjJhMDU1MGM3YjA3NmJlODFkMzAwZmVkYyIsIm5iZiI6MTc5Mjc2NTA4Mi41NjYwMDAyLCJzdWIiOiI2YWRiNmM5YTgxMzU1ODRmYTRkNjdiNDYiLCJzY29wZXMiOlsiYXBpX3JlYWQiXSwidmVyc2lvbiI6MX0.hC4lk6ijl5NlIvnJ1FYW2zpAZDQmnUoS7j4itqhNdTc';

  static const String baseUrl = 'https://api.themoviedb.org/3';
  static const String imageUrlW500 = 'https://image.tmdb.org/t/p/w500';
  static const String imageUrlW780 = 'https://image.tmdb.org/t/p/w780';
  static const String imageUrlOriginal = 'https://image.tmdb.org/t/p/original';

  static Map<String, String> get authHeaders => {
        'Authorization': 'Bearer $readAccessToken',
        'Accept': 'application/json',
      };

  // Common TMDB Movie Genres mapping
  static const Map<int, String> genreMap = {
    28: 'Action',
    12: 'Adventure',
    16: 'Animation',
    35: 'Comedy',
    80: 'Crime',
    99: 'Documentary',
    18: 'Drama',
    10751: 'Family',
    14: 'Fantasy',
    36: 'History',
    27: 'Horror',
    10402: 'Music',
    9648: 'Mystery',
    10749: 'Romance',
    878: 'Sci-Fi',
    10770: 'TV Movie',
    53: 'Thriller',
    10752: 'War',
    37: 'Western',
  };

  static String getGenreName(int id) {
    return genreMap[id] ?? 'Other';
  }
}
