class Event {
  final String id;
  final String title;
  final String artist;
  final String description;
  final DateTime date;
  final String location;
  final double price;
  final String imageUrl;
  final List<String> images;
  final int availableTickets;
  final double rating;
  final String genre;
  final Map<String, int> tierAvailability;
  final Map<String, double> tierPrices;
  final int initialTickets;

  Event({
    required this.id,
    required this.title,
    required this.artist,
    required this.description,
    required this.date,
    required this.location,
    required this.price,
    required this.imageUrl,
    this.images = const [],
    required this.availableTickets,
    this.rating = 4.8,
    this.genre = 'Pop',
    this.tierAvailability = const {},
    this.tierPrices = const {},
    int? initialTickets,
  }) : initialTickets = initialTickets ?? availableTickets;

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      id: json['id'],
      title: json['title'],
      artist: json['artist'],
      description: json['description'],
      date: DateTime.parse(json['date']),
      location: json['location'],
      price: json['price'].toDouble(),
      imageUrl: json['imageUrl'],
      images: List<String>.from(json['images'] ?? []),
      availableTickets: json['availableTickets'],
      rating: (json['rating'] ?? 4.8).toDouble(),
      genre: json['genre'] ?? 'Pop',
      tierAvailability: Map<String, int>.from(json['tierAvailability'] ?? {}),
      tierPrices: Map<String, double>.from(
        (json['tierPrices'] ?? {}).map(
          (k, v) => MapEntry(k, (v as num).toDouble()),
        ),
      ),
      initialTickets: json['initialTickets'] ?? json['availableTickets'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'artist': artist,
      'description': description,
      'date': date.toIso8601String(),
      'location': location,
      'price': price,
      'imageUrl': imageUrl,
      'images': images,
      'availableTickets': availableTickets,
      'rating': rating,
      'genre': genre,
      'tierAvailability': tierAvailability,
      'tierPrices': tierPrices,
      'initialTickets': initialTickets,
    };
  }
}
