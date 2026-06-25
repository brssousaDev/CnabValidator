class LayoutCategory {
  final String category;
  final List<String> layouts;

  LayoutCategory({
    required this.category,
    required this.layouts,
  });

  factory LayoutCategory.fromJson(Map<String, dynamic> json) {
    return LayoutCategory(
      category: json['category'] as String,
      layouts: List<String>.from(json['layouts'] as List),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'category': category,
      'layouts': layouts,
    };
  }
}
