import 'package:flutter_test/flutter_test.dart';
import 'package:aigle_au_stade/models/event.dart';

void main() {
  test('Event serialization should parse and export expected values', () {
    final json = {
      'id': 'evt-1',
      'title': 'Concert Fally Ipupa',
      'artist': 'Fally Ipupa',
      'description': 'Concert test',
      'date': '2026-12-31T20:00:00.000Z',
      'location': 'Stade des Martyrs',
      'price': 50.0,
      'imageUrl': 'https://example.com/image.jpg',
      'availableTickets': 1000,
    };

    final event = Event.fromJson(json);
    final exported = event.toJson();

    expect(event.id, 'evt-1');
    expect(event.price, 50.0);
    expect(event.availableTickets, 1000);
    expect(exported['artist'], 'Fally Ipupa');
    expect(exported['location'], 'Stade des Martyrs');
  });
}
