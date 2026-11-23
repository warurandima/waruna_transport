import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../services/pin_service.dart';
import '../utils/app_colors.dart';
import '../utils/page_transitions.dart';
import 'dashboard_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _pinController = TextEditingController();
  final _pinService = PinService();
  bool _isLoading = false;

  @override
  void dispose() {
    _pinController.dispose();
    super.dispose();
  }

  Future<void> _submitPin(String pin) async {
    final enteredPin = pin.trim();
    if (enteredPin.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('කරුණාකර PIN අංකය ඇතුලත් කරන්න'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    final isValid = await _pinService.verifyPin(enteredPin);

    if (!mounted) return;

    setState(() {
      _isLoading = false;
    });

    if (isValid) {
      Navigator.pushReplacement(
        context,
        SlideFadePageRoute(page: const DashboardScreen()),
      );
    } else {
      _pinController.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('වැරදි PIN අංකයකි'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Image.asset(
                          'assets/images/logo.png',
                          height: 110,
                          width: 110,
                          fit: BoxFit.cover,
                        ),
                      ),
                    )
                    .animate()
                    .fade(duration: 600.ms)
                    .slideY(begin: 0.3, curve: Curves.easeOutCubic),
                const SizedBox(height: 16),
                const Text(
                      'WARUNA TRANSPORT',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: AppColors.secondaryColor,
                        letterSpacing: 1.2,
                      ),
                    )
                    .animate()
                    .fade(delay: 150.ms, duration: 600.ms)
                    .slideY(begin: 0.3, curve: Curves.easeOutCubic),
                const SizedBox(height: 8),
                Text(
                      'ඇතුල් වන්න',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.notoSansSinhala(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: AppColors.secondaryColor,
                      ),
                    )
                    .animate()
                    .fade(delay: 300.ms, duration: 600.ms)
                    .slideY(begin: 0.3, curve: Curves.easeOutCubic),
                const SizedBox(height: 36),
                TextFormField(
                      controller: _pinController,
                      obscureText: true,
                      keyboardType: TextInputType.number,
                      maxLength: 4,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 28,
                        letterSpacing: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      decoration: InputDecoration(
                        labelText: 'PIN අංකය ඇතුලත් කරන්න',
                        counterText: '',
                        prefixIcon: const Icon(Icons.lock_outline),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: AppColors.primaryColor,
                            width: 2,
                          ),
                        ),
                      ),
                      onChanged: (value) {
                        if (value.length == 4) {
                          _submitPin(value);
                        }
                      },
                      onFieldSubmitted: (value) => _submitPin(value),
                    )
                    .animate()
                    .fade(delay: 450.ms, duration: 600.ms)
                    .slideY(begin: 0.3, curve: Curves.easeOutCubic),
                const SizedBox(height: 24),
                ElevatedButton(
                      onPressed: _isLoading
                          ? null
                          : () => _submitPin(_pinController.text),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 2,
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Text(
                              'ලොග් වෙන්න',
                              style: GoogleFonts.notoSansSinhala(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    )
                    .animate()
                    .fade(delay: 600.ms, duration: 600.ms)
                    .slideY(begin: 0.3, curve: Curves.easeOutCubic)
                    .scale(
                      delay: 600.ms,
                      duration: 400.ms,
                      curve: Curves.easeOutBack,
                    ),
                const SizedBox(height: 16),
                Text(
                  'පෙරනිමි PIN අංකය: 0000',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                ).animate().fade(delay: 750.ms, duration: 600.ms),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
