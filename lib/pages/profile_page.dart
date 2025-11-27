// lib/pages/profile_page.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive/hive.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import '../main.dart';
import '../models/profile_model.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late Box<ProfileModel> profileBox;
  ProfileModel? profile;
  bool loading = true;

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _initProfile();
  }

  Future<void> _initProfile() async {
    profileBox = Hive.box<ProfileModel>("profileBox");

    final prefs = await SharedPreferences.getInstance();
    final currentUsername = prefs.getString("current_username") ?? "User";

    var existing = profileBox.get(currentUsername);

    if (existing == null) {
      existing = ProfileModel(
        name: currentUsername,
        nim: "124230008",
        username: currentUsername,
        photoPath: null,
      );
      await profileBox.put(currentUsername, existing);
    }

    setState(() {
      profile = existing;
      loading = false;
    });
  }

  Future<void> pickImage(ImageSource src) async {
    final picked = await _picker.pickImage(
      source: src,
      imageQuality: 80,
    );

    if (picked != null && profile != null) {
      profile!.photoPath = picked.path;
      await profile!.save();
      setState(() {});
      _snack("Foto profil berhasil diperbarui ✨", Colors.green);
    }
  }

  void openPhotoPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(18, 18, 18, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 50,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(100),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                "Ubah Foto Profil",
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: kTextDark,
                ),
              ),
              const SizedBox(height: 8),
              ListTile(
                leading: const Icon(Icons.photo_library_rounded,
                    color: kPurplePrimary),
                title: const Text("Pilih dari Galeri"),
                onTap: () {
                  Navigator.pop(context);
                  pickImage(ImageSource.gallery);
                },
              ),
              ListTile(
                leading:
                    const Icon(Icons.camera_alt_rounded, color: kPurplePrimary),
                title: const Text("Ambil dari Kamera"),
                onTap: () {
                  Navigator.pop(context);
                  pickImage(ImageSource.camera);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // =====================================================
  //                        LOGOUT
  // =====================================================
  Future<void> _logout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          "Keluar Akun?",
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w700,
            color: kTextDark,
          ),
        ),
        content: Text(
          "Kamu akan keluar dari akun ini, namun data login tetap aman.",
          style: GoogleFonts.poppins(fontSize: 13, color: kTextLight),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              "Batal",
              style:
                  GoogleFonts.poppins(color: kPurplePrimary, fontWeight: FontWeight.w600),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Logout", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool("logged_in", false);

      if (!mounted) return;
      Navigator.pushNamedAndRemoveUntil(context, "/login", (_) => false);
    }
  }

  // =====================================================
  //                        BUILD UI
  // =====================================================
  @override
  Widget build(BuildContext context) {
    const bgGradient = LinearGradient(
      colors: [kPurpleBg1, kPurpleBg1],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );

    if (loading || profile == null) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: kPurplePrimary),
        ),
      );
    }

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: bgGradient),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildHeaderTitle(),
                const SizedBox(height: 20),
                _buildAvatarCard(),
                const SizedBox(height: 26),
                _buildSocialMediaCard(),
                const SizedBox(height: 26),
                _buildLogoutButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // HEADER TITLE
  Widget _buildHeaderTitle() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Profil Saya",
              style: GoogleFonts.poppins(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: kTextDark,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              "Kelola identitas akunmu✨",
              style: GoogleFonts.poppins(
                fontSize: 12.5,
                color: kTextLight,
              ),
            ),
          ],
        ),
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.7),
            borderRadius: BorderRadius.circular(14),
          ),
          child: const Icon(Icons.restaurant, color: kPurplePrimary),
        )
      ],
    );
  }

  // AVATAR CARD
  Widget _buildAvatarCard() {
    final photoExists = profile!.photoPath != null &&
        File(profile!.photoPath!).existsSync();

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26),
        gradient: const LinearGradient(
          colors: [Color(0xFF7E57C2), Color(0xFF5E35B1)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.deepPurple.withOpacity(0.35),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Stack(
            alignment: Alignment.bottomRight,
            children: [
              CircleAvatar(
                radius: 55,
                backgroundColor: Colors.white,
                backgroundImage:
                    photoExists ? FileImage(File(profile!.photoPath!)) : null,
                child: !photoExists
                    ? const Icon(Icons.person_rounded,
                        size: 60, color: Colors.deepPurple)
                    : null,
              ),
              Positioned(
                bottom: 4,
                right: 4,
                child: GestureDetector(
                  onTap: openPhotoPicker,
                  child: Container(
                    padding: const EdgeInsets.all(7),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.25),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: const Icon(Icons.camera_alt_rounded,
                        size: 18, color: Colors.deepPurple),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            profile!.username,
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            "NIM: 124230008",
            style: GoogleFonts.poppins(
              fontSize: 13,
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }

  // =====================================================
  //               SOCIAL MEDIA SECTION CARD
  // =====================================================
  Widget _buildSocialMediaCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Sosial Media",
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: kTextDark,
            ),
          ),
          const SizedBox(height: 14),

          Row(
            children: [
              Expanded(
                child: _socialIcon(
                  'assets/images/instagram.png',
                  'Instagram',
                  'https://instagram.com/aurasherylia',
                  showBorder: true,
                ),
              ),
              Expanded(
                child: _socialIcon(
                  'assets/images/whatsapp.png',
                  'WhatsApp',
                  'https://wa.me/6288216526097',
                  showBorder: true,
                ),
              ),
              Expanded(
                child: _socialIcon(
                  'assets/images/tiktok.png',
                  'TikTok',
                  'https://tiktok.com/@aurasherylia',
                  showBorder: false,
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _socialIcon(
    String asset,
    String label,
    String url, {
    bool showBorder = false,
  }) {
    return InkWell(
      onTap: () async {
        final uri = Uri.parse(url);
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        } else {
          _snack("Tidak dapat membuka link", Colors.red);
        }
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 6),
        decoration: BoxDecoration(
          border: Border(
            right: showBorder
                ? const BorderSide(
                    color: Color(0xFFBFA9E9),
                    width: 1.0,
                  )
                : BorderSide.none,
          ),
        ),
        child: Column(
          children: [
            Image.asset(asset, height: 40),
            const SizedBox(height: 6),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                color: kTextDark,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // LOGOUT BUTTON
  Widget _buildLogoutButton() {
    return GestureDetector(
      onTap: _logout,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFE53935), Color(0xFFD32F2F)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.redAccent.withOpacity(0.35),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.logout_rounded, color: Colors.white),
            const SizedBox(width: 8),
            Text(
              "Logout",
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w700,
                color: Colors.white,
                fontSize: 15,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // SNACKBAR
  void _snack(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
