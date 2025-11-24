import 'package:flutter/material.dart';
import '../services/motivation_service.dart';

class MotivationCard extends StatefulWidget {
  const MotivationCard({Key? key}) : super(key: key);

  @override
  State<MotivationCard> createState() => _MotivationCardState();
}

class _MotivationCardState extends State<MotivationCard> {
  final MotivationService _motivationService = MotivationService();
  late String _quote;

  @override
  void initState() {
    super.initState();
    _refreshQuote();
  }

  void _refreshQuote() {
    setState(() {
      _quote = _motivationService.getDailyQuote();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [Colors.blue.shade400, Colors.purple.shade400],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Icon(Icons.format_quote, color: Colors.white, size: 30),
                IconButton(
                  icon: const Icon(Icons.refresh, color: Colors.white),
                  onPressed: _refreshQuote,
                  tooltip: 'Nueva frase',
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              _quote,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontStyle: FontStyle.italic,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
