class Event {
  final String id;
  final String title;
  final String artist;
  final String description;
  final DateTime date;
  final String location;
  final double price;
  final String imageUrl;
  final int availableTickets;

  Event({
    required this.id,
    required this.title,
    required this.artist,
    required this.description,
    required this.date,
    required this.location,
    required this.price,
    required this.imageUrl,
    required this.availableTickets,
  });

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
      availableTickets: json['availableTickets'],
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
      'availableTickets': availableTickets,
    };
  }
}
