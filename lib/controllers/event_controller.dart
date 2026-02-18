import 'package:flutter/material.dart';
import '../models/event.dart';
import '../models/artist_track.dart';
import '../services/firestore_service.dart';
import '../services/external_music_service.dart';

class EventController extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();
  final ExternalMusicService _externalMusicService = ExternalMusicService();
  final Map<String, List<ArtistTrack>> _artistTracksCache = {};

  List<Event> _events = [];
  bool _isLoading = false;

  List<Event> get events => _events;
  bool get isLoading => _isLoading;

  void loadEvents() {
    _isLoading = true;
    notifyListeners();

    try {
      _events = _firestoreService.getEvents();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<List<ArtistTrack>> loadArtistTracks(
    String artist, {
    bool forceRefresh = false,
  }) async {
    final key = artist.toLowerCase().trim();
    if (!forceRefresh && _artistTracksCache.containsKey(key)) {
      return _artistTracksCache[key]!;
    }

    final tracks = await _externalMusicService.fetchArtistTopTracks(artist);
    _artistTracksCache[key] = tracks;
    return tracks;
  }

  @override
  void dispose() {
    _externalMusicService.dispose();
    super.dispose();
  }
}
