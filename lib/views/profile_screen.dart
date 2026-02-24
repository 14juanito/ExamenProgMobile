import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/auth_controller.dart';
import '../controllers/ticket_controller.dart';
import '../models/user.dart';
import '../theme/app_theme.dart';
import 'my_tickets_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
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

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthController>();
    final ticketController = context.watch<TicketController>();
    final user = auth.user;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
          children: [
            _ProfileHeader(user: user, activeTickets: ticketController.tickets.length),
            const SizedBox(height: 18),
            _SectionCard(
              title: 'Mon compte',
              actions: [
                _SectionAction(
                  icon: Icons.person_outline,
                  label: 'Informations personnelles',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => PersonalInfoScreen(user: user)),
                  ),
                ),
                _SectionAction(
                  icon: Icons.credit_card,
                  label: 'Paramètres de paiement',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const PaymentSettingsScreen()),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            _SectionCard(
              title: 'Mes billets',
              chip: '${ticketController.tickets.length} actifs',
              actions: [
                _SectionAction(
                  icon: Icons.confirmation_num_outlined,
                  label: 'Billets à venir',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const MyTicketsScreen()),
                  ),
                ),
                _SectionAction(
                  icon: Icons.history,
                  label: 'Historique des commandes',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const MyTicketsScreen()),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            _SectionCard(
              title: 'Assistance & Infos',
              actions: [
                _SectionAction(
                  icon: Icons.help_outline,
                  label: 'FAQ / Support',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const SupportScreen()),
                  ),
                ),
                _SectionAction(
                  icon: Icons.description_outlined,
                  label: 'Conditions générales',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const LegalScreen()),
                  ),
                ),
                _SectionAction(
                  icon: Icons.logout,
                  label: 'Se déconnecter',
                  iconColor: AppColors.danger,
                  onTap: () async {
                    await context.read<AuthController>().signOut();
                    if (!mounted) return;
                    Navigator.of(context).popUntil((route) => route.isFirst);
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  final User? user;
  final int activeTickets;

  const _ProfileHeader({required this.user, required this.activeTickets});

  @override
  Widget build(BuildContext context) {
    final initials = (user?.name.isNotEmpty ?? false)
        ? user!.name.trim().split(' ').take(2).map((p) => p[0]).join().toUpperCase()
        : '??';

    return Container(
      height: 240,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26),
        image: const DecorationImage(
          image: NetworkImage(
            'https://images.unsplash.com/photo-1517245386807-bb43f82c33c4?auto=format&fit=crop&w=1400&q=80',
          ),
          fit: BoxFit.cover,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 22,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.black.withOpacity(0.05), Colors.black.withOpacity(0.65)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Align(
                  alignment: Alignment.topRight,
                  child: IconButton(
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.white.withOpacity(0.16),
                      foregroundColor: Colors.white,
                    ),
                    onPressed: () {},
                    icon: const Icon(Icons.settings_outlined),
                  ),
                ),
                const Spacer(),
                Row(
                  children: [
                    CircleAvatar(
                      radius: 38,
                      backgroundColor: Colors.white,
                      backgroundImage:
                          user?.photoUrl != null ? NetworkImage(user!.photoUrl!) : null,
                      child: user?.photoUrl == null
                          ? Text(
                              initials,
                              style: const TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.w800,
                                fontSize: 20,
                              ),
                            )
                          : null,
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user?.name ?? 'Utilisateur connecté',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w800,
                                ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            user?.email ?? 'email non renseigné',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.86),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            children: [
                              _pill(
                                icon: Icons.confirmation_num_outlined,
                                label: '$activeTickets billet(s)',
                              ),
                              _pill(
                                icon: Icons.shield_outlined,
                                label: 'Paiements sécurisés',
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _pill({required IconData icon, required String label}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.18),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Colors.white),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final String? chip;
  final List<_SectionAction> actions;

  const _SectionCard({
    required this.title,
    required this.actions,
    this.chip,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 4),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: Colors.black87,
                        ),
                  ),
                ),
                if (chip != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      chip!,
                      style: TextStyle(
                        color: Colors.black.withOpacity(0.7),
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          ...actions.map((a) => a.build(context)).toList(),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

class _SectionAction {
  final IconData icon;
  final Color? iconColor;
  final String label;
  final VoidCallback onTap;

  const _SectionAction({
    required this.icon,
    required this.label,
    required this.onTap,
    this.iconColor,
  });

  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                icon,
                color: iconColor ?? Colors.black.withOpacity(0.8),
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  color: Colors.black.withOpacity(0.9),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            Icon(Icons.arrow_forward_ios_rounded, size: 16, color: Colors.black.withOpacity(0.35)),
          ],
        ),
      ),
    );
  }
}

class PersonalInfoScreen extends StatelessWidget {
  final User? user;

  const PersonalInfoScreen({super.key, this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Informations personnelles')),
      backgroundColor: AppColors.background,
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _infoTile(
              context,
              icon: Icons.badge_outlined,
              label: 'Nom complet',
              value: user?.name ?? 'Non renseigné',
            ),
            _infoTile(
              context,
              icon: Icons.mail_outline,
              label: 'Email',
              value: user?.email ?? 'Non renseigné',
            ),
            _infoTile(
              context,
              icon: Icons.tag_outlined,
              label: 'ID utilisateur',
              value: user?.id ?? 'Non renseigné',
            ),
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 14,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, color: Colors.black54),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Ces informations proviennent de votre session actuelle.',
                      style: TextStyle(color: Colors.black.withOpacity(0.7)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoTile(BuildContext context,
      {required IconData icon, required String label, required String value}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 14,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: Colors.black87),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(color: Colors.black.withOpacity(0.7)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class PaymentSettingsScreen extends StatelessWidget {
  const PaymentSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Paramètres de paiement')),
      backgroundColor: AppColors.background,
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _paymentCard(
            context,
            title: 'Carte principale',
            masked: '**** **** **** 5124',
            network: 'VISA',
            trailing: 'Défaut',
          ),
          _paymentCard(
            context,
            title: 'Mobile Money',
            masked: '+243 •••• ••24',
            network: 'Airtel',
            trailing: 'Actif',
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.add),
            label: const Text('Ajouter un moyen de paiement'),
          ),
        ],
      ),
    );
  }

  Widget _paymentCard(
    BuildContext context, {
    required String title,
    required String masked,
    required String network,
    required String trailing,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.credit_card, color: Colors.black87),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      color: Colors.black87,
                    )),
                const SizedBox(height: 4),
                Text('$masked · $network',
                    style: TextStyle(color: Colors.black.withOpacity(0.7))),
              ],
            ),
          ),
          Text(
            trailing,
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              color: AppColors.accent,
            ),
          ),
        ],
      ),
    );
  }
}

class SupportScreen extends StatelessWidget {
  const SupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('FAQ / Support')),
      backgroundColor: AppColors.background,
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _faq(
            'Comment accéder à mes billets ?',
            'Vos billets achetés apparaissent dans l’onglet “Billets à venir” et restent disponibles hors-ligne.',
          ),
          _faq(
            'Puis-je transférer un billet ?',
            'Le transfert n’est pas encore activé. Vous pouvez toutefois présenter le QR code sur place.',
          ),
          _faq(
            'Modes de paiement acceptés',
            'Cartes Visa/Mastercard, Mobile Money (Airtel, M-Pesa) et paiements cash chez nos partenaires.',
          ),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.chat_bubble_outline),
            label: const Text('Contacter le support'),
          ),
        ],
      ),
    );
  }

  Widget _faq(String title, String body) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 14,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.w800,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            body,
            style: TextStyle(color: Colors.black.withOpacity(0.72)),
          ),
        ],
      ),
    );
  }
}

class LegalScreen extends StatelessWidget {
  const LegalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Conditions générales')),
      backgroundColor: AppColors.background,
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 14,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: const Text(
            'En utilisant e-ticket, vous acceptez nos conditions de vente, la politique de remboursement des organisateurs '
            'et le traitement sécurisé de vos données. Les billets sont nominatifs et contrôlés à l’entrée via QR code.',
            style: TextStyle(height: 1.35),
          ),
        ),
      ),
    );
  }
}
