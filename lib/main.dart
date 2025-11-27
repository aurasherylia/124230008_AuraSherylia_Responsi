import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'models/profile_model.dart';
import 'pages/login_page.dart';
import 'pages/main_shell.dart';

// ===========================================
//  GLOBAL COLOR THEME
// ===========================================
const Color kPurplePrimary = Color(0xFF6C4ADE);
const Color kPurpleDark = Color(0xFF5A3FCF);
const Color kPurpleLight = Color(0xFFF3EFFF);
const Color kPurpleBg1 = Color(0xFFF7F2FF);
const Color kPurpleBg2 = Color(0xFFF0E9FF);
const Color kTextDark = Color(0xFF1F1F1F);
const Color kTextLight = Color(0xFF7A7A7A);

// ===========================================
//                   MAIN
// ===========================================
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // init Hive
  await Hive.initFlutter();
  Hive.registerAdapter(ProfileModelAdapter());
  await Hive.openBox<ProfileModel>("profileBox");

  runApp(const SpaceflightApp());
}

class SpaceflightApp extends StatelessWidget {
  const SpaceflightApp({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = ThemeData(
      fontFamily: GoogleFonts.poppins().fontFamily,
      scaffoldBackgroundColor: kPurpleBg1,
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: kPurplePrimary,
        primary: kPurplePrimary,
      ),
    );

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: theme,

      // route untuk navigasi manual
      routes: {
        "/login": (_) => const LoginPage(),
        "/main": (_) => const MainShell(),
      },

      // SELALU mulai dari LoginPage
      home: const LoginPage(),
    );
  }
}
