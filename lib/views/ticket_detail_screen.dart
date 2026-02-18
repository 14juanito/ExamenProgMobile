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
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text('Détails du billet'),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const QRScannerScreen()),
          );
        },
        backgroundColor: Colors.black,
        icon: const Icon(Icons.qr_code_scanner),
        label: const Text('Scanner un billet'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Card(
              elevation: 8,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    QrImageView(
                      data: ticket.id,
                      version: QrVersions.auto,
                      size: 220,
                    ),
                    const SizedBox(height: 12),
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
            ),
            const SizedBox(height: 16),
            Card(
              elevation: 8,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Statut',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
                    const SizedBox(height: 14),
                    Text(
                      ticket.eventTitle,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      ticket.eventArtist,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.black54,
                        fontWeight: FontWeight.w600,
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
                    const SizedBox(height: 12),
                    _buildInfoRow(
                      Icons.event_seat,
                      'Catégorie',
                      '${ticket.seatCategory} x${ticket.quantity}',
                    ),
                    const SizedBox(height: 12),
                    _buildInfoRow(
                      Icons.phone_iphone,
                      'Mobile Money',
                      '${ticket.paymentOperator} • ${ticket.payerPhone.isEmpty ? 'Non fourni' : ticket.payerPhone}',
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 14),
            const Text(
              'Présentez ce QR code à l\'entrée.',
              style: TextStyle(
                fontSize: 14,
                color: Colors.black54,
                fontStyle: FontStyle.italic,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.black87),
        const SizedBox(width: 8),
        Text(
          '$label : ',
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontSize: 14, color: Colors.black87),
          ),
        ),
      ],
    );
  }
}
