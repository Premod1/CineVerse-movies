import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/tmdb_config.dart';
import '../models/movie_model.dart';

class TmdbService {
  final http.Client _client;

  TmdbService({http.Client? client}) : _client = client ?? http.Client();

  Uri _buildUri(String path, [Map<String, String>? queryParams]) {
    final params = <String, String>{
      'language': 'en-US',
      ...?queryParams,
    };
    return Uri.parse('${TmdbConfig.baseUrl}$path')
        .replace(queryParameters: params);
  }

  Future<List<Movie>> getTrendingMovies({String timeWindow = 'day'}) async {
    try {
      final uri = _buildUri('/trending/movie/$timeWindow');
      final response = await _client.get(uri, headers: TmdbConfig.authHeaders);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final results = data['results'] as List<dynamic>? ?? [];
        return results.map((e) => Movie.fromJson(e)).toList();
      } else {
        throw Exception('Failed to load trending movies (${response.statusCode})');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<List<Movie>> getNowPlayingMovies({int page = 1}) async {
    try {
      final uri = _buildUri('/movie/now_playing', {'page': page.toString()});
      final response = await _client.get(uri, headers: TmdbConfig.authHeaders);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final results = data['results'] as List<dynamic>? ?? [];
        return results.map((e) => Movie.fromJson(e)).toList();
      } else {
        throw Exception('Failed to load now playing movies (${response.statusCode})');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<List<Movie>> getPopularMovies({int page = 1}) async {
    try {
      final uri = _buildUri('/movie/popular', {'page': page.toString()});
      final response = await _client.get(uri, headers: TmdbConfig.authHeaders);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final results = data['results'] as List<dynamic>? ?? [];
        return results.map((e) => Movie.fromJson(e)).toList();
      } else {
        throw Exception('Failed to load popular movies (${response.statusCode})');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<List<Movie>> getTopRatedMovies({int page = 1}) async {
    try {
      final uri = _buildUri('/movie/top_rated', {'page': page.toString()});
      final response = await _client.get(uri, headers: TmdbConfig.authHeaders);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final results = data['results'] as List<dynamic>? ?? [];
        return results.map((e) => Movie.fromJson(e)).toList();
      } else {
        throw Exception('Failed to load top rated movies (${response.statusCode})');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<List<Movie>> getMoviesByGenre(int genreId, {int page = 1}) async {
    try {
      final uri = _buildUri('/discover/movie', {
        'with_genres': genreId.toString(),
        'sort_by': 'popularity.desc',
        'page': page.toString(),
      });
      final response = await _client.get(uri, headers: TmdbConfig.authHeaders);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final results = data['results'] as List<dynamic>? ?? [];
        return results.map((e) => Movie.fromJson(e)).toList();
      } else {
        throw Exception('Failed to load movies by genre (${response.statusCode})');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<List<Movie>> searchMovies(String query, {int page = 1}) async {
    if (query.trim().isEmpty) return [];

    try {
      final uri = _buildUri('/search/movie', {
        'query': query,
        'page': page.toString(),
        'include_adult': 'false',
      });
      final response = await _client.get(uri, headers: TmdbConfig.authHeaders);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final results = data['results'] as List<dynamic>? ?? [];
        return results.map((e) => Movie.fromJson(e)).toList();
      } else {
        throw Exception('Failed to search movies (${response.statusCode})');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<MovieDetail> getMovieDetails(int movieId) async {
    try {
      final uri = _buildUri('/movie/$movieId');
      final response = await _client.get(uri, headers: TmdbConfig.authHeaders);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return MovieDetail.fromJson(data);
      } else {
        throw Exception('Failed to load movie details (${response.statusCode})');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<List<CastMember>> getMovieCredits(int movieId) async {
    try {
      final uri = _buildUri('/movie/$movieId/credits');
      final response = await _client.get(uri, headers: TmdbConfig.authHeaders);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final cast = data['cast'] as List<dynamic>? ?? [];
        return cast.take(15).map((e) => CastMember.fromJson(e)).toList();
      } else {
        throw Exception('Failed to load cast (${response.statusCode})');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<List<Movie>> getSimilarMovies(int movieId) async {
    try {
      final uri = _buildUri('/movie/$movieId/similar');
      final response = await _client.get(uri, headers: TmdbConfig.authHeaders);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final results = data['results'] as List<dynamic>? ?? [];
        return results.map((e) => Movie.fromJson(e)).toList();
      } else {
        return [];
      }
    } catch (e) {
      return [];
    }
  }
}
