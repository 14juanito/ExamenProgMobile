import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/auth_controller.dart';
import '../controllers/ticket_controller.dart';
import '../models/ticket.dart';
import '../theme/app_theme.dart';
import 'ticket_detail_screen.dart';

class MyTicketsScreen extends StatefulWidget {
  const MyTicketsScreen({super.key});

  @override
  State<MyTicketsScreen> createState() => _MyTicketsScreenState();
}

class _MyTicketsScreenState extends State<MyTicketsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userId = context.read<AuthController>().user?.id;
      if (userId != null) {
        context.read<TicketController>().loadUserTickets(userId);
      }
    });
  }

  String _dateLabel(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mes billets')),
      body: Consumer<TicketController>(
        builder: (context, ticketController, _) {
          if (ticketController.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (ticketController.tickets.isEmpty) {
            return Center(
              child: Container(
                margin: const EdgeInsets.all(24),
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.surface.withOpacity(0.94),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.06),
                      blurRadius: 12,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: const Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.confirmation_num_outlined, size: 44),
                    SizedBox(height: 10),
                    Text('Aucun billet achete pour le moment.'),
                  ],
                ),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            itemCount: ticketController.tickets.length,
            itemBuilder: (context, index) {
              final ticket = ticketController.tickets[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _TicketCard(
                  ticket: ticket,
                  dateLabel: _dateLabel(ticket.eventDate),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _TicketCard extends StatelessWidget {
  final Ticket ticket;
  final String dateLabel;

  const _TicketCard({required this.ticket, required this.dateLabel});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => TicketDetailScreen(ticket: ticket),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      ticket.eventTitle,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: ticket.isScanned ? AppColors.success : AppColors.warning,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      ticket.isScanned ? 'Utilise' : 'Valide',
                      style: const TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                ticket.eventArtist,
                style: const TextStyle(
                  color: AppColors.accentAlt,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 10),
              _line(Icons.location_on_outlined, ticket.eventLocation),
              const SizedBox(height: 6),
              _line(Icons.calendar_today_outlined, dateLabel),
              const SizedBox(height: 10),
              _line(Icons.event_seat_outlined, 'Catégorie : ${ticket.seatCategory} x${ticket.quantity}'),
              const SizedBox(height: 10),
              Text(
                '\$${ticket.price.toStringAsFixed(2)}',
                style: const TextStyle(
                  color: AppColors.accent,
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _line(IconData icon, String value) {
    return Row(
      children: [
        Icon(icon, size: 15, color: Colors.black.withOpacity(0.8)),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            value,
            style: TextStyle(color: Colors.black.withOpacity(0.78)),
          ),
        ),
      ],
    );
  }
}
