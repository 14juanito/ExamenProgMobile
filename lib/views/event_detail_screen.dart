import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/auth_controller.dart';
import '../controllers/event_controller.dart';
import '../controllers/ticket_controller.dart';
import '../models/artist_track.dart';
import '../models/event.dart';
import '../models/ticket.dart';
import '../theme/app_theme.dart';

class EventDetailScreen extends StatefulWidget {
  final Event event;

  const EventDetailScreen({super.key, required this.event});

  @override
  State<EventDetailScreen> createState() => _EventDetailScreenState();
}

class _EventDetailScreenState extends State<EventDetailScreen> {
  late final Future<List<ArtistTrack>> _tracksFuture;
  late Event _event;
  late String _selectedTier;
  int _quantity = 1;
  final TextEditingController _phoneController = TextEditingController();
  String _operator = 'M-Pesa';

  @override
  void initState() {
    super.initState();
    _event = widget.event;
    _selectedTier = _event.tierAvailability.keys.isNotEmpty
        ? _event.tierAvailability.keys.first
        : 'Normal';
    _tracksFuture = context.read<EventController>().loadArtistTracks(_event.artist);
  }

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _purchaseTicket() async {
    final auth = context.read<AuthController>();
    final ticketController = context.read<TicketController>();
    if (auth.user == null) return;

    final remaining = _event.tierAvailability[_selectedTier] ?? 0;
    if (_quantity > remaining) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Stock insuffisant pour cette catégorie.')),
      );
      return;
    }

    final tierPrice = _event.tierPrices[_selectedTier] ?? _event.price;
    final ticket = Ticket(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: auth.user!.id,
      eventId: _event.id,
      eventTitle: _event.title,
      eventArtist: _event.artist,
      eventDate: _event.date,
      eventLocation: _event.location,
      price: tierPrice * _quantity,
      purchaseDate: DateTime.now(),
      seatCategory: _selectedTier,
      quantity: _quantity,
      paymentOperator: _operator,
      payerPhone: _phoneController.text.trim(),
    );

    await ticketController.purchaseTicket(ticket);
    // refresh events to reflect availability
    context.read<EventController>().loadEvents();
    final refreshed = context.read<EventController>().events.firstWhere(
          (e) => e.id == _event.id,
          orElse: () => _event,
        );
    setState(() => _event = refreshed);

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Billet achete avec succes.')),
    );
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
    final event = _event;
    final tiers = event.tierAvailability.keys.toList();
    final availableForTier = event.tierAvailability[_selectedTier] ?? 0;
    final purchased = event.initialTickets - event.availableTickets;
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Détails de l’événement'),
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: ElevatedButton(
          onPressed: event.availableTickets > 0 ? _purchaseTicket : null,
          child: const Text('Réserver maintenant'),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 90),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(28),
              child: Image.network(
                event.imageUrl,
                height: 260,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  height: 260,
                  color: Colors.black12,
                  alignment: Alignment.center,
                  child: const Icon(Icons.image_not_supported_outlined, size: 40),
                ),
              ),
            ),
            const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          event.title,
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.w800,
                                color: Colors.black87,
                              ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                        event.location,
                          style: TextStyle(color: Colors.black.withOpacity(0.6)),
                        ),
                      ],
                    ),
                  ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                      )
                    ],
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.star_rounded, color: Colors.amber, size: 20),
                      const SizedBox(width: 4),
                      Text(
                        event.rating.toStringAsFixed(1),
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              event.description,
              style: TextStyle(color: Colors.black.withOpacity(0.62)),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Text(
                  '\$${event.price.toStringAsFixed(0)}',
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(width: 10),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceSoft,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${event.availableTickets} billets',
                    style: TextStyle(color: Colors.black.withOpacity(0.7)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  )
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Type de billet',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: tiers
                        .map(
                          (tier) => ChoiceChip(
                            label: Text('$tier • \$${(event.tierPrices[tier] ?? event.price).toStringAsFixed(0)}'),
                            selected: _selectedTier == tier,
                            onSelected: (_) => setState(() => _selectedTier = tier),
                            selectedColor: Colors.black,
                            labelStyle: TextStyle(
                              color: _selectedTier == tier ? Colors.white : Colors.black87,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        )
                        .toList(),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Text('Quantité', style: TextStyle(fontWeight: FontWeight.w700)),
                      const SizedBox(width: 12),
                      IconButton(
                        onPressed: _quantity > 1 ? () => setState(() => _quantity--) : null,
                        icon: const Icon(Icons.remove_circle_outline),
                      ),
                      Text('$_quantity', style: const TextStyle(fontWeight: FontWeight.w800)),
                      IconButton(
                        onPressed: _quantity < 10 && _quantity < availableForTier
                            ? () => setState(() => _quantity++)
                            : null,
                        icon: const Icon(Icons.add_circle_outline),
                      ),
                      const Spacer(),
                      Text(
                        '$availableForTier restants',
                        style: TextStyle(color: Colors.black.withOpacity(0.6)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Total : \$${((_event.tierPrices[_selectedTier] ?? _event.price) * _quantity).toStringAsFixed(0)}',
                    style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
                  ),
                  const SizedBox(height: 14),
                  const Text('Paiement Mobile Money (RDC)',
                      style: TextStyle(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 10),
                  DropdownButtonFormField<String>(
                    value: _operator,
                    items: const [
                      DropdownMenuItem(value: 'M-Pesa', child: Text('M-Pesa (Vodacom)')),
                      DropdownMenuItem(value: 'Airtel Money', child: Text('Airtel Money')),
                      DropdownMenuItem(value: 'Orange Money', child: Text('Orange Money')),
                    ],
                    onChanged: (v) => setState(() => _operator = v ?? 'M-Pesa'),
                    decoration: const InputDecoration(
                      labelText: 'Opérateur',
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(
                      labelText: 'Numéro Mobile Money (+243...)',
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${event.availableTickets} billets restants',
                  style: TextStyle(color: Colors.black.withOpacity(0.65)),
                ),
                Text(
                  'Vendues: $purchased',
                  style: TextStyle(color: Colors.black.withOpacity(0.65)),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _PhotosRow(images: List.filled(4, event.imageUrl)),
            const SizedBox(height: 14),
            _InfoGrid(
              event: event,
              dateLabel: _dateLabel,
              seatSummary: event.tierAvailability.keys.join(', '),
            ),
            const SizedBox(height: 16),
            _OrganizerRow(),
            const SizedBox(height: 14),
            _ServiceIcons(),
            const SizedBox(height: 16),
            _MapCard(location: event.location),
            const SizedBox(height: 18),
            _ItunesTracks(tracksFuture: _tracksFuture),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}

class _PhotosRow extends StatelessWidget {
  final List<String> images;

  const _PhotosRow({required this.images});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              'Photos',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
            const SizedBox(width: 10),
            Icon(Icons.chevron_right, color: Colors.black.withOpacity(0.5)),
          ],
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 64,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: images.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, index) => ClipOval(
              child: Image.network(
                images[index],
                width: 64,
                height: 64,
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _InfoGrid extends StatelessWidget {
  final Event event;
  final String Function(DateTime) dateLabel;
  final String seatSummary;

  const _InfoGrid({required this.event, required this.dateLabel, required this.seatSummary});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 14,
            offset: const Offset(0, 8),
          )
        ],
      ),
      child: Wrap(
        alignment: WrapAlignment.spaceBetween,
        runSpacing: 14,
        children: [
          _InfoTile(icon: Icons.calendar_today_outlined, label: 'Date', value: dateLabel(event.date)),
          _InfoTile(icon: Icons.schedule_outlined, label: 'Heure', value: '${event.date.hour.toString().padLeft(2, '0')}:${event.date.minute.toString().padLeft(2, '0')}'),
          _InfoTile(icon: Icons.event_seat_outlined, label: 'Catégorie', value: seatSummary.isEmpty ? 'Normal' : seatSummary),
          _InfoTile(icon: Icons.security_outlined, label: 'Âge minimum', value: '12+'),
        ],
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoTile({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.42,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.surfaceSoft,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, size: 20, color: Colors.black87),
              ),
              const SizedBox(width: 10),
              Text(label, style: const TextStyle(fontWeight: FontWeight.w700)),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(color: Colors.black.withOpacity(0.6)),
          ),
        ],
      ),
    );
  }
}

class _OrganizerRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 6),
          )
        ],
      ),
      child: Row(
        children: [
          const CircleAvatar(
            backgroundColor: Colors.black,
            child: Text('LN', style: TextStyle(color: Colors.white)),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'Live Nation',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.call),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.message_outlined),
            onPressed: () {},
          ),
        ],
      ),
    );
  }
}

class _ServiceIcons extends StatelessWidget {
  final List<_ServiceItem> items = const [
    _ServiceItem(icon: Icons.local_parking_outlined, label: 'Parking'),
    _ServiceItem(icon: Icons.local_bar_outlined, label: 'Bar'),
    _ServiceItem(icon: Icons.accessible_forward_outlined, label: 'PMR Access'),
    _ServiceItem(icon: Icons.shopping_bag_outlined, label: 'Merch'),
  ];

  const _ServiceIcons();

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 14,
      runSpacing: 14,
      children: items
          .map(
            (item) => Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 6),
                  )
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(item.icon, color: Colors.black87),
                  const SizedBox(height: 6),
                  Text(
                    item.label,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 11),
                  ),
                ],
              ),
            ),
          )
          .toList(),
    );
  }
}

class _ServiceItem {
  final IconData icon;
  final String label;

  const _ServiceItem({required this.icon, required this.label});
}

class _MapCard extends StatelessWidget {
  final String location;

  const _MapCard({required this.location});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 8),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                const Text(
                  'Localisation',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
                const Spacer(),
                Icon(Icons.map_outlined, color: Colors.black.withOpacity(0.6)),
              ],
            ),
          ),
          ClipRRect(
            borderRadius: const BorderRadius.vertical(bottom: Radius.circular(18)),
            child: Image.network(
              'https://images.unsplash.com/photo-1505761671935-60b3a7427bad?auto=format&fit=crop&w=1200&q=80',
              height: 180,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Text(
              location,
              style: TextStyle(color: Colors.black.withOpacity(0.7)),
            ),
          ),
        ],
      ),
    );
  }
}

class _ItunesTracks extends StatelessWidget {
  final Future<List<ArtistTrack>> tracksFuture;

  const _ItunesTracks({required this.tracksFuture});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 8),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Titres iTunes',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
          FutureBuilder<List<ArtistTrack>>(
            future: tracksFuture,
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
                    color: Colors.black.withOpacity(0.6),
                  ),
                );
              }

              final tracks = snapshot.data ?? const [];
              if (tracks.isEmpty) {
                return Text(
                  'Aucune recommandation disponible.',
                  style: TextStyle(
                    color: Colors.black.withOpacity(0.6),
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
                                  color: Colors.black12,
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
                            color: Colors.black.withOpacity(0.65),
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
    );
  }
}
