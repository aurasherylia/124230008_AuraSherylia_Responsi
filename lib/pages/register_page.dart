import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../main.dart';
import 'login_page.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final userC = TextEditingController();
  final passC = TextEditingController();
  final confirmC = TextEditingController();

  bool loading = false;
  bool obscure1 = true;
  bool obscure2 = true;

  void showPopup({
    required String title,
    required String message,
    required bool success,
    VoidCallback? onOk,
  }) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22),
        ),
        child: Padding(
          padding: const EdgeInsets.all(22),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                success ? Icons.check_circle_rounded : Icons.error_rounded,
                size: 70,
                color: success ? kPurplePrimary : Colors.redAccent,
              ),
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
                child: Text(
                  "OK",
                  style: GoogleFonts.poppins(
                      color: Colors.white, fontWeight: FontWeight.w600),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  // ===========================================================
  //                    REGISTER MULTI USER
  // ===========================================================
  Future<void> handleRegister() async {
    if (userC.text.isEmpty || passC.text.isEmpty || confirmC.text.isEmpty) {
      return showPopup(
        title: "Gagal",
        message: "Semua kolom wajib diisi.",
        success: false,
      );
    }

    if (passC.text != confirmC.text) {
      return showPopup(
        title: "Gagal",
        message: "Password tidak sama.",
        success: false,
      );
    }

    setState(() => loading = true);
    await Future.delayed(const Duration(milliseconds: 600));

    final prefs = await SharedPreferences.getInstance();
    final users = prefs.getStringList("users") ?? [];

    // cek username sudah ada?
    bool exists = users.any((u) {
      final d = jsonDecode(u);
      return d["username"] == userC.text.trim();
    });

    if (exists) {
      setState(() => loading = false);
      return showPopup(
        title: "Gagal",
        message: "Username sudah terdaftar!",
        success: false,
      );
    }

    // simpan user baru
    Map<String, dynamic> newUser = {
      "username": userC.text.trim(),
      "password": passC.text.trim(),
    };

    users.add(jsonEncode(newUser));
    await prefs.setStringList("users", users);

    setState(() => loading = false);

    showPopup(
      title: "Berhasil",
      message: "Akun berhasil dibuat! Silakan login.",
      success: true,
      onOk: () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const LoginPage()),
        );
      },
    );
  }

  // ===========================================================
  //                        BUILD UI
  // ===========================================================
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

                        // ICON
                        Container(
                          padding: const EdgeInsets.all(28),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: kPurplePrimary.withOpacity(0.15),
                          ),
                          child: const Icon(
                            Icons.person_add_alt_1_rounded,
                            size: 64,
                            color: kPurplePrimary,
                          ),
                        ),

                        const SizedBox(height: 18),
                        Text(
                          "Buat Akun Baru",
                          style: GoogleFonts.poppins(
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                              color: kTextDark),
                        ),

                        const SizedBox(height: 40),

                        // FORM CARD
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 26),
                          child: Container(
                            padding: const EdgeInsets.all(22),
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
                                _field(
                                  controller: userC,
                                  hint: "Buat username",
                                  icon: Icons.person_outline,
                                ),

                                const SizedBox(height: 18),
                                _label("Password"),
                                _field(
                                  controller: passC,
                                  hint: "Buat password",
                                  icon: Icons.lock_outline,
                                  isPass: true,
                                  obscure: obscure1,
                                  toggle: () =>
                                      setState(() => obscure1 = !obscure1),
                                ),

                                const SizedBox(height: 18),
                                _label("Konfirmasi Password"),
                                _field(
                                  controller: confirmC,
                                  hint: "Ulangi password",
                                  icon: Icons.lock_outline,
                                  isPass: true,
                                  obscure: obscure2,
                                  toggle: () =>
                                      setState(() => obscure2 = !obscure2),
                                ),

                                const SizedBox(height: 26),
                                SizedBox(
                                  width: double.infinity,
                                  height: 52,
                                  child: ElevatedButton(
                                    onPressed:
                                        loading ? null : handleRegister,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: kPurplePrimary,
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(18),
                                      ),
                                    ),
                                    child: loading
                                        ? const CircularProgressIndicator(
                                            color: Colors.white,
                                            strokeWidth: 2.0)
                                        : Text(
                                            "Daftar",
                                            style: GoogleFonts.poppins(
                                              fontSize: 15,
                                              color: Colors.white,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                  ),
                                ),

                                const SizedBox(height: 16),

                                Center(
                                  child: GestureDetector(
                                    onTap: () {
                                      Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(
                                            builder: (_) =>
                                                const LoginPage()),
                                      );
                                    },
                                    child: RichText(
                                      text: TextSpan(
                                        text: "Sudah punya akun? ",
                                        style: GoogleFonts.poppins(
                                            color: kTextLight,
                                            fontSize: 12.5),
                                        children: [
                                          TextSpan(
                                            text: "Masuk",
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
                        const SizedBox(height: 32),
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

  Widget _label(String text) => Text(
        text,
        style: GoogleFonts.poppins(
            fontSize: 13, fontWeight: FontWeight.w600, color: kTextDark),
      );

  Widget _field({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool isPass = false,
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
          suffixIcon: isPass
              ? IconButton(
                  icon: Icon(
                      obscure ? Icons.visibility_off : Icons.visibility,
                      color: kPurplePrimary),
                  onPressed: toggle,
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
