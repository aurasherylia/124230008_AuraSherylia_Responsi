import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/restaurant_model.dart';

class ApiService {
  static const baseUrl = "https://restaurant-api.dicoding.dev";

  static Future<List<Restaurant>> getRestaurants() async {
    final url = Uri.parse("$baseUrl/list");
    final res = await http.get(url);

    final data = jsonDecode(res.body);
    List list = data["restaurants"];

    return list.map((e) => Restaurant.fromJson(e)).toList();
  }

  static Future<Map<String, dynamic>> getRestaurantDetail(String id) async {
    final url = Uri.parse("$baseUrl/detail/$id");
    final res = await http.get(url);

    return jsonDecode(res.body)["restaurant"];
  }

  static Future<List<Restaurant>> searchRestaurant(String query) async {
    final url = Uri.parse("$baseUrl/search?q=$query");
    final res = await http.get(url);

    final data = jsonDecode(res.body);
    List list = data["restaurants"];

    return list.map((e) => Restaurant.fromJson(e)).toList();
  }
}
