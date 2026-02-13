import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/auth_controller.dart';
import '../controllers/event_controller.dart';
import '../controllers/ticket_controller.dart';
import '../models/artist_track.dart';
import '../models/event.dart';
import '../models/ticket.dart';
import '../theme/app_theme.dart';
import 'widgets/aurora_background.dart';

class EventDetailScreen extends StatefulWidget {
  final Event event;

  const EventDetailScreen({super.key, required this.event});

  @override
  State<EventDetailScreen> createState() => _EventDetailScreenState();
}

class _EventDetailScreenState extends State<EventDetailScreen> {
  late final Future<List<ArtistTrack>> _tracksFuture;

  @override
  void initState() {
    super.initState();
    _tracksFuture = context.read<EventController>().loadArtistTracks(
          widget.event.artist,
        );
  }

  Future<void> _purchaseTicket() async {
    final auth = context.read<AuthController>();
    final ticketController = context.read<TicketController>();
    if (auth.user == null) return;

    final ticket = Ticket(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: auth.user!.id,
      eventId: widget.event.id,
      eventTitle: widget.event.title,
      eventArtist: widget.event.artist,
      eventDate: widget.event.date,
      eventLocation: widget.event.location,
      price: widget.event.price,
      purchaseDate: DateTime.now(),
    );

    await ticketController.purchaseTicket(ticket);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Billet achete avec succes.')),
    );
    Navigator.pop(context);
  }

  String _dateLabel(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year} a '
        '${date.hour.toString().padLeft(2, '0')}:'
        '${date.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final event = widget.event;
    return Scaffold(
      appBar: AppBar(title: const Text('Detail evenement')),
      body: AuroraBackground(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(22),
                child: Image.network(
                  event.imageUrl,
                  height: 270,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    height: 270,
                    color: AppColors.surface,
                    alignment: Alignment.center,
                    child: const Icon(Icons.music_note, size: 68),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: AppColors.surface.withValues(alpha: 0.86),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.1),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(event.title, style: Theme.of(context).textTheme.headlineSmall),
                    const SizedBox(height: 4),
                    Text(
                      event.artist,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.accentAlt,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _MetaRow(icon: Icons.location_on_outlined, text: event.location),
                    const SizedBox(height: 8),
                    _MetaRow(icon: Icons.calendar_today_outlined, text: _dateLabel(event.date)),
                    const SizedBox(height: 8),
                    _MetaRow(
                      icon: Icons.confirmation_number_outlined,
                      text: '${event.availableTickets} billets disponibles',
                    ),
                    const SizedBox(height: 16),
                    Text(
                      event.description,
                      style: TextStyle(color: Colors.white.withValues(alpha: 0.78)),
                    ),
                    const SizedBox(height: 18),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '\$${event.price.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                            color: AppColors.accent,
                          ),
                        ),
                        SizedBox(
                          width: 176,
                          child: ElevatedButton(
                            onPressed: event.availableTickets > 0 ? _purchaseTicket : null,
                            child: const Text('Acheter'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: AppColors.surfaceSoft.withValues(alpha: 0.84),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Top titres artiste (API externe iTunes)',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 12),
                    FutureBuilder<List<ArtistTrack>>(
                      future: _tracksFuture,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState != ConnectionState.done) {
                          return const Padding(
                            padding: EdgeInsets.symmetric(vertical: 12),
                            child: Center(child: CircularProgressIndicator()),
                          );
                        }
                        if (snapshot.hasError) {
                          return Text(
                            'Impossible de charger les titres pour le moment.',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.72),
                            ),
                          );
                        }

                        final tracks = snapshot.data ?? const [];
                        if (tracks.isEmpty) {
                          return Text(
                            'Aucune recommandation disponible.',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.72),
                            ),
                          );
                        }

                        return Column(
                          children: tracks
                              .take(5)
                              .map(
                                (track) => ListTile(
                                  contentPadding: EdgeInsets.zero,
                                  leading: ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: track.artworkUrl.isEmpty
                                        ? Container(
                                            width: 44,
                                            height: 44,
                                            color: Colors.white12,
                                            child: const Icon(Icons.music_note),
                                          )
                                        : Image.network(
                                            track.artworkUrl,
                                            width: 44,
                                            height: 44,
                                            fit: BoxFit.cover,
                                          ),
                                  ),
                                  title: Text(
                                    track.trackName,
                                    style: const TextStyle(fontWeight: FontWeight.w600),
                                  ),
                                  subtitle: Text(
                                    track.albumName,
                                    style: TextStyle(
                                      color: Colors.white.withValues(alpha: 0.7),
                                    ),
                                  ),
                                  trailing: track.previewUrl == null
                                      ? null
                                      : const Icon(
                                          Icons.play_circle_outline,
                                          color: AppColors.accentAlt,
                                        ),
                                ),
                              )
                              .toList(),
                        );
                      },
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

class _MetaRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const _MetaRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.white.withValues(alpha: 0.8)),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: TextStyle(color: Colors.white.withValues(alpha: 0.78)),
          ),
        ),
      ],
    );
  }
}
