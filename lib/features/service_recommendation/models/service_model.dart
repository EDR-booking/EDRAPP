class ServiceModel {
  final String id;
  final String name;
  final String category;
  final double rating;
  final double distance; // in km
  final String imageUrl;
  final String description;
  final String priceRange; // $ to $$$$
  final String contact;
  
  ServiceModel({
    required this.id,
    required this.name,
    required this.category,
    required this.rating,
    required this.distance,
    required this.imageUrl,
    required this.description,
    required this.priceRange,
    required this.contact,
  });
  
  factory ServiceModel.fromMap(Map<String, dynamic> map) {
    return ServiceModel(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      category: map['category'] ?? '',
      rating: (map['rating'] ?? 0.0).toDouble(),
      distance: (map['distance'] ?? 0.0).toDouble(),
      imageUrl: map['imageUrl'] ?? '',
      description: map['description'] ?? '',
      priceRange: map['priceRange'] ?? '\$',
      contact: map['contact'] ?? '',
    );
  }
}
