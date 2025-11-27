import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../main.dart';
import '../models/restaurant_model.dart';
import '../services/api_service.dart';
import 'restaurant_detail_page.dart';

class ListPage extends StatefulWidget {
  final String category; // kategori = city / kota

  const ListPage({super.key, required this.category});

  @override
  State<ListPage> createState() => _ListPageState();
}

class _ListPageState extends State<ListPage> {
  List<Restaurant> restaurants = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    // ambil semua restoran
    final all = await ApiService.getRestaurants();

    // filter sesuai city (kategori)
    restaurants =
        all.where((e) => e.city.toLowerCase() == widget.category.toLowerCase()).toList();

    loading = false;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kPurpleBg1,
      appBar: AppBar(
        backgroundColor: kPurpleBg1,
        elevation: 0,
        title: Text(
          widget.category.toUpperCase(),
          style: GoogleFonts.poppins(
            color: kTextDark,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: loading
          ? const Center(
              child: CircularProgressIndicator(color: kPurplePrimary),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: restaurants.length,
              itemBuilder: (_, i) {
                return _restaurantCard(restaurants[i]);
              },
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
        margin: const EdgeInsets.only(bottom: 18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              blurRadius: 14,
              offset: const Offset(0, 5),
              color: Colors.black.withOpacity(.07),
            ),
          ],
        ),
        child: Row(
          children: [
            // IMAGE
            ClipRRect(
              borderRadius:
                  const BorderRadius.horizontal(left: Radius.circular(22)),
              child: Image.network(
                "https://restaurant-api.dicoding.dev/images/medium/${r.pictureId}",
                width: 120,
                height: 120,
                fit: BoxFit.cover,
              ),
            ),

            // TEXT
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      r.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: kTextDark,
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
                            fontSize: 13,
                            color: kTextLight,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.star_rounded,
                            color: Colors.amber, size: 18),
                        const SizedBox(width: 4),
                        Text(
                          "${r.rating}",
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            color: kTextLight,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
