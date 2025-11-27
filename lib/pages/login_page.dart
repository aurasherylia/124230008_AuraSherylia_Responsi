import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../main.dart';
import 'main_shell.dart';
import 'register_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final userC = TextEditingController();
  final passC = TextEditingController();

  bool loading = false;
  bool obscure = true;

  void showPopup({
    required String title,
    required String message,
    required bool success,
    VoidCallback? onOk,
  }) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22),
        ),
        child: Padding(
          padding: const EdgeInsets.all(22),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(success ? Icons.check_circle_rounded : Icons.error_rounded,
                  size: 70,
                  color: success ? kPurplePrimary : Colors.redAccent),
              const SizedBox(height: 14),
              Text(title,
                  style: GoogleFonts.poppins(
                      fontSize: 18, fontWeight: FontWeight.w700)),
              const SizedBox(height: 6),
              Text(message,
                  textAlign: TextAlign.center,
                  style:
                      GoogleFonts.poppins(fontSize: 13, color: kTextLight)),
              const SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: kPurplePrimary,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  minimumSize: const Size(double.infinity, 48),
                ),
                onPressed: () {
                  Navigator.pop(context);
                  if (onOk != null) onOk();
                },
                child: Text("OK",
                    style: GoogleFonts.poppins(
                        color: Colors.white, fontWeight: FontWeight.w600)),
              )
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  //                        LOGIN MULTI USER
  // ============================================================
  Future<void> handleLogin() async {
    if (userC.text.isEmpty || passC.text.isEmpty) {
      return showPopup(
        title: "Login Gagal",
        message: "Silakan isi semua kolom!",
        success: false,
      );
    }

    final prefs = await SharedPreferences.getInstance();
    final users = prefs.getStringList("users") ?? [];

    bool found = false;

    for (String u in users) {
      final data = jsonDecode(u);

      if (data["username"] == userC.text &&
          data["password"] == passC.text) {
        found = true;

        await prefs.setBool("logged_in", true);
        await prefs.setString("current_username", userC.text);

        showPopup(
          title: "Berhasil",
          message: "Selamat datang, ${data["username"]}!",
          success: true,
          onOk: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const MainShell()),
            );
          },
        );
        break;
      }
    }

    if (!found) {
      showPopup(
        title: "Login Gagal",
        message: "Username atau password salah.",
        success: false,
      );
    }
  }

  // ============================================================
  //                        BUILD UI
  // ============================================================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [kPurpleBg1, kPurpleBg2],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                child: ConstrainedBox(
                  constraints:
                      BoxConstraints(minHeight: constraints.maxHeight),
                  child: IntrinsicHeight(
                    child: Column(
                      children: [
                        const SizedBox(height: 40),

                        // LOGO
                        Container(
                          padding: const EdgeInsets.all(28),
                          decoration: BoxDecoration(
                              color: kPurplePrimary.withOpacity(0.15),
                              shape: BoxShape.circle),
                          child: const Icon(Icons.restaurant,
                              size: 64, color: kPurplePrimary),
                        ),

                        const SizedBox(height: 20),

                        Text("Selamat Datang",
                            style: GoogleFonts.poppins(
                                fontSize: 22,
                                fontWeight: FontWeight.w700,
                                color: kTextDark)),
                        Text("Masuk untuk melanjutkan",
                            style: GoogleFonts.poppins(
                                fontSize: 13, color: kTextLight)),

                        const SizedBox(height: 40),

                        // ================= FORM CARD =================
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 26),
                          child: Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(26),
                              boxShadow: [
                                BoxShadow(
                                    color: Colors.black.withOpacity(0.06),
                                    blurRadius: 22,
                                    offset: const Offset(0, 10))
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _label("Username"),
                                _inputField(
                                  controller: userC,
                                  hint: "Masukkan username",
                                  icon: Icons.person_outline,
                                ),

                                const SizedBox(height: 18),

                                _label("Password"),
                                _inputField(
                                  controller: passC,
                                  hint: "Masukkan password",
                                  icon: Icons.lock_outline,
                                  isPassword: true,
                                  obscure: obscure,
                                  toggle: () =>
                                      setState(() => obscure = !obscure),
                                ),

                                const SizedBox(height: 26),

                                SizedBox(
                                  height: 52,
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    onPressed:
                                        loading ? null : handleLogin,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: kPurplePrimary,
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(18)),
                                    ),
                                    child: loading
                                        ? const CircularProgressIndicator(
                                            color: Colors.white,
                                            strokeWidth: 2.2)
                                        : Text("Masuk",
                                            style: GoogleFonts.poppins(
                                                color: Colors.white,
                                                fontWeight: FontWeight.w600,
                                                fontSize: 15)),
                                  ),
                                ),

                                const SizedBox(height: 18),

                                Center(
                                  child: GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (_) =>
                                                const RegisterPage()),
                                      );
                                    },
                                    child: RichText(
                                      text: TextSpan(
                                        text: "Belum punya akun? ",
                                        style: GoogleFonts.poppins(
                                            color: kTextLight,
                                            fontSize: 12.5),
                                        children: [
                                          TextSpan(
                                            text: "Daftar",
                                            style: GoogleFonts.poppins(
                                              color: kPurplePrimary,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),

                        const Spacer(),
                        const SizedBox(height: 30),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _label(String text) => Text(text,
      style: GoogleFonts.poppins(
          fontSize: 13, fontWeight: FontWeight.w600, color: kTextDark));

  Widget _inputField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool isPassword = false,
    bool obscure = false,
    VoidCallback? toggle,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: kPurpleLight,
        borderRadius: BorderRadius.circular(16),
      ),
      child: TextField(
        controller: controller,
        obscureText: obscure,
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: kPurplePrimary),
          suffixIcon: isPassword
              ? IconButton(
                  onPressed: toggle,
                  icon: Icon(
                    obscure ? Icons.visibility_off : Icons.visibility,
                    color: kPurplePrimary,
                  ),
                )
              : null,
          hintText: hint,
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(vertical: 14, horizontal: 0),
        ),
      ),
    );
  }
}
