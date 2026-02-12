import 'package:flutter/material.dart';
import '../models/event.dart';
import '../services/firestore_service.dart';

class EventController extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();
  List<Event> _events = [];
  bool _isLoading = false;

  List<Event> get events => _events;
  bool get isLoading => _isLoading;

  void loadEvents() {
    _isLoading = true;
    notifyListeners();

    _firestoreService.getEvents().listen((events) {
      _events = events;
      _isLoading = false;
      notifyListeners();
    });
  }
}
