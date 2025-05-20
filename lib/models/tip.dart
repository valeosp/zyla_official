class Tip {
  final String id;
  final String title;
  final String description;
  final String category;
  final String imageUrl;

  Tip({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.imageUrl,
  });

  factory Tip.fromMap(String id, Map<String, dynamic> data) {
    return Tip(
      id: id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      category: data['category'] ?? '',
      imageUrl: data['image_url'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'category': category,
      'image_url': imageUrl,
    };
  }
}
