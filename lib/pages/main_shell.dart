import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../main.dart';
import 'home_page.dart';
import 'favorite_page.dart';
import 'profile_page.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int currentIndex = 0;

  final pages = const [
    HomePage(),
    FavoritePage(),
    ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kPurpleBg1,
      extendBody: true, 
      body: Stack(
        children: [
          pages[currentIndex],

          // FLOATING NAVBAR
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 24),
              child: _buildNavbar(),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================
  //              FLOATING NAVIGATION BAR
  // ============================================
  Widget _buildNavbar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(38),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _navItem(
            index: 0,
            icon: Icons.home_rounded,
            label: "Home",
          ),
          const SizedBox(width: 26),
          _navItem(
            index: 1,
            icon: Icons.favorite_rounded,
            label: "Favorite",
          ),
          const SizedBox(width: 26),
          _navItem(
            index: 2,
            icon: Icons.person_rounded,
            label: "Profile",
          ),
        ],
      ),
    );
  }

  Widget _navItem({
    required int index,
    required IconData icon,
    required String label,
  }) {
    final bool selected = currentIndex == index;

    return GestureDetector(
      onTap: () {
        setState(() => currentIndex = index);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? kPurplePrimary.withOpacity(0.15) : Colors.transparent,
          borderRadius: BorderRadius.circular(22),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: selected ? 26 : 24,
              color: selected ? kPurplePrimary : kTextLight,
            ),
            if (selected) ...[
              const SizedBox(width: 8),
              Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: kPurplePrimary,
                ),
              ),
            ]
          ],
        ),
      ),
    );
  }
}
