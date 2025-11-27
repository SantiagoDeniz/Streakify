import 'package:flutter/material.dart';
import '../services/purchase_service.dart';
import '../config/product_ids.dart';

class DonationScreen extends StatefulWidget {
  const DonationScreen({super.key});

  @override
  State<DonationScreen> createState() => _DonationScreenState();
}

class _DonationScreenState extends State<DonationScreen> {
  final PurchaseService _purchaseService = PurchaseService();
  String? _selectedDonation;

  final List<Map<String, dynamic>> _donationTiers = [
    {'id': ProductIds.donation1, 'amount': '\$1', 'label': 'Café'},
    {'id': ProductIds.donation3, 'amount': '\$3', 'label': 'Snack'},
    {'id': ProductIds.donation5, 'amount': '\$5', 'label': 'Almuerzo'},
    {'id': ProductIds.donation10, 'amount': '\$10', 'label': 'Cena'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Apoyar Streakify'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildHeader(),
            const SizedBox(height: 24),
            _buildDonationTiers(),
            const SizedBox(height: 24),
            _buildDonateButton(),
            const SizedBox(height: 16),
            _buildThankYouMessage(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Icon(
          Icons.favorite,
          size: 64,
          color: Theme.of(context).colorScheme.primary,
        ),
        const SizedBox(height: 16),
        Text(
          '¿Te gusta Streakify?',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 8),
        Text(
          'Tu apoyo ayuda a mantener la app gratis y sin anuncios para todos',
          style: Theme.of(context).textTheme.bodyMedium,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildDonationTiers() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.2,
      ),
      itemCount: _donationTiers.length,
      itemBuilder: (context, index) {
        final tier = _donationTiers[index];
        final isSelected = _selectedDonation == tier['id'];
        
        return GestureDetector(
          onTap: () => setState(() => _selectedDonation = tier['id']),
          child: Container(
            decoration: BoxDecoration(
              color: isSelected
                  ? Theme.of(context).colorScheme.primaryContainer
                  : Theme.of(context).colorScheme.surfaceVariant,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSelected
                    ? Theme.of(context).colorScheme.primary
                    : Colors.transparent,
                width: 2,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  tier['amount'],
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: isSelected
                        ? Theme.of(context).colorScheme.onPrimaryContainer
                        : null,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  tier['label'],
                  style: TextStyle(
                    fontSize: 16,
                    color: isSelected
                        ? Theme.of(context).colorScheme.onPrimaryContainer
                        : Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDonateButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _selectedDonation == null || _purchaseService.purchasePending
            ? null
            : _donate,
        icon: const Icon(Icons.favorite),
        label: _purchaseService.purchasePending
            ? const CircularProgressIndicator()
            : const Text('Donar', style: TextStyle(fontSize: 18)),
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
      ),
    );
  }

  Widget _buildThankYouMessage() {
    return Card(
      color: Theme.of(context).colorScheme.surfaceVariant,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(
              Icons.emoji_emotions,
              size: 32,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 8),
            const Text(
              '¡Gracias por tu apoyo!',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 4),
            const Text(
              'Cada donación nos ayuda a seguir mejorando Streakify',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _donate() async {
    if (_selectedDonation == null) return;

    final success = await _purchaseService.purchaseProduct(_selectedDonation!);
    
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Procesando donación...')),
      );
      
      // Show thank you dialog after successful donation
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          _showThankYouDialog();
        }
      });
    }
  }

  void _showThankYouDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.favorite, color: Colors.red),
            SizedBox(width: 8),
            Text('¡Muchas Gracias!'),
          ],
        ),
        content: const Text(
          'Tu generosidad nos ayuda a mantener Streakify gratis y sin anuncios. '
          '¡Eres increíble!',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }
}
