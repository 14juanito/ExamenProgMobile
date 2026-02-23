import 'dart:math';
import '../models/event.dart';
import '../models/ticket.dart';

/// In-memory data store to replace Firebase for front-end demonstrations.
/// Keeps events and tickets locally so the UI can run without backend access.
class FirestoreService {
  FirestoreService._internal() {
    _seedEvents();
  }

  static final FirestoreService _instance = FirestoreService._internal();
  factory FirestoreService() => _instance;

  final List<Event> _events = [];
  final List<Ticket> _tickets = [];
  final Map<String, Map<String, int>> _initialTierStock = {};

  List<Event> getEvents() => List.unmodifiable(_events);

  List<Ticket> getUserTickets(String userId) {
    return _tickets.where((t) => t.userId == userId).toList(growable: false);
  }

  Future<void> purchaseTicket(Ticket ticket) async {
    final eventIndex = _events.indexWhere((e) => e.id == ticket.eventId);
    if (eventIndex == -1) throw Exception('Événement introuvable');
    final e = _events[eventIndex];

    final remainingTier =
        (e.tierAvailability[ticket.seatCategory] ?? 0) - ticket.quantity;
    if (remainingTier < 0) {
      throw Exception('Plus assez de billets ${ticket.seatCategory}');
    }

    final updatedTierAvailability = Map<String, int>.from(e.tierAvailability);
    updatedTierAvailability[ticket.seatCategory] = remainingTier;

    final newAvailable = e.availableTickets - ticket.quantity;
    _events[eventIndex] = Event(
      id: e.id,
      title: e.title,
      artist: e.artist,
      description: e.description,
      date: e.date,
      location: e.location,
      price: e.price,
      imageUrl: e.imageUrl,
      images: e.images,
      availableTickets: newAvailable,
      rating: e.rating,
      genre: e.genre,
      tierAvailability: updatedTierAvailability,
      tierPrices: e.tierPrices,
      initialTickets: e.initialTickets,
    );

    _tickets.add(ticket);
  }

  Future<void> scanTicket(String ticketId) async {
    final index = _tickets.indexWhere((t) => t.id == ticketId);
    if (index != -1) {
      final current = _tickets[index];
      _tickets[index] = Ticket(
        id: current.id,
        userId: current.userId,
        eventId: current.eventId,
        eventTitle: current.eventTitle,
        eventArtist: current.eventArtist,
        eventDate: current.eventDate,
        eventLocation: current.eventLocation,
        price: current.price,
        purchaseDate: current.purchaseDate,
        isScanned: true,
        seatCategory: current.seatCategory,
        quantity: current.quantity,
        paymentOperator: current.paymentOperator,
        payerPhone: current.payerPhone,
      );
    }
  }

  Future<Ticket?> getTicketById(String ticketId) async {
    return _tickets.cast<Ticket?>().firstWhere(
          (t) => t?.id == ticketId,
          orElse: () => null,
        );
  }

  int getPurchasedCount(String eventId) {
    final initial = _initialTierStock[eventId]?.values.fold<int>(0, (a, b) => a + b) ?? 0;
    final current = _events.firstWhere((e) => e.id == eventId).availableTickets;
    return initial - current;
  }

  void _seedEvents() {
    if (_events.isNotEmpty) return;
    final now = DateTime.now();
    final rng = Random(42);
    final mockData = [
      {
        'id': 'evt-moise',
        'title': 'Soirée Adoration Live',
        'artist': 'Moïse Mbiye',
        'description': 'Adoration et louange avec l\'Apôtre Moïse Mbiye et son orchestre.',
        'date': now.add(const Duration(days: 10)),
        'location': 'Stade des Martyrs, Kinshasa',
        'image': '',
        'rating': 4.9,
        'genre': 'Worship',
        'tiers': {
          'VVIP': {'price': 180.0, 'stock': 80},
          'VIP': {'price': 120.0, 'stock': 180},
          'Normal': {'price': 60.0, 'stock': 400},
        },
      },
      {
        'id': 'evt-dena',
        'title': 'Worship Night',
        'artist': 'Dena Mwana',
        'description': 'Grande nuit de louange avec Dena Mwana et invités.',
        'date': now.add(const Duration(days: 18)),
        'location': 'Pullman Grand Hôtel, Kinshasa',
        'image': 'assets/images/soirée worship 1.jpg',
        'images': [
          'assets/images/soirée worship 1.jpg',
          'assets/images/soirée worship 2.jpg',
          'assets/images/soirée worship 3.jpg',
          'assets/images/soirée worship 4.jpg',
        ],
        'rating': 4.8,
        'genre': 'Gospel',
        'tiers': {
          'VVIP': {'price': 200.0, 'stock': 60},
          'VIP': {'price': 130.0, 'stock': 150},
          'Normal': {'price': 70.0, 'stock': 320},
        },
      },
      {
        'id': 'evt-athoms',
        'title': 'Soirée Worship Intimiste',
        'artist': 'Athoms Mbuma',
        'description': 'Louange et adoration avec Athoms & Nadège, ambiance acoustique.',
        'date': now.add(const Duration(days: 30)),
        'location': 'Philadelphie, Kisangani',
        'image': '',
        'rating': 4.7,
        'genre': 'Adoration',
        'tiers': {
          'VVIP': {'price': 140.0, 'stock': 50},
          'VIP': {'price': 95.0, 'stock': 150},
          'Normal': {'price': 50.0, 'stock': 260},
        },
      },
      {
        'id': 'evt-fally',
        'title': 'Tokoos Live',
        'artist': 'Fally Ipupa',
        'description': 'Afro-urban show avec orchestre complet et danseurs.',
        'date': now.add(const Duration(days: 22)),
        'location': 'Arena de Gombe, Kinshasa',
        'image': 'assets/images/fallyabercy_0.jpg',
        'images': [
          'assets/images/fallyabercy_0.jpg',
          'assets/images/fally concert.jpg',
          'assets/images/Fally_Ipupa_SdF.jpg.webp',
          'assets/images/fally6.webp',
        ],
        'rating': 4.8,
        'genre': 'Afro',
        'tiers': {
          'VVIP': {'price': 220.0, 'stock': 90},
          'VIP': {'price': 150.0, 'stock': 200},
          'Normal': {'price': 80.0, 'stock': 420},
        },
      },
      {
        'id': 'evt-koffi',
        'title': 'Légende Viva La Musica',
        'artist': 'Koffi Olomidé',
        'description': 'Rumba night avec Koffi et Quartier Latin.',
        'date': now.add(const Duration(days: 35)),
        'location': 'Stade Père Raphaël, Kinshasa',
        'image': '',
        'rating': 4.6,
        'genre': 'Rumba',
        'tiers': {
          'VVIP': {'price': 210.0, 'stock': 70},
          'VIP': {'price': 140.0, 'stock': 190},
          'Normal': {'price': 65.0, 'stock': 380},
        },
      },
      {
        'id': 'evt-ferre',
        'title': 'Harmonie Rumba',
        'artist': 'Ferré Gola',
        'description': 'Soirée rumba chic avec l\'artiste Jésus de nuances.',
        'date': now.add(const Duration(days: 27)),
        'location': 'Pullman Grand Hôtel, Kinshasa',
        'image': '',
        'rating': 4.7,
        'genre': 'Rumba',
        'tiers': {
          'VVIP': {'price': 180.0, 'stock': 60},
          'VIP': {'price': 120.0, 'stock': 160},
          'Normal': {'price': 70.0, 'stock': 340},
        },
      },
      {
        'id': 'evt-niska',
        'title': 'Concert R.A.P.',
        'artist': 'Niska',
        'description': 'Show rap/afrotrap avec live band et guests.',
        'date': now.add(const Duration(days: 40)),
        'location': 'Palais du Peuple, Kinshasa',
        'image': 'assets/images/CONCERT RAP NISKA 1.jpg',
        'images': [
          'assets/images/CONCERT RAP NISKA 1.jpg',
          'assets/images/CONERT RAP NISKA 2.png',
          'assets/images/CONCERT RAP NISKA 3.webp',
          'assets/images/CONCERT RAP NISKA 4.jpg',
        ],
        'rating': 4.5,
        'genre': 'Rap',
        'tiers': {
          'VVIP': {'price': 160.0, 'stock': 70},
          'VIP': {'price': 110.0, 'stock': 170},
          'Normal': {'price': 60.0, 'stock': 360},
        },
      },
    ];

    for (final raw in mockData) {
      final tiers = Map<String, dynamic>.from(raw['tiers'] as Map);
      final tierAvailability = <String, int>{};
      final tierPrices = <String, double>{};
      tiers.forEach((key, value) {
        tierAvailability[key] = value['stock'] as int;
        tierPrices[key] = (value['price'] as num).toDouble();
      });

      // light randomization to vary availability demo
      final noise = rng.nextInt(30) - 10;
      final tierAvailabilityNoisy = tierAvailability.map(
        (k, v) => MapEntry(k, (v + noise).clamp(30, 500)),
      );

      final totalTickets = tierAvailabilityNoisy.values.fold<int>(0, (a, b) => a + b);
      _initialTierStock[raw['id'] as String] = Map<String, int>.from(tierAvailabilityNoisy);

      _events.add(
        Event(
          id: raw['id'] as String,
          title: raw['title'] as String,
          artist: raw['artist'] as String,
          description: raw['description'] as String,
          date: raw['date'] as DateTime,
          location: raw['location'] as String,
          price: tierPrices.entries.first.value,
          imageUrl: raw['image'] as String,
          images: raw['images'] != null ? List<String>.from(raw['images'] as List) : [],
          availableTickets: totalTickets,
          rating: raw['rating'] as double,
          genre: raw['genre'] as String,
          tierAvailability: tierAvailabilityNoisy,
          tierPrices: tierPrices,
          initialTickets: totalTickets,
        ),
      );
    }
  }
}
