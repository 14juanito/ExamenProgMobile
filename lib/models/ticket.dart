class Ticket {
  final String id;
  final String userId;
  final String eventId;
  final String eventTitle;
  final String eventArtist;
  final DateTime eventDate;
  final String eventLocation;
  final double price;
  final DateTime purchaseDate;
  final bool isScanned;

  Ticket({
    required this.id,
    required this.userId,
    required this.eventId,
    required this.eventTitle,
    required this.eventArtist,
    required this.eventDate,
    required this.eventLocation,
    required this.price,
    required this.purchaseDate,
    this.isScanned = false,
  });

  factory Ticket.fromJson(Map<String, dynamic> json) {
    return Ticket(
      id: json['id'],
      userId: json['userId'],
      eventId: json['eventId'],
      eventTitle: json['eventTitle'],
      eventArtist: json['eventArtist'],
      eventDate: DateTime.parse(json['eventDate']),
      eventLocation: json['eventLocation'],
      price: json['price'].toDouble(),
      purchaseDate: DateTime.parse(json['purchaseDate']),
      isScanned: json['isScanned'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'eventId': eventId,
      'eventTitle': eventTitle,
      'eventArtist': eventArtist,
      'eventDate': eventDate.toIso8601String(),
      'eventLocation': eventLocation,
      'price': price,
      'purchaseDate': purchaseDate.toIso8601String(),
      'isScanned': isScanned,
    };
  }
}
