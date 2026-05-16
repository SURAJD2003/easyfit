import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/router/route_names.dart';
import 'package:provider/provider.dart';
import '../../../../providers/auth_provider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {

  late AnimationController _backgroundController;
  late AnimationController _contentController;
  late AnimationController _glowController;
  late AnimationController _arcController;
  late AnimationController _loaderPulseController;
  late AnimationController _outerRingController;

  late Animation<double> _backgroundOpacity;
  late Animation<double> _contentOpacity;
  late Animation<double> _contentSlide;
  late Animation<double> _glowPulse;
  late Animation<double> _loaderPulse;
  late Animation<double> _outerRingScale;

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: Color(0xFF0D0600),
        systemNavigationBarIconBrightness: Brightness.light,
      ),
    );
    _initAnimations();
    _startAnimationSequence();
    _navigateAfterDelay();
  }

  void _initAnimations() {
    _backgroundController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );
    _backgroundOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
          parent: _backgroundController, curve: Curves.easeInOut),
    );

    _contentController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );
    _contentOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _contentController, curve: Curves.easeOut),
    );
    _contentSlide = Tween<double>(begin: 24.0, end: 0.0).animate(
      CurvedAnimation(
          parent: _contentController, curve: Curves.easeOutCubic),
    );

    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3200),
    )..repeat(reverse: true);
    _glowPulse = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
          parent: _glowController, curve: Curves.easeInOutCubic),
    );

    _arcController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    );

    _loaderPulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);
    _loaderPulse = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
          parent: _loaderPulseController, curve: Curves.easeInOutCubic),
    );

    _outerRingController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    )..repeat();
    _outerRingScale = Tween<double>(begin: 0.9, end: 1.3).animate(
      CurvedAnimation(
          parent: _outerRingController, curve: Curves.easeInOut),
    );
  }

  Future<void> _startAnimationSequence() async {
    await _backgroundController.forward();
    await Future.delayed(const Duration(milliseconds: 300));
    _contentController.forward();
    await Future.delayed(const Duration(milliseconds: 800));
    _arcController.forward();
  }

  Future<void> _navigateAfterDelay() async {
    // Explicitly await the auth check from SharedPreferences  
    final auth = Provider.of<AuthProvider>(context, listen: false);
    await auth.checkAuthStatus();
    // Fetch fresh profile and subscription status from server
    await auth.fetchProfile();
    await auth.fetchSubscriptionStatus();
    
    if (!mounted) return;
    
    if (auth.isAuthenticated) {
      if (auth.isApproved) {
        context.go(RouteNames.dashboard);
      } else {
        context.go(RouteNames.approvalPending);
      }
    } else {
      context.go(RouteNames.onboarding);
    }
  }

  @override
  void dispose() {
    _backgroundController.dispose();
    _contentController.dispose();
    _glowController.dispose();
    _arcController.dispose();
    _loaderPulseController.dispose();
    _outerRingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFF0D0600),
      body: AnimatedBuilder(
        animation: Listenable.merge([
          _backgroundController,
          _contentController,
          _glowController,
          _arcController,
          _loaderPulseController,
          _outerRingController,
        ]),
        builder: (context, _) {
          return Opacity(
            opacity: _backgroundOpacity.value,
            child: SizedBox(
              width: size.width,
              height: size.height,
              child: Stack(
                fit: StackFit.expand,
                children: [

                  // ── Bokeh background ──────────────────────────────
                  CustomPaint(
                      painter: _BokehPainter(glow: _glowPulse.value)),

                  // ── Bottom enhancement layer ───────────────────────
                  CustomPaint(
                    painter: _BottomEnhancementPainter(
                        loaderPulse: _loaderPulse.value,
                        outerRingScale: _outerRingScale.value),
                  ),

                  // ── Main content ──────────────────────────────────
                  SafeArea(
                    child: Transform.translate(
                      offset: Offset(0, _contentSlide.value),
                      child: Opacity(
                        opacity: _contentOpacity.value,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 28, vertical: 20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              const Spacer(),

                              // ── Clinic name (MAIN HEADLINE) ──────────────────
                              RichText(
                                textAlign: TextAlign.center,
                                text: TextSpan(
                                  children: [
                                    TextSpan(
                                      text: 'The Easy',
                                      style: GoogleFonts.playfairDisplay(
                                        fontSize: _fs(context, 40),
                                        fontStyle: FontStyle.italic,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.white,
                                        letterSpacing: 0.5,
                                        height: 1.1,
                                      ),
                                    ),
                                    TextSpan(
                                      text: 'fit',
                                      style: GoogleFonts.playfairDisplay(
                                        fontSize: _fs(context, 40),
                                        fontStyle: FontStyle.italic,
                                        fontWeight: FontWeight.w700,
                                        color: const Color(0xFFE8721A),
                                        letterSpacing: 0.5,
                                        height: 1.1,
                                      ),
                                    ),
                                    TextSpan(
                                      text: ' Clinics',
                                      style: GoogleFonts.playfairDisplay(
                                        fontSize: _fs(context, 40),
                                        fontStyle: FontStyle.italic,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.white,
                                        letterSpacing: 0.5,
                                        height: 1.1,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              const SizedBox(height: 16),

                              // ── Tagline ────────────────────────────────────
                              Text(
                                'food is the cause  |  Food is the cure',
                                textAlign: TextAlign.center,
                                style: GoogleFonts.inter(
                                  fontSize: _fs(context, 12),
                                  color: Colors.white54,
                                  fontWeight: FontWeight.w400,
                                  letterSpacing: 0.4,
                                  height: 1.6,
                                ),
                              ),

                              const SizedBox(height: 24),

                              // ── Secondary message ──────────────────────────
                              Text(
                                "You've already\nstarted.",
                                textAlign: TextAlign.center,
                                style: GoogleFonts.playfairDisplay(
                                  fontSize: _fs(context, 28),
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                  height: 1.15,
                                  letterSpacing: -0.3,
                                ),
                              ),

                              const SizedBox(height: 6),

                              Text(
                                'Just continue.',
                                textAlign: TextAlign.center,
                                style: GoogleFonts.playfairDisplay(
                                  fontSize: _fs(context, 28),
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFFE8721A),
                                  height: 1.15,
                                  letterSpacing: -0.3,
                                ),
                              ),

                              const Spacer(flex: 2),

                              // ── Enhanced loader section ───────────────────
                              Stack(
                                alignment: Alignment.center,
                                children: [
                                  // Animated outer ring glow
                                  Transform.scale(
                                    scale: _outerRingScale.value,
                                    child: Container(
                                      width: 64,
                                      height: 64,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        boxShadow: [
                                          BoxShadow(
                                            color: const Color(0xFFE8721A)
                                                .withOpacity(0.15),
                                            blurRadius: 24,
                                            spreadRadius: 8,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  // Main loader with pulse
                                  Transform.scale(
                                    scale: _loaderPulse.value,
                                    child: Container(
                                      width: 52,
                                      height: 52,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        boxShadow: [
                                          BoxShadow(
                                            color: const Color(0xFFE8721A)
                                                .withOpacity(
                                                    0.4 * _glowPulse.value),
                                            blurRadius: 20,
                                            spreadRadius: 2,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  // Arc progress
                                  SizedBox(
                                    width: 44,
                                    height: 44,
                                    child: CustomPaint(
                                      painter: _ArcPainter(
                                          progress: _arcController.value),
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 28),

                              // ── Engaging loading text ──────────────────────
                              Text(
                                'Preparing your personalized\nhealth experience...',
                                textAlign: TextAlign.center,
                                style: GoogleFonts.inter(
                                  fontSize: _fs(context, 12),
                                  color: Colors.white30,
                                  fontWeight: FontWeight.w400,
                                  letterSpacing: 0.3,
                                  height: 1.5,
                                ),
                              ),

                              const SizedBox(height: 24),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  double _fs(BuildContext context, double base) {
    final w = MediaQuery.of(context).size.width;
    if (w < 360) return base * 0.88;
    if (w > 600) return base * 1.12;
    return base;
  }
}

// ── Bokeh background painter ──────────────────────────────────────────────
class _BokehPainter extends CustomPainter {
  final double glow;
  _BokehPainter({required this.glow});

  @override
  void paint(Canvas canvas, Size size) {
    final bg = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFF0D0600), Color(0xFF1C0A00), Color(0xFF0D0600)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        stops: [0.0, 0.5, 1.0],
      ).createShader(Offset.zero & size);
    canvas.drawRect(Offset.zero & size, bg);

    _glow(canvas, Offset(size.width * 0.9, size.height * 0.08),
        size.width * 0.6, const Color(0x28FF6B2B));

    _glow(canvas, Offset(size.width * 0.12, size.height * 0.06),
        size.width * 0.32, const Color(0x14FF8040));

    _glow(canvas, Offset(size.width * 0.5, size.height * 0.73),
        size.width * 0.38 * glow, const Color(0x1EE8721A));

    _glow(canvas, Offset(size.width * 0.5, size.height * 0.735),
        size.width * 0.08, Color((0x40FF9040 * glow).toInt()));

    final dots = [
      (0.80, 0.11, 16.0, 0x35FF7020),
      (0.88, 0.20, 10.0, 0x25FF8030),
      (0.95, 0.09,  7.0, 0x20FFA050),
      (0.65, 0.07, 12.0, 0x28FF6B2B),
      (0.08, 0.18,  9.0, 0x18FF7A30),
      (0.25, 0.12,  6.0, 0x15FF9040),
      (0.42, 0.66, 14.0, 0x20E8721A),
      (0.30, 0.72,  8.0, 0x18FF8030),
      (0.68, 0.69, 10.0, 0x22FF7020),
    ];
    for (final d in dots) {
      _glow(
        canvas,
        Offset(size.width * d.$1, size.height * d.$2),
        d.$3,
        Color(d.$4),
      );
    }

    // ── Bottom gradient enhancement ────────────────────────────
    final bottomGradient = Paint()
      ..shader = LinearGradient(
        colors: [
          const Color(0xFF0D0600).withOpacity(0),
          const Color(0xFFE8721A).withOpacity(0.08),
        ],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        stops: const [0.0, 1.0],
      ).createShader(
        Rect.fromLTWH(0, size.height * 0.75, size.width, size.height * 0.25),
      );
    canvas.drawRect(
      Rect.fromLTWH(0, size.height * 0.75, size.width, size.height * 0.25),
      bottomGradient,
    );
  }

  void _glow(Canvas canvas, Offset center, double radius, Color color) {
    final paint = Paint()
      ..shader = RadialGradient(
        colors: [color, color.withOpacity(0)],
      ).createShader(Rect.fromCircle(center: center, radius: radius))
      ..blendMode = BlendMode.plus;
    canvas.drawCircle(center, radius, paint);
  }

  @override
  bool shouldRepaint(_BokehPainter o) => o.glow != glow;
}

// ── Arc progress painter ──────────────────────────────────────────────────
class _ArcPainter extends CustomPainter {
  final double progress;
  _ArcPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    final r = math.min(size.width, size.height) / 2 - 2;

    canvas.drawCircle(
      c,
      r,
      Paint()
        ..color = Colors.white12
        ..strokeWidth = 1.5
        ..style = PaintingStyle.stroke,
    );

    canvas.drawArc(
      Rect.fromCircle(center: c, radius: r),
      -math.pi / 2,
      2 * math.pi * progress,
      false,
      Paint()
        ..color = const Color(0xFFE8721A)
        ..strokeWidth = 1.8
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(_ArcPainter o) => o.progress != progress;
}

// ── Bottom enhancement painter ────────────────────────────────────────────
class _BottomEnhancementPainter extends CustomPainter {
  final double loaderPulse;
  final double outerRingScale;

  _BottomEnhancementPainter({required this.loaderPulse, required this.outerRingScale});

  @override
  void paint(Canvas canvas, Size size) {
    // ── Blurred circular light effect behind loader ──────────────────
    final loaderGlowCenter = Offset(size.width / 2, size.height * 0.72);
    final blurGlow = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFFE8721A).withOpacity(0.2 * loaderPulse),
          const Color(0xFFE8721A).withOpacity(0),
        ],
      ).createShader(Rect.fromCircle(center: loaderGlowCenter, radius: size.width * 0.35))
      ..blendMode = BlendMode.screen;
    canvas.drawCircle(
      loaderGlowCenter,
      size.width * 0.35,
      blurGlow,
    );

    // ── Subtle wave pattern near bottom ────────────────────────────
    _drawWavePattern(canvas, size);

    // ── Light particle cluster animation ──────────────────────────
    _drawParticleCluster(canvas, size);
  }

  void _drawWavePattern(Canvas canvas, Size size) {
    final wavePaint = Paint()
      ..color = const Color(0xFFE8721A).withOpacity(0.04)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    final bottomY = size.height * 0.88;
    final waveAmplitude = 6.0;
    final waveFrequency = 0.015;
    const waveLength = 60.0;

    final path = Path();
    path.moveTo(0, bottomY);

    for (double x = 0; x <= size.width; x += 2) {
      final y = bottomY + math.sin(x * waveFrequency) * waveAmplitude;
      path.lineTo(x, y);
    }

    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    canvas.drawPath(path, wavePaint);
  }

  void _drawParticleCluster(Canvas canvas, Size size) {
    final particlePoints = [
      (0.3, 0.82, 1.5),
      (0.45, 0.85, 1.0),
      (0.55, 0.88, 0.8),
      (0.7, 0.84, 1.2),
      (0.25, 0.88, 0.9),
      (0.75, 0.87, 1.1),
      (0.5, 0.92, 0.7),
    ];

    for (final particle in particlePoints) {
      final x = size.width * particle.$1;
      final y = size.height * particle.$2;
      final radius = particle.$3;

      final particlePaint = Paint()
        ..color = const Color(0xFFE8721A).withOpacity(0.15 * loaderPulse)
        ..blendMode = BlendMode.screen;

      canvas.drawCircle(Offset(x, y), radius, particlePaint);

      // Subtle glow around each particle
      final glowPaint = Paint()
        ..shader = RadialGradient(
          colors: [
            const Color(0xFFE8721A).withOpacity(0.08 * loaderPulse),
            const Color(0xFFE8721A).withOpacity(0),
          ],
        ).createShader(Rect.fromCircle(center: Offset(x, y), radius: radius * 3))
        ..blendMode = BlendMode.screen;

      canvas.drawCircle(Offset(x, y), radius * 3, glowPaint);
    }
  }

  @override
  bool shouldRepaint(_BottomEnhancementPainter o) =>
      o.loaderPulse != loaderPulse || o.outerRingScale != outerRingScale;
}