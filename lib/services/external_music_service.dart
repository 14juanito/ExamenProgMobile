import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/artist_track.dart';

class ExternalMusicService {
  final http.Client _client;

  ExternalMusicService({http.Client? client}) : _client = client ?? http.Client();

  Future<List<ArtistTrack>> fetchArtistTopTracks(
    String artist, {
    int limit = 6,
  }) async {
    final query = artist.trim();
    if (query.isEmpty) return const [];

    final uri = Uri.parse(
      'https://itunes.apple.com/search'
      '?term=${Uri.encodeQueryComponent(query)}'
      '&entity=song&limit=$limit',
    );

    final response = await _client.get(uri);
    if (response.statusCode != 200) {
      throw Exception('External API error (${response.statusCode})');
    }

    final data = jsonDecode(response.body);
    if (data is! Map<String, dynamic>) {
      return const [];
    }

    final results = data['results'];
    if (results is! List) {
      return const [];
    }

    return results
        .whereType<Map>()
        .map((item) => ArtistTrack.fromJson(Map<String, dynamic>.from(item)))
        .where((track) => track.trackName.isNotEmpty)
        .toList();
  }

  void dispose() {
    _client.close();
  }
}
