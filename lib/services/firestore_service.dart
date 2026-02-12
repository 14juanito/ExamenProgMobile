import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/event.dart';
import '../models/ticket.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<Event>> getEvents() {
    return _firestore.collection('events').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return Event.fromJson(data);
      }).toList();
    });
  }

  Future<void> purchaseTicket(Ticket ticket) async {
    await _firestore.collection('tickets').doc(ticket.id).set(ticket.toJson());
    
    final eventRef = _firestore.collection('events').doc(ticket.eventId);
    await _firestore.runTransaction((transaction) async {
      final eventDoc = await transaction.get(eventRef);
      final currentTickets = eventDoc.data()?['availableTickets'] ?? 0;
      transaction.update(eventRef, {'availableTickets': currentTickets - 1});
    });
  }

  Stream<List<Ticket>> getUserTickets(String userId) {
    return _firestore
        .collection('tickets')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return Ticket.fromJson(data);
      }).toList();
    });
  }

  Future<void> scanTicket(String ticketId) async {
    await _firestore.collection('tickets').doc(ticketId).update({
      'isScanned': true,
    });
  }

  Future<Ticket?> getTicketById(String ticketId) async {
    final doc = await _firestore.collection('tickets').doc(ticketId).get();
    if (doc.exists) {
      final data = doc.data()!;
      data['id'] = doc.id;
      return Ticket.fromJson(data);
    }
    return null;
  }
}
