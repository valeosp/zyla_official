class Tip {
  final String id;
  final String category; // 'Sexualidad', 'Salud Mental', 'Salud Íntima'
  final String title;
  final String description;
  final String imageUrl; // asset path

  Tip({
    required this.id,
    required this.category,
    required this.title,
    required this.description,
    required this.imageUrl,
  });
}
