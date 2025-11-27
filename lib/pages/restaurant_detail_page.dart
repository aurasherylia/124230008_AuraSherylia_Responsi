
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../main.dart';
import '../models/restaurant_model.dart';
import '../services/api_service.dart';

class RestaurantDetailPage extends StatefulWidget {
  final String id;
  const RestaurantDetailPage({super.key, required this.id});

  @override
  State<RestaurantDetailPage> createState() => _RestaurantDetailPageState();
}

class _RestaurantDetailPageState extends State<RestaurantDetailPage>
    with SingleTickerProviderStateMixin {
  Restaurant? restaurant;
  bool loading = true;

  List<Map<String, dynamic>> favorites = [];
  String currentUser = "";

  late AnimationController favAnim;

  @override
  void initState() {
    super.initState();

    favAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 260),
      lowerBound: 0.8,
      upperBound: 1.2,
    );

    loadDetail();
    loadUserData();
  }

  Future<void> loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    currentUser = prefs.getString("current_username") ?? "User";

    final stored = prefs.getStringList("favorite_$currentUser") ?? [];

    favorites = stored
        .map((e) {
          try {
            return jsonDecode(e) as Map<String, dynamic>;
          } catch (_) {
            return null;
          }
        })
        .where((e) => e != null)
        .cast<Map<String, dynamic>>()
        .toList();

    setState(() {});
  }

  bool get isFavorite =>
      favorites.any((e) => e["id"] == restaurant?.id);

  Future<void> toggleFavorite() async {
    if (restaurant == null) return;

    favAnim.forward().then((_) => favAnim.reverse());

    final prefs = await SharedPreferences.getInstance();
    final key = "favorite_$currentUser";

    favorites.removeWhere((e) => e["id"] == restaurant!.id);

    if (!isFavorite) {
      favorites.add({
        "id": restaurant!.id,
        "name": restaurant!.name,
        "city": restaurant!.city,
        "address": restaurant!.address,
        "image": restaurant!.pictureId,
        "rating": restaurant!.rating,
      });
    }

    await prefs.setStringList(
        key, favorites.map((e) => jsonEncode(e)).toList());

    setState(() {});
  }

  Future<void> loadDetail() async {
    final raw = await ApiService.getRestaurantDetail(widget.id);
    restaurant = Restaurant.fromJson(raw);
    loading = false;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (loading || restaurant == null) {
      return const Scaffold(
        backgroundColor: kPurpleBg1,
        body: Center(
            child: CircularProgressIndicator(color: kPurplePrimary)),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          SizedBox(
            height: 330,
            width: double.infinity,
            child: Stack(
              children: [
                Hero(
                  tag: restaurant!.pictureId,
                  child: Image.network(
                    "https://restaurant-api.dicoding.dev/images/large/${restaurant!.pictureId}",
                    width: double.infinity,
                    height: 330,
                    fit: BoxFit.cover,
                  ),
                ),
                Container(
                  height: 330,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.black.withOpacity(.6),
                        Colors.black.withOpacity(.25),
                        Colors.transparent,
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                ),
              ],
            ),
          ),

          SafeArea(
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // BACK BUTTON
                  _circleBtn(Icons.arrow_back_ios_new_rounded,
                      () => Navigator.pop(context),
                      bg: Colors.white.withOpacity(.8),
                      color: kPurplePrimary),

                  // LOVE BUTTON
                  ScaleTransition(
                    scale: favAnim,
                    child: _circleBtn(
                      isFavorite
                          ? Icons.favorite_rounded
                          : Icons.favorite_border_rounded,
                      toggleFavorite,
                      color: isFavorite ? Colors.red : kTextDark,
                      bg: Colors.white,
                      glow: isFavorite,
                    ),
                  )
                ],
              ),
            ),
          ),

          DraggableScrollableSheet(
            minChildSize: .60,
            initialChildSize: .60,
            maxChildSize: 1,
            builder: (_, scroll) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 22),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius:
                      BorderRadius.vertical(top: Radius.circular(28)),
                ),
                child: SingleChildScrollView(
                  controller: scroll,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 24),

                      Text(
                        restaurant!.name,
                        style: GoogleFonts.poppins(
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                        ),
                      ),

                      const SizedBox(height: 10),

                      Row(
                        children: [
                          Icon(Icons.location_on_rounded,
                              color: kPurplePrimary),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              "${restaurant!.city} • ${restaurant!.address}",
                              style: GoogleFonts.poppins(
                                  color: kTextLight, fontSize: 14),
                            ),
                          ),
                          const Icon(Icons.star_rounded,
                              color: Colors.amber, size: 20),
                          Text(
                            restaurant!.rating.toString(),
                            style: GoogleFonts.poppins(
                                fontSize: 15,
                                fontWeight: FontWeight.w600),
                          )
                        ],
                      ),

                      const SizedBox(height: 22),

                      _section("Kategori"),
                      Wrap(
                        spacing: 10,
                        children: restaurant!.categories
                            .map((e) => Chip(
                                  avatar: const Icon(Icons.label_rounded,
                                      size: 16, color: Colors.deepPurple),
                                  backgroundColor: Colors.deepPurple.shade50,
                                  label: Text(e["name"],
                                      style: GoogleFonts.poppins(
                                          color: kTextDark)),
                                ))
                            .toList(),
                      ),

                      const SizedBox(height: 22),

                      _section("Deskripsi"),
                      Text(
                        restaurant!.description,
                        style: GoogleFonts.poppins(
                            fontSize: 14,
                            height: 1.6,
                            color: kTextDark),
                      ),

                      const SizedBox(height: 22),

                      _section("Menu Makanan"),
                      _menuWrap(restaurant!.foods, Colors.orange),

                      const SizedBox(height: 20),

                      _section("Menu Minuman"),
                      _menuWrap(restaurant!.drinks, Colors.blue),

                      const SizedBox(height: 24),

                      _section("Customer Reviews"),

                      Column(
                        children: restaurant!.reviews.map((review) {
                          return Container(
                            margin: const EdgeInsets.only(bottom: 14),
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Icon(Icons.person_rounded,
                                    size: 36, color: kPurplePrimary),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(review["name"],
                                            style: GoogleFonts.poppins(
                                                fontWeight: FontWeight.w600)),
                                        Text(
                                          review["date"],
                                          style: GoogleFonts.poppins(
                                              fontSize: 12,
                                              color: kTextLight),
                                        ),
                                        const SizedBox(height: 6),
                                        Text(review["review"],
                                            style: GoogleFonts.poppins(
                                                fontSize: 14)),
                                      ]),
                                )
                              ],
                            ),
                          );
                        }).toList(),
                      ),

                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }


  Widget _section(String title) {
    return Text(
      title,
      style: GoogleFonts.poppins(
          fontSize: 18, fontWeight: FontWeight.w700),
    );
  }

  Widget _menuWrap(List foods, Color color) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: foods
          .map((e) => Chip(
                avatar: Icon(Icons.fastfood_rounded,
                    color: color, size: 16),
                backgroundColor: color.withOpacity(.15),
                label: Text(e["name"]),
              ))
          .toList(),
    );
  }

  Widget _circleBtn(IconData icon, VoidCallback onTap,
      {Color color = Colors.white,
      Color bg = Colors.black26,
      bool glow = false}) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: bg,
          boxShadow: glow
              ? [
                  BoxShadow(
                    color: Colors.redAccent.withOpacity(.6),
                    blurRadius: 18,
                    spreadRadius: 3,
                  )
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withOpacity(.15),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  )
                ],
        ),
        child: Icon(icon, color: color, size: 26),
      ),
    );
  }
}
