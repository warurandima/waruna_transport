import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../utils/app_colors.dart';

class PixelTruckAnimation extends StatefulWidget {
  const PixelTruckAnimation({super.key});

  @override
  State<PixelTruckAnimation> createState() => _PixelTruckAnimationState();
}

class _PixelTruckAnimationState extends State<PixelTruckAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _bedAngleAnimation;

  // Particle offsets and colors
  final List<_PixelParticle> _particles = const [
    _PixelParticle(dx: -12, dy: 8, color: Color(0xFFF1C40F), size: 10),
    _PixelParticle(dx: -20, dy: 14, color: Color(0xFFF39C12), size: 8),
    _PixelParticle(dx: -8, dy: 22, color: Color(0xFFE67E22), size: 9),
    _PixelParticle(dx: -28, dy: 6, color: Color(0xFFBDC3C7), size: 7),
    _PixelParticle(dx: -16, dy: 18, color: Color(0xFF95A5A6), size: 11),
    _PixelParticle(dx: -24, dy: 26, color: Color(0xFFF1C40F), size: 8),
    _PixelParticle(dx: -4, dy: 16, color: Color(0xFF7F8C8D), size: 10),
    _PixelParticle(dx: -32, dy: 20, color: Color(0xFFD35400), size: 9),
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    );

    // 1. (0.0 - 0.3): Slide in from Offset(-1.5, 0) to Offset(0, 0)
    // 5. (0.8 - 1.0): Slide out to Offset(1.5, 0)
    _slideAnimation = TweenSequence<Offset>([
      TweenSequenceItem(
        tween: Tween<Offset>(
          begin: const Offset(-1.5, 0.0),
          end: Offset.zero,
        ).chain(CurveTween(curve: Curves.easeOutCubic)),
        weight: 30,
      ),
      TweenSequenceItem(tween: ConstantTween<Offset>(Offset.zero), weight: 50),
      TweenSequenceItem(
        tween: Tween<Offset>(
          begin: Offset.zero,
          end: const Offset(1.5, 0.0),
        ).chain(CurveTween(curve: Curves.easeInCubic)),
        weight: 20,
      ),
    ]).animate(_controller);

    // 2. (0.3 - 0.5): Tipper bed rotates up by -40 degrees (-40 * pi / 180)
    // 4. (0.7 - 0.8): Tipper bed rotates back to 0 degrees
    _bedAngleAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: ConstantTween<double>(0.0), weight: 30),
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 0.0,
          end: -40 * math.pi / 180,
        ).chain(CurveTween(curve: Curves.easeInOut)),
        weight: 20,
      ),
      TweenSequenceItem(
        tween: ConstantTween<double>(-40 * math.pi / 180),
        weight: 20,
      ),
      TweenSequenceItem(
        tween: Tween<double>(
          begin: -40 * math.pi / 180,
          end: 0.0,
        ).chain(CurveTween(curve: Curves.easeInOut)),
        weight: 10,
      ),
      TweenSequenceItem(tween: ConstantTween<double>(0.0), weight: 20),
    ]).animate(_controller);

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final t = _controller.value;

        // Calculate wheel rotation
        double wheelAngle = 0.0;
        if (t <= 0.3) {
          wheelAngle = (t / 0.3) * 6 * math.pi;
        } else if (t >= 0.8) {
          wheelAngle = ((t - 0.8) / 0.2) * 6 * math.pi;
        }

        // 3. (0.4 - 0.7): Sand particles falling
        final showParticles = t >= 0.4 && t <= 0.7;
        final particleProgress = showParticles
            ? ((t - 0.4) / 0.3).clamp(0.0, 1.0)
            : 0.0;

        return SlideTransition(
          position: _slideAnimation,
          child: SizedBox(
            width: 220,
            height: 160,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                // Ground road line (retro 8-bit dashed curb)
                Positioned(
                  bottom: 12,
                  left: -40,
                  right: -40,
                  child: Row(
                    children: List.generate(
                      15,
                      (i) => Container(
                        width: 14,
                        height: 3,
                        margin: const EdgeInsets.symmetric(horizontal: 3),
                        color: Colors.white.withValues(alpha: 0.25),
                      ),
                    ),
                  ),
                ),

                // Sand particles falling from tipper rear during 0.4 - 0.7
                if (showParticles)
                  ..._particles.map((p) {
                    final currentX = 20.0 + p.dx - (particleProgress * 35);
                    final currentY =
                        55.0 +
                        p.dy +
                        (particleProgress * particleProgress * 85);
                    final opacity = (1.0 - particleProgress).clamp(0.0, 1.0);

                    return Positioned(
                      left: currentX,
                      top: currentY,
                      child: Opacity(
                        opacity: opacity,
                        child: Container(
                          width: p.size,
                          height: p.size,
                          decoration: BoxDecoration(
                            color: p.color,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.3),
                                blurRadius: 1,
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),

                // Pixel Tipper Bed (Rotating)
                Positioned(
                  left: 20,
                  bottom: 30,
                  child: Transform.rotate(
                    angle: _bedAngleAnimation.value,
                    alignment: Alignment.bottomLeft, // Hinge at rear bottom
                    child: _buildPixelTipperBed(showSand: t < 0.55),
                  ),
                ),

                // Pixel Truck Cabin & Chassis
                Positioned(
                  left: 20,
                  bottom: 22,
                  child: _buildPixelCabinAndChassis(),
                ),

                // Rear Wheel (Pixel style)
                Positioned(
                  left: 45,
                  bottom: 12,
                  child: _buildPixelWheel(wheelAngle),
                ),

                // Front Wheel (Pixel style)
                Positioned(
                  left: 142,
                  bottom: 12,
                  child: _buildPixelWheel(wheelAngle),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // 8-bit Tipper Bed Widget
  Widget _buildPixelTipperBed({required bool showSand}) {
    return SizedBox(
      width: 95,
      height: 55,
      child: Stack(
        children: [
          // Sand heap inside bed
          if (showSand)
            Positioned(
              left: 10,
              top: 4,
              child: Container(
                width: 72,
                height: 18,
                decoration: const BoxDecoration(
                  color: Color(0xFFF1C40F),
                  border: Border(
                    top: BorderSide(color: Color(0xFFF39C12), width: 3),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Container(
                      width: 8,
                      height: 6,
                      color: const Color(0xFFE67E22),
                    ),
                    Container(
                      width: 12,
                      height: 8,
                      color: const Color(0xFFF39C12),
                    ),
                    Container(
                      width: 10,
                      height: 6,
                      color: const Color(0xFFD35400),
                    ),
                  ],
                ),
              ),
            ),

          // Tipper box main body (Turquoise Green)
          Positioned(
            left: 0,
            bottom: 0,
            child: Container(
              width: 90,
              height: 42,
              decoration: BoxDecoration(
                color: AppColors.primaryColor,
                border: Border.all(color: const Color(0xFF16A085), width: 2),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Ribbed steel slats (retro pixel stripes)
                  Container(height: 3, color: const Color(0xFF16A085)),
                  Container(height: 3, color: const Color(0xFF16A085)),
                ],
              ),
            ),
          ),

          // Cab-over protector (front vertical lip)
          Positioned(
            right: 0,
            top: 0,
            child: Container(
              width: 10,
              height: 25,
              color: const Color(0xFF16A085),
            ),
          ),

          // Tailgate (rear vertical lip)
          Positioned(
            left: 0,
            top: 10,
            child: Container(
              width: 6,
              height: 45,
              color: const Color(0xFF0E6655),
            ),
          ),
        ],
      ),
    );
  }

  // 8-bit Cabin & Chassis Widget
  Widget _buildPixelCabinAndChassis() {
    return SizedBox(
      width: 175,
      height: 75,
      child: Stack(
        children: [
          // Black Chassis rail
          Positioned(
            left: 0,
            bottom: 6,
            child: Container(
              width: 165,
              height: 8,
              color: const Color(0xFF2C3E50),
            ),
          ),

          // Exhaust stack (8-bit pipe)
          Positioned(
            left: 98,
            top: 0,
            child: Container(width: 6, height: 40, color: Colors.grey.shade400),
          ),

          // Cabin Lower Body
          Positioned(
            left: 106,
            bottom: 12,
            child: Container(
              width: 58,
              height: 34,
              decoration: BoxDecoration(
                color: AppColors.primaryColor,
                border: Border.all(color: const Color(0xFF16A085), width: 2),
              ),
              child: Row(
                children: [
                  const Spacer(),
                  // Door handle pixel
                  Container(width: 6, height: 4, color: Colors.black54),
                  const SizedBox(width: 8),
                ],
              ),
            ),
          ),

          // Cabin Upper Roof & Windshield
          Positioned(
            left: 106,
            top: 4,
            child: SizedBox(
              width: 58,
              height: 28,
              child: Stack(
                children: [
                  // Roof block
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    child: Container(height: 6, color: const Color(0xFF16A085)),
                  ),
                  // Windshield pixel glass
                  Positioned(
                    top: 6,
                    left: 6,
                    right: 6,
                    bottom: 0,
                    child: Container(
                      color: const Color(0xFF81D4FA),
                      child: Container(
                        margin: const EdgeInsets.only(top: 2, right: 3),
                        alignment: Alignment.topRight,
                        child: Container(
                          width: 4,
                          height: 4,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Front Bumper (Pixel)
          Positioned(
            right: 0,
            bottom: 6,
            child: Container(
              width: 10,
              height: 14,
              color: Colors.grey.shade500,
            ),
          ),

          // Bright Headlight
          Positioned(
            right: 2,
            bottom: 22,
            child: Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                color: Color(0xFFFFEB3B),
                boxShadow: [
                  BoxShadow(
                    color: Color(0xFFFFEB3B),
                    blurRadius: 4,
                    spreadRadius: 1,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 8-bit Pixel Wheel Widget
  Widget _buildPixelWheel(double rotationAngle) {
    return Transform.rotate(
      angle: rotationAngle,
      child: Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          color: const Color(0xFF1C2833),
          borderRadius: BorderRadius.circular(4), // Slightly blocky tire
          border: Border.all(color: Colors.black, width: 2),
        ),
        child: Center(
          child: Container(
            width: 8,
            height: 8,
            color: Colors.grey.shade300, // Wheel hub
          ),
        ),
      ),
    );
  }
}

class _PixelParticle {
  final double dx;
  final double dy;
  final Color color;
  final double size;

  const _PixelParticle({
    required this.dx,
    required this.dy,
    required this.color,
    required this.size,
  });
}
