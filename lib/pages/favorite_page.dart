// lib/pages/favorite_page.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../main.dart';
import 'restaurant_detail_page.dart';

class FavoritePage extends StatefulWidget {
  const FavoritePage({super.key});

  @override
  State<FavoritePage> createState() => _FavoritePageState();
}

class _FavoritePageState extends State<FavoritePage>
    with SingleTickerProviderStateMixin {
  List<Map<String, dynamic>> favorites = [];
  String currentUser = "";
  late AnimationController _anim;

  @override
  void initState() {
    super.initState();
    loadFavorites();

    _anim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
      lowerBound: 0.95,
      upperBound: 1.0,
    );
  }

  @override
  void dispose() {
    _anim.dispose();
    super.dispose();
  }


  Future<void> loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    currentUser = prefs.getString("current_username") ?? "User";

    final stored = prefs.getStringList("favorite_$currentUser") ?? [];

    favorites = stored
        .map((e) {
          try {
            final json = jsonDecode(e);
            if (json is Map<String, dynamic>) return json;
          } catch (_) {}
          return null;
        })
        .where((e) =>
            e != null &&
            e["id"] != null &&
            e["name"] != null &&
            e["city"] != null &&
            e["image"] != null)
        .map((e) => e as Map<String, dynamic>)
        .toList();

    setState(() {});
  }

  Future<void> deleteFavorite(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final key = "favorite_$currentUser";

    favorites.removeWhere((e) => e["id"] == id);

    await prefs.setStringList(
      key,
      favorites.map((e) => jsonEncode(e)).toList(),
    );

    loadFavorites();
  }

  Future<bool> confirmDelete() async {
    return await showDialog(
          context: context,
          builder: (_) {
            return AlertDialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
              title: Text(
                "Hapus Favorite?",
                style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w700, color: kTextDark),
              ),
              content: Text(
                "Apakah kamu yakin ingin menghapus item ini dari favorit?",
                style: GoogleFonts.poppins(
                    fontSize: 14, color: kTextLight),
              ),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: Text("Batal", style: GoogleFonts.poppins())),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent),
                  onPressed: () => Navigator.pop(context, true),
                  child: Text("Hapus",
                      style: GoogleFonts.poppins(color: Colors.white)),
                ),
              ],
            );
          },
        ) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kPurpleBg1,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 20),

            // Title
            Text(
              "My Favorite",
              style: GoogleFonts.poppins(
                fontSize: 28,
                fontWeight: FontWeight.w800,
                color: kTextDark,
              ),
            ),

            const SizedBox(height: 20),

            Expanded(
              child: favorites.isEmpty
                  ? _emptyView()
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 18, vertical: 10),
                      itemCount: favorites.length,
                      itemBuilder: (_, i) =>
                          _swipeCard(favorites[i]),
                    ),
            ),

            const SizedBox(height: 60),
          ],
        ),
      ),
    );
  }

  Widget _emptyView() {
    return Center(
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 600),
        opacity: 1,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.favorite_border_rounded,
                size: 90, color: kPurplePrimary.withOpacity(.3)),
            const SizedBox(height: 14),
            Text("Belum Ada Favorite",
                style: GoogleFonts.poppins(
                    fontSize: 20, fontWeight: FontWeight.w700)),
            Text("Tambahkan dari halaman detail",
                style:
                    GoogleFonts.poppins(color: kTextLight, fontSize: 14)),
          ],
        ),
      ),
    );
  }

  Widget _swipeCard(Map<String, dynamic> item) {
    return Dismissible(
      key: Key(item["id"]),
      direction: DismissDirection.endToStart,
      confirmDismiss: (_) => confirmDelete(),
      onDismissed: (_) => deleteFavorite(item["id"]),
      background: Container(
        decoration: BoxDecoration(
          color: Colors.redAccent,
          borderRadius: BorderRadius.circular(22),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        child: const Icon(Icons.delete, color: Colors.white, size: 32),
      ),
      child: _favoriteCard(item),
    );
  }

  Widget _favoriteCard(Map<String, dynamic> item) {
    return GestureDetector(
      onTapDown: (_) => _anim.reverse(),
      onTapUp: (_) => _anim.forward(),
      onTapCancel: () => _anim.forward(),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => RestaurantDetailPage(id: item["id"]),
          ),
        );
      },
      child: ScaleTransition(
        scale: _anim,
        child: Container(
          margin: const EdgeInsets.only(bottom: 18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(.08),
                blurRadius: 18,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            children: [
              Hero(
                tag: item["id"],
                child: ClipRRect(
                  borderRadius: const BorderRadius.horizontal(
                      left: Radius.circular(22)),
                  child: Image.network(
                    "https://restaurant-api.dicoding.dev/images/medium/${item["image"]}",
                    width: 120,
                    height: 120,
                    fit: BoxFit.cover,
                  ),
                ),
              ),

              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item["name"],
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: kTextDark)),

                      const SizedBox(height: 6),

                      Row(
                        children: [
                          Icon(Icons.location_on_rounded,
                              size: 16, color: kPurplePrimary),
                          const SizedBox(width: 6),
                          Text(item["city"],
                              style: GoogleFonts.poppins(
                                  color: kTextLight, fontSize: 13)),
                        ],
                      ),

                      const SizedBox(height: 6),

                      Row(
                        children: [
                          const Icon(Icons.star_rounded,
                              color: Colors.amber, size: 18),
                          const SizedBox(width: 4),
                          Text(
                            "${item["rating"]}",
                            style: GoogleFonts.poppins(
                                color: kTextDark,
                                fontSize: 13,
                                fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
