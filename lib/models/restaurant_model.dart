class Restaurant {
  final String id;
  final String name;
  final String description;
  final String city;
  final String address;
  final String pictureId;
  final double rating;

  final List categories; 
  final List foods;          
  final List drinks;       
  final List reviews;          

  Restaurant({
    required this.id,
    required this.name,
    required this.description,
    required this.city,
    required this.address,
    required this.pictureId,
    required this.rating,
    this.categories = const [],
    this.foods = const [],
    this.drinks = const [],
    this.reviews = const [],
  });

  factory Restaurant.fromJson(Map<String, dynamic> json) {
    return Restaurant(
      id: json["id"],
      name: json["name"],
      description: json["description"] ?? "",
      city: json["city"],
      address: json["address"] ?? "",
      pictureId: json["pictureId"],
      rating: (json["rating"] as num).toDouble(),
      categories: json["categories"] ?? [],
      foods: json["menus"]?["foods"] ?? [],
      drinks: json["menus"]?["drinks"] ?? [],
      reviews: json["customerReviews"] ?? [],
    );
  }
}
