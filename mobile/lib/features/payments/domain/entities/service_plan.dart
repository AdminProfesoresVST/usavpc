class ServicePlan {
  final String id;
  final String title;
  final double price;
  final String description;
  final bool isPopular;

  const ServicePlan({
    required this.id,
    required this.title,
    required this.price,
    required this.description,
    this.isPopular = false,
  });
  
  // Factory for DB (Supabase/Json) will go here
  factory ServicePlan.fromJson(Map<String, dynamic> json) {
    return ServicePlan(
      id: json['id'] as String,
      title: json['title'] as String,
      price: (json['price'] as num).toDouble(),
      description: json['description'] as String,
      isPopular: json['is_popular'] as bool? ?? false,
    );
  }
}
