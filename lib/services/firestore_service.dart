import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/event.dart';
import '../models/ticket.dart';

/// Service Cloud Firestore pour la gestion des événements et billets
class FirestoreService {
  // Collections Firestore
  final CollectionReference eventsCollection = FirebaseFirestore.instance.collection('events');
  final CollectionReference ticketsCollection = FirebaseFirestore.instance.collection('tickets');

  FirestoreService._internal();

  static final FirestoreService _instance = FirestoreService._internal();
  factory FirestoreService() => _instance;

  // ============ ÉVÉNEMENTS ============
  
  // Lire tous les événements
  Future<List<Event>> getEvents() async {
    try {
      final snapshot = await eventsCollection.get();
      return snapshot.docs.map((doc) => Event.fromJson(doc.data() as Map<String, dynamic>)).toList();
    } catch (e) {
      // En cas d'erreur, retourner des données de démonstration
      return _getDemoEvents();
    }
  }

  // Ajouter un événement
  Future<void> addEvent(Event event) async {
    await eventsCollection.doc(event.id).set(event.toJson());
  }

  // Modifier un événement
  Future<void> updateEvent(Event event) async {
    await eventsCollection.doc(event.id).update(event.toJson());
  }

  // Supprimer un événement
  Future<void> deleteEvent(String eventId) async {
    await eventsCollection.doc(eventId).delete();
  }

  // ============ BILLETS ============
  
  // Lire les billets d'un utilisateur
  Future<List<Ticket>> getUserTickets(String userId) async {
    final snapshot = await ticketsCollection
        .where('userId', isEqualTo: userId)
        .get();
    return snapshot.docs.map((doc) => Ticket.fromJson(doc.data() as Map<String, dynamic>)).toList();
  }

  // Acheter un billet
  Future<void> purchaseTicket(Ticket ticket) async {
    await ticketsCollection.doc(ticket.id).set(ticket.toJson());
    
    // Mettre à jour la disponibilité des billets
    final eventDoc = eventsCollection.doc(ticket.eventId);
    final eventSnapshot = await eventDoc.get();
    if (eventSnapshot.exists) {
      final eventData = eventSnapshot.data() as Map<String, dynamic>;
      final tierAvailability = Map<String, int>.from(eventData['tierAvailability'] ?? {});
      final category = ticket.seatCategory;
      if (tierAvailability.containsKey(category)) {
        tierAvailability[category] = tierAvailability[category]! - ticket.quantity;
        await eventDoc.update({'tierAvailability': tierAvailability});
      }
    }
  }

  // Scanner un billet
  Future<void> scanTicket(String ticketId) async {
    await ticketsCollection.doc(ticketId).update({'isScanned': true});
  }

  // Obtenir un billet par ID
  Future<Ticket?> getTicketById(String ticketId) async {
    final doc = await ticketsCollection.doc(ticketId).get();
    if (!doc.exists) return null;
    return Ticket.fromJson(doc.data() as Map<String, dynamic>);
  }

  // ============ DONNÉES DE DÉMONSTRATION ============
  
  List<Event> _getDemoEvents() {
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
    ];

    return mockData.map((raw) {
      final tiers = Map<String, dynamic>.from(raw['tiers'] as Map);
      final tierAvailability = <String, int>{};
      final tierPrices = <String, double>{};
      tiers.forEach((key, value) {
        tierAvailability[key] = value['stock'] as int;
        tierPrices[key] = (value['price'] as num).toDouble();
      });

      final noise = rng.nextInt(30) - 10;
      final tierAvailabilityNoisy = tierAvailability.map(
        (k, v) => MapEntry(k, (v + noise).clamp(30, 500)),
      );

      final totalTickets = tierAvailabilityNoisy.values.fold<int>(0, (a, b) => a + b);

      return Event(
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
      );
    }).toList();
  }
}
