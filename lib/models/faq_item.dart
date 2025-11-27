/// FAQ item model
class FAQItem {
  final String question;
  final String answer;
  final String category;
  final List<String> tags;

  const FAQItem({
    required this.question,
    required this.answer,
    required this.category,
    this.tags = const [],
  });
}
