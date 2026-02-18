import 'package:flutter/material.dart';
import '../models/ticket.dart';
import '../services/firestore_service.dart';

class TicketController extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();
  List<Ticket> _tickets = [];
  bool _isLoading = false;

  List<Ticket> get tickets => _tickets;
  bool get isLoading => _isLoading;

  void loadUserTickets(String userId) {
    _isLoading = true;
    notifyListeners();

    _tickets = _firestoreService.getUserTickets(userId);
    _isLoading = false;
    notifyListeners();
  }

  Future<void> purchaseTicket(Ticket ticket) async {
    await _firestoreService.purchaseTicket(ticket);
    _tickets = _firestoreService.getUserTickets(ticket.userId);
    notifyListeners();
  }

  Future<void> scanTicket(String ticketId) async {
    await _firestoreService.scanTicket(ticketId);
    if (_tickets.isNotEmpty) {
      _tickets = _firestoreService.getUserTickets(_tickets.first.userId);
    }
    notifyListeners();
  }

  Future<Ticket?> getTicketById(String ticketId) async {
    return await _firestoreService.getTicketById(ticketId);
  }
}
