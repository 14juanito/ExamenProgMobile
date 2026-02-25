import 'dart:math';

/// Service de simulation de paiement Mobile Money (M-Pesa, Airtel Money, Orange Money)
class PaymentService {
  // Token de labyrinthe fourni
  static const String _labyrinthToken = r'$2y$12$3mB3Y0IY3tOJcpaecIrG1ul8GlsdrV78Fz9ty7.BcvBx5fT2bmvCK';

  /// Simule un paiement Mobile Money
  /// Retourne un objet PaymentResult contenant le statut et les détails
  static Future<PaymentResult> processPayment({
    required String operator,
    required String phoneNumber,
    required double amount,
    required String eventTitle,
  }) async {
    // Simuler un délai réseau (1-3 secondes)
    await Future.delayed(Duration(milliseconds: 1500 + Random().nextInt(1500)));

    // Vérifier si le token est valide (simulation)
    final isTokenValid = _validateToken(_labyrinthToken);

    if (!isTokenValid) {
      return PaymentResult(
        success: false,
        message: 'Token de validation invalide',
        transactionId: null,
        operator: operator,
      );
    }

    // Validation du numéro de téléphone
    if (phoneNumber.isEmpty || phoneNumber.length < 9) {
      return PaymentResult(
        success: false,
        message: 'Numéro de téléphone invalide',
        transactionId: null,
        operator: operator,
      );
    }

    // Vérification du montant minimum
    if (amount < 1.0) {
      return PaymentResult(
        success: false,
        message: 'Le montant doit être au moins de \$1',
        transactionId: null,
        operator: operator,
      );
    }

    // Générer un ID de transaction unique
    final transactionId = _generateTransactionId(operator);

    // Simulation: 90% de succès
    final isSuccess = Random().nextDouble() < 0.9;

    if (isSuccess) {
      String operatorName;
      switch (operator) {
        case 'M-Pesa':
          operatorName = 'M-Pesa (Vodacom)';
          break;
        case 'Airtel Money':
          operatorName = 'Airtel Money';
          break;
        case 'Orange Money':
          operatorName = 'Orange Money';
          break;
        default:
          operatorName = operator;
      }

      return PaymentResult(
        success: true,
        message: 'Paiement réussi via $operatorName',
        transactionId: transactionId,
        operator: operator,
        amount: amount,
        phoneNumber: phoneNumber,
        eventTitle: eventTitle,
      );
    } else {
      return PaymentResult(
        success: false,
        message: 'Échec du paiement. Veuillez réessayer.',
        transactionId: transactionId,
        operator: operator,
      );
    }
  }

  /// Valide le token de labyrinthe
  static bool _validateToken(String token) {
    // Simulation de validation de token
    // Le token fourni doit correspondre
    return token == _labyrinthToken;
  }

  /// Génère un ID de transaction unique
  static String _generateTransactionId(String operator) {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final prefix = operator.substring(0, min(3, operator.length)).toUpperCase();
    return '$prefix-$timestamp';
  }

  /// Retourne les opérateurs disponibles
  static List<String> get availableOperators => [
    'M-Pesa',
    'Airtel Money',
    'Orange Money',
  ];
}

/// Résultat d'un paiement
class PaymentResult {
  final bool success;
  final String message;
  final String? transactionId;
  final String operator;
  final double? amount;
  final String? phoneNumber;
  final String? eventTitle;

  PaymentResult({
    required this.success,
    required this.message,
    required this.transactionId,
    required this.operator,
    this.amount,
    this.phoneNumber,
    this.eventTitle,
  });

  /// Génère les données pour le QR code
  Map<String, dynamic> toQrData() {
    return {
      'transactionId': transactionId,
      'operator': operator,
      'amount': amount,
      'phoneNumber': phoneNumber,
      'eventTitle': eventTitle,
      'timestamp': DateTime.now().toIso8601String(),
      'status': success ? 'PAID' : 'FAILED',
    };
  }
}
