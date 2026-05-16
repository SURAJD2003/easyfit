class SubscriptionPlanModel {
  final String planId;
  final String name;
  final double price;
  final String duration;
  final List<String> features;

  SubscriptionPlanModel({
    required this.planId,
    required this.name,
    required this.price,
    required this.duration,
    required this.features,
  });

  factory SubscriptionPlanModel.fromJson(Map<String, dynamic> json) {
    return SubscriptionPlanModel(
      planId: json['planId'] ?? '',
      name: json['name'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      duration: json['duration'] ?? '',
      features: List<String>.from(json['features'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'planId': planId,
      'name': name,
      'price': price,
      'duration': duration,
      'features': features,
    };
  }
}
