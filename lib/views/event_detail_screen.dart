import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/event.dart';
import '../models/ticket.dart';
import '../controllers/auth_controller.dart';
import '../controllers/ticket_controller.dart';

class EventDetailScreen extends StatelessWidget {
  final Event event;

  const EventDetailScreen({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Détails de l\'événement'),
        backgroundColor: const Color(0xFF1a1a2e),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF1a1a2e), Color(0xFF16213e)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Image.network(
                event.imageUrl,
                height: 300,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  height: 300,
                  color: Colors.grey[800],
                  child: const Icon(Icons.music_note, size: 100),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      event.title,
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      event.artist,
                      style: const TextStyle(fontSize: 20, color: Colors.blue),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        const Icon(Icons.location_on, color: Colors.white70),
                        const SizedBox(width: 8),
                        Text(
                          event.location,
                          style: const TextStyle(fontSize: 16, color: Colors.white70),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Icon(Icons.calendar_today, color: Colors.white70),
                        const SizedBox(width: 8),
                        Text(
                          '${event.date.day}/${event.date.month}/${event.date.year} à ${event.date.hour}:${event.date.minute.toString().padLeft(2, '0')}',
                          style: const TextStyle(fontSize: 16, color: Colors.white70),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Description',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      event.description,
                      style: const TextStyle(fontSize: 16, color: Colors.white70),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '\$${event.price.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                        Text(
                          '${event.availableTickets} billets disponibles',
                          style: const TextStyle(fontSize: 16, color: Colors.white70),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: event.availableTickets > 0
                            ? () async {
                                final auth = context.read<AuthController>();
                                final ticketController = context.read<TicketController>();
                                
                                final ticket = Ticket(
                                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                                  userId: auth.user!.id,
                                  eventId: event.id,
                                  eventTitle: event.title,
                                  eventArtist: event.artist,
                                  eventDate: event.date,
                                  eventLocation: event.location,
                                  price: event.price,
                                  purchaseDate: DateTime.now(),
                                );

                                await ticketController.purchaseTicket(ticket);
                                
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Billet acheté avec succès!'),
                                      backgroundColor: Colors.green,
                                    ),
                                  );
                                  Navigator.pop(context);
                                }
                              }
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Acheter le billet',
                          style: TextStyle(fontSize: 18),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
