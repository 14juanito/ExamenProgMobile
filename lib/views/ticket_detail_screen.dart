import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../models/ticket.dart';
import 'qr_scanner_screen.dart';

class TicketDetailScreen extends StatelessWidget {
  final Ticket ticket;

  const TicketDetailScreen({super.key, required this.ticket});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Détails du Billet'),
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
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    QrImageView(
                      data: ticket.id,
                      version: QrVersions.auto,
                      size: 250,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'ID: ${ticket.id}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFF0f3460),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Statut',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white70,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: ticket.isScanned ? Colors.green : Colors.orange,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            ticket.isScanned ? 'Scanné' : 'Valide',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 32, color: Colors.white30),
                    Text(
                      ticket.eventTitle,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      ticket.eventArtist,
                      style: const TextStyle(
                        fontSize: 18,
                        color: Colors.blue,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildInfoRow(
                      Icons.location_on,
                      'Lieu',
                      ticket.eventLocation,
                    ),
                    const SizedBox(height: 12),
                    _buildInfoRow(
                      Icons.calendar_today,
                      'Date',
                      '${ticket.eventDate.day}/${ticket.eventDate.month}/${ticket.eventDate.year} à ${ticket.eventDate.hour}:${ticket.eventDate.minute.toString().padLeft(2, '0')}',
                    ),
                    const SizedBox(height: 12),
                    _buildInfoRow(
                      Icons.attach_money,
                      'Prix',
                      '\$${ticket.price.toStringAsFixed(2)}',
                    ),
                    const SizedBox(height: 12),
                    _buildInfoRow(
                      Icons.shopping_cart,
                      'Acheté le',
                      '${ticket.purchaseDate.day}/${ticket.purchaseDate.month}/${ticket.purchaseDate.year}',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Présentez ce QR code à l\'entrée',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white70,
                  fontStyle: FontStyle.italic,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const QRScannerScreen()),
          );
        },
        backgroundColor: Colors.blue,
        icon: const Icon(Icons.qr_code_scanner),
        label: const Text('Scanner un billet'),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.white70),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: const TextStyle(
            fontSize: 14,
            color: Colors.white70,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}
