// lib/pages/home_page.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../main.dart';
import '../models/restaurant_model.dart';
import '../services/api_service.dart';
import 'restaurant_detail_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String currentUser = "User";
  List<Restaurant> restaurants = [];
  bool loading = true;

  final List<String> categories = [
    "Semua",
    "Italia",
    "Modern",
    "Sunda",
    "Jawa",
    "Bali",
  ];

  String selectedCategory = "Semua";

  @override
  void initState() {
    super.initState();
    loadUser();
    loadAllRestaurants();
  }

  Future<void> loadUser() async {
    final prefs = await SharedPreferences.getInstance();
    currentUser = prefs.getString("current_username") ?? "User";
    setState(() {});
  }

  Future<void> loadAllRestaurants() async {
    restaurants = await ApiService.getRestaurants();
    loading = false;
    setState(() {});
  }

  Future<void> filterCategory(String category) async {
    setState(() {
      selectedCategory = category;
      loading = true;
    });

    if (category == "Semua") {
      await loadAllRestaurants();
    } else {
      restaurants = await ApiService.searchRestaurant(category);
      loading = false;
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kPurpleBg1,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Halo, $currentUser 👋",
                style: GoogleFonts.poppins(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: kTextDark,
                ),
              ),
              const SizedBox(height: 6),

              Text(
                "Jelajahi restoran terbaik hari ini!",
                style: GoogleFonts.poppins(
                  color: kTextLight,
                  fontSize: 15,
                ),
              ),

              const SizedBox(height: 20),

              // 🔥 CHIP KATEGORI FILTER
              SizedBox(
                height: 48,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: categories.length,
                  itemBuilder: (_, i) {
                    final c = categories[i];
                    final selected = c == selectedCategory;

                    return GestureDetector(
                      onTap: () => filterCategory(c),
                      child: Container(
                        margin: const EdgeInsets.only(right: 12),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 18, vertical: 10),
                        decoration: BoxDecoration(
                          color: selected ? kPurplePrimary : Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                              color: selected
                                  ? kPurplePrimary
                                  : Colors.grey.shade300),
                        ),
                        child: Row(
                          children: [
                            if (selected)
                              const Icon(Icons.check_rounded,
                                  color: Colors.white, size: 18),
                            if (selected) const SizedBox(width: 6),
                            Text(
                              c,
                              style: GoogleFonts.poppins(
                                color: selected ? Colors.white : kTextDark,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 26),

              loading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: kPurplePrimary,
                      ),
                    )
                  : ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: restaurants.length,
                      itemBuilder: (_, i) =>
                          _restaurantCard(restaurants[i]),
                    ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _restaurantCard(Restaurant r) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => RestaurantDetailPage(id: r.id),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              blurRadius: 18,
              offset: const Offset(0, 6),
              color: Colors.black.withOpacity(.08),
            )
          ],
        ),
        child: Column(
          children: [
            ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(22)),
              child: Image.network(
                "https://restaurant-api.dicoding.dev/images/medium/${r.pictureId}",
                height: 160,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    r.name,
                    style: GoogleFonts.poppins(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.location_on_rounded,
                          color: kPurplePrimary, size: 18),
                      const SizedBox(width: 4),
                      Text(
                        r.city,
                        style: GoogleFonts.poppins(
                            fontSize: 13, color: kTextLight),
                      ),
                      const Spacer(),
                      const Icon(Icons.star_rounded,
                          size: 20, color: Colors.amber),
                      const SizedBox(width: 6),
                      Text(
                        "${r.rating}",
                        style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w600),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
