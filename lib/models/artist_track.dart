class ArtistTrack {
  final String trackName;
  final String albumName;
  final String artworkUrl;
  final String? previewUrl;

  const ArtistTrack({
    required this.trackName,
    required this.albumName,
    required this.artworkUrl,
    this.previewUrl,
  });

  factory ArtistTrack.fromJson(Map<String, dynamic> json) {
    final preview = json['previewUrl']?.toString();
    return ArtistTrack(
      trackName: json['trackName']?.toString() ?? '',
      albumName: json['collectionName']?.toString() ?? 'Single',
      artworkUrl: json['artworkUrl100']?.toString() ?? '',
      previewUrl: (preview == null || preview.isEmpty) ? null : preview,
    );
  }
}
