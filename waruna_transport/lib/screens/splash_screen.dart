import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/app_colors.dart';
import 'login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  // Particle data for sand/stones unloading
  final List<_ParticleData> _particles = const [
    _ParticleData(
      x: -35,
      startY: 10,
      fallDistance: 280,
      size: 8,
      color: Color(0xFFE9C46A),
      rotation: 0.5,
    ),
    _ParticleData(
      x: -25,
      startY: 15,
      fallDistance: 320,
      size: 10,
      color: Color(0xFFD4A373),
      rotation: -0.8,
    ),
    _ParticleData(
      x: -15,
      startY: 8,
      fallDistance: 260,
      size: 6,
      color: Color(0xFFF4A261),
      rotation: 1.2,
    ),
    _ParticleData(
      x: -5,
      startY: 20,
      fallDistance: 350,
      size: 12,
      color: Color(0xFF6C757D),
      rotation: -0.4,
    ),
    _ParticleData(
      x: 5,
      startY: 12,
      fallDistance: 300,
      size: 7,
      color: Color(0xFF495057),
      rotation: 0.9,
    ),
    _ParticleData(
      x: 15,
      startY: 18,
      fallDistance: 340,
      size: 11,
      color: Color(0xFFADB5BD),
      rotation: -1.1,
    ),
    _ParticleData(
      x: 25,
      startY: 10,
      fallDistance: 290,
      size: 8,
      color: Color(0xFF8D5B4C),
      rotation: 0.3,
    ),
    _ParticleData(
      x: -30,
      startY: 25,
      fallDistance: 360,
      size: 9,
      color: Color(0xFFE76F51),
      rotation: -0.7,
    ),
    _ParticleData(
      x: -10,
      startY: 22,
      fallDistance: 310,
      size: 10,
      color: Color(0xFF343A40),
      rotation: 0.6,
    ),
    _ParticleData(
      x: 10,
      startY: 28,
      fallDistance: 380,
      size: 12,
      color: Color(0xFFDDA15E),
      rotation: -0.5,
    ),
    _ParticleData(
      x: -45,
      startY: 5,
      fallDistance: 270,
      size: 7,
      color: Color(0xFFD4A373),
      rotation: 1.0,
    ),
    _ParticleData(
      x: -20,
      startY: 30,
      fallDistance: 330,
      size: 11,
      color: Color(0xFF6C757D),
      rotation: -1.3,
    ),
    _ParticleData(
      x: 0,
      startY: 16,
      fallDistance: 300,
      size: 9,
      color: Color(0xFFE9C46A),
      rotation: 0.4,
    ),
    _ParticleData(
      x: 20,
      startY: 24,
      fallDistance: 350,
      size: 8,
      color: Color(0xFF495057),
      rotation: -0.9,
    ),
    _ParticleData(
      x: -40,
      startY: 18,
      fallDistance: 310,
      size: 10,
      color: Color(0xFFF4A261),
      rotation: 0.8,
    ),
    _ParticleData(
      x: 30,
      startY: 14,
      fallDistance: 280,
      size: 6,
      color: Color(0xFF8D5B4C),
      rotation: -0.6,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    );

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                const LoginScreen(),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
                  return FadeTransition(opacity: animation, child: child);
                },
            transitionDuration: const Duration(milliseconds: 800),
          ),
        );
      }
    });

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: AppColors.secondaryColor,
      body: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          final t = _controller.value; // 0.0 to 1.0 over 5.0 seconds

          // 1. (0s - 1.5s): Slide in from Left to Center (t: 0.0 to 0.30)
          // 5. (3.5s - 5.0s): Drive off-screen to Right (t: 0.70 to 1.0)
          double truckX = 0.0;
          if (t <= 0.30) {
            final p1 = (t / 0.30).clamp(0.0, 1.0);
            truckX = Tween<double>(
              begin: -screenSize.width - 150,
              end: 0.0,
            ).transform(Curves.easeOutCubic.transform(p1));
          } else if (t >= 0.70) {
            final p5 = ((t - 0.70) / 0.30).clamp(0.0, 1.0);
            truckX = Tween<double>(
              begin: 0.0,
              end: screenSize.width + 150,
            ).transform(Curves.easeInCubic.transform(p5));
          }

          // 2. (1.5s - 2.5s): Rotate/tilt backwards by -30 deg (t: 0.30 to 0.50)
          // 4. (3.0s - 3.5s): Level out back to 0 deg (t: 0.60 to 0.70)
          const targetAngle = -30 * math.pi / 180;
          double truckAngle = 0.0;
          if (t > 0.30 && t <= 0.50) {
            final p2 = ((t - 0.30) / 0.20).clamp(0.0, 1.0);
            truckAngle = Tween<double>(
              begin: 0.0,
              end: targetAngle,
            ).transform(Curves.easeInOut.transform(p2));
          } else if (t > 0.50 && t <= 0.60) {
            truckAngle = targetAngle;
          } else if (t > 0.60 && t <= 0.70) {
            final p4 = ((t - 0.60) / 0.10).clamp(0.0, 1.0);
            truckAngle = Tween<double>(
              begin: targetAngle,
              end: 0.0,
            ).transform(Curves.easeInOut.transform(p4));
          }

          // 3. (2.0s - 3.0s): Sand/stones fall and fade out (t: 0.40 to 0.60)
          final showParticles = t >= 0.40 && t <= 0.60;
          final particleProgress = showParticles
              ? ((t - 0.40) / 0.20).clamp(0.0, 1.0)
              : 0.0;

          // Branding opacity (fade in while truck is in center, fade out near end)
          double brandOpacity = 0.0;
          if (t >= 0.15 && t <= 0.75) {
            if (t < 0.30) {
              brandOpacity = ((t - 0.15) / 0.15).clamp(0.0, 1.0);
            } else if (t > 0.65) {
              brandOpacity = (1.0 - ((t - 0.65) / 0.10)).clamp(0.0, 1.0);
            } else {
              brandOpacity = 1.0;
            }
          }

          return Stack(
            alignment: Alignment.center,
            children: [
              // Background subtle road / horizon line
              Positioned(
                bottom: screenSize.height * 0.42,
                left: 0,
                right: 0,
                child: Container(
                  height: 3,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.transparent,
                        AppColors.primaryColor.withValues(alpha: 0.4),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),

              // Falling sand/stone particles
              if (showParticles)
                ..._particles.map((p) {
                  final currentY =
                      p.startY +
                      (p.fallDistance * (particleProgress * particleProgress));
                  final currentOpacity = (1.0 - particleProgress).clamp(
                    0.0,
                    1.0,
                  );

                  return Positioned(
                    top: (screenSize.height / 2) + currentY,
                    left: (screenSize.width / 2) + p.x,
                    child: Opacity(
                      opacity: currentOpacity,
                      child: Transform.rotate(
                        angle: p.rotation * particleProgress * 4,
                        child: Container(
                          width: p.size,
                          height: p.size,
                          decoration: BoxDecoration(
                            color: p.color,
                            borderRadius: BorderRadius.circular(2),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.2),
                                blurRadius: 2,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                }),

              // Animated Truck
              Transform.translate(
                offset: Offset(truckX, 0),
                child: Transform.rotate(
                  angle: truckAngle,
                  alignment:
                      Alignment.bottomRight, // Tilt backwards like a dump truck
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Image.asset(
                      'assets/images/logo.png',
                      height: 150,
                      width: 150,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),

              // Business Name & Sinhala text
              Positioned(
                bottom: screenSize.height * 0.18,
                child: Opacity(
                  opacity: brandOpacity,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'WARUNA TRANSPORT',
                        style: TextStyle(
                          color: AppColors.primaryColor,
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2.0,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'වරුණ ට්‍රාන්ස්පෝර්ට්',
                        style: GoogleFonts.notoSansSinhala(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _ParticleData {
  final double x;
  final double startY;
  final double fallDistance;
  final double size;
  final Color color;
  final double rotation;

  const _ParticleData({
    required this.x,
    required this.startY,
    required this.fallDistance,
    required this.size,
    required this.color,
    required this.rotation,
  });
}
