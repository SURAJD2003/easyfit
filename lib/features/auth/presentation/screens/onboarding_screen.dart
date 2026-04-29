import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'dart:ui';
import 'dart:math' as math;
import '../../../../core/router/route_names.dart';

class OnboardingScreen extends StatefulWidget {
  final VoidCallback? onComplete;

  const OnboardingScreen({
    super.key,
    this.onComplete,
  });

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with TickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  late AnimationController _glowController;
  late AnimationController _particleController;
  late AnimationController _contentController;
  late AnimationController _floatController;
  late AnimationController _progressController;

  late Animation<double> _glowPulse;
  late Animation<double> _particleAnim;
  late Animation<double> _contentFade;
  late Animation<double> _contentSlide;
  late Animation<double> _floatAnim;
  late Animation<double> _progressAnim;

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
    );
    _initControllers();
  }

  void _initControllers() {
    // Glow pulse
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    )..repeat(reverse: true);
    _glowPulse = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOutCubic),
    );

    // Particles animation
    _particleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 4000),
    )..repeat();
    _particleAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      _particleController,
    );

    // Content transition
    _contentController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _contentFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _contentController,
        curve: const Interval(0.0, 0.7, curve: Curves.easeIn),
      ),
    );
    _contentSlide = Tween<double>(begin: 40.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _contentController,
        curve: Curves.easeOutCubic,
      ),
    );
    _contentController.forward();

    // Float animation
    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat(reverse: true);
    _floatAnim = Tween<double>(begin: -6.0, end: 6.0).animate(
      CurvedAnimation(parent: _floatController, curve: Curves.easeInOut),
    );

    // Progress ring animation
    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    )..repeat(reverse: true);
    _progressAnim = Tween<double>(begin: 0.6, end: 0.75).animate(
      CurvedAnimation(parent: _progressController, curve: Curves.easeInOut),
    );
  }

  void _onPageChanged(int index) {
    setState(() => _currentPage = index);
    _contentController.reset();
    _contentController.forward();
  }

  Future<void> _onButtonTap() async {
    if (_currentPage < 3) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOutCubic,
      );
    } else {
      // Last page — call onComplete or navigate
      if (widget.onComplete != null) {
        widget.onComplete!.call();
      } else if (mounted) {
        context.go(RouteNames.login);
      }
    }
  }

  void _skip() {
    if (widget.onComplete != null) {
      widget.onComplete!.call();
    } else if (mounted) {
      context.go(RouteNames.login);
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    _glowController.dispose();
    _particleController.dispose();
    _contentController.dispose();
    _floatController.dispose();
    _progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
      body: Stack(
        children: [
          // ── PAGES ────────────────────────────────
          AnimatedBuilder(
            animation: Listenable.merge([
              _glowController,
              _particleController,
              _contentController,
              _floatController,
              _progressController,
            ]),
            builder: (context, _) {
              return PageView(
                controller: _pageController,
                onPageChanged: _onPageChanged,
                children: [
                  _Screen1(
                    glowPulse: _glowPulse.value,
                    particleAnim: _particleAnim.value,
                    contentFade: _contentFade.value,
                    contentSlide: _contentSlide.value,
                    floatAnim: _floatAnim.value,
                    size: size,
                  ),
                  _Screen2(
                    glowPulse: _glowPulse.value,
                    contentFade: _contentFade.value,
                    contentSlide: _contentSlide.value,
                    floatAnim: _floatAnim.value,
                    size: size,
                  ),
                  _Screen3(
                    glowPulse: _glowPulse.value,
                    contentFade: _contentFade.value,
                    contentSlide: _contentSlide.value,
                    floatAnim: _floatAnim.value,
                    progressAnim: _progressAnim.value,
                    size: size,
                  ),
                  _Screen4(
                    glowPulse: _glowPulse.value,
                    contentFade: _contentFade.value,
                    contentSlide: _contentSlide.value,
                    floatAnim: _floatAnim.value,
                    size: size,
                  ),
                ],
              );
            },
          ),

          // ── SKIP BUTTON ──────────────────────────
          Positioned(
            top: MediaQuery.of(context).padding.top + 20,
            right: 28,
            child: GestureDetector(
              onTap: _skip,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.12),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      'Skip',
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        color: Colors.white.withOpacity(0.7),
                        fontWeight: FontWeight.w400,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),

          // ── BOTTOM CONTROLS ──────────────────────
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: _buildBottomControls(),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomControls() {
    return Container(
      padding: const EdgeInsets.fromLTRB(28, 24, 28, 54),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.transparent,
            const Color(0xFF0D0D0D).withOpacity(0.95),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // CTA Button
          GestureDetector(
            onTap: _onButtonTap,
            child: Container(
              height: 56,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(28),
                gradient: const LinearGradient(
                  colors: [Color(0xFFFF7A00), Color(0xFFFF9A3C)],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                boxShadow: [
                  // Outer glow halo
                  BoxShadow(
                    color: const Color(0xFFFF7A00).withOpacity(0.15),
                    blurRadius: 48,
                    spreadRadius: 8,
                  ),
                  // Mid glow layer
                  BoxShadow(
                    color: const Color(0xFFFF7A00).withOpacity(0.25),
                    blurRadius: 32,
                    offset: const Offset(0, 12),
                  ),
                  // Core shadow
                  BoxShadow(
                    color: const Color(0xFFFF7A00).withOpacity(0.4),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  // Shine
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      height: 28,
                      decoration: BoxDecoration(
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(28),
                        ),
                        gradient: LinearGradient(
                          colors: [
                            Colors.white.withOpacity(0.2),
                            Colors.transparent,
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                    ),
                  ),
                  // Text
                  Center(
                    child: Text(
                      _currentPage == 3 ? 'Get Started' : 'Next',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 32),

          // Dot indicators
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(4, (i) {
              final isActive = i == _currentPage;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 400),
                curve: Curves.easeInOutCubic,
                margin: const EdgeInsets.symmetric(horizontal: 5),
                width: isActive ? 28 : 8,
                height: 8,
                decoration: BoxDecoration(
                  color: isActive
                      ? const Color(0xFFFF7A00)
                      : Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(4),
                  boxShadow: isActive
                      ? [
                          BoxShadow(
                            color: const Color(0xFFFF7A00)
                                .withOpacity(0.5),
                            blurRadius: 12,
                            spreadRadius: 1,
                          ),
                        ]
                      : null,
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// SCREEN 1: TRACK EVERY STEP YOU TAKE
// ═══════════════════════════════════════════════════════════════
class _Screen1 extends StatelessWidget {
  final double glowPulse, particleAnim, contentFade, contentSlide, floatAnim;
  final Size size;

  const _Screen1({
    required this.glowPulse,
    required this.particleAnim,
    required this.contentFade,
    required this.contentSlide,
    required this.floatAnim,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Background gradient
        Container(
          decoration: const BoxDecoration(
            gradient: RadialGradient(
              center: Alignment(0, -0.3),
              radius: 1.3,
              colors: [Color(0xFF1A0A00), Color(0xFF0D0D0D)],
            ),
          ),
        ),

        // Animated path visualization
        Positioned.fill(
          child: IgnorePointer(
            child: CustomPaint(
              painter: _AnimatedPathPainter(progress: particleAnim),
            ),
          ),
        ),

        // Glow overlay
        Positioned.fill(
          child: IgnorePointer(
            child: Opacity(
              opacity: 0.08 * glowPulse,
              child: Container(
                decoration: const BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment(0, -0.2),
                    radius: 0.8,
                    colors: [Color(0xFFFF7A00), Colors.transparent],
                  ),
                ),
              ),
            ),
          ),
        ),

        // Particle field
        Positioned.fill(
          child: IgnorePointer(
            child: CustomPaint(
              painter: _ParticlePainter(progress: particleAnim, seed: 7),
            ),
          ),
        ),

        // Vignette
        Positioned.fill(
          child: IgnorePointer(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  radius: 1.2,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.4),
                  ],
                ),
              ),
            ),
          ),
        ),

        // Content
        Positioned(
          bottom: 160,
          left: 32,
          right: 32,
          child: Opacity(
            opacity: contentFade,
            child: Transform.translate(
              offset: Offset(0, contentSlide),
              child: Column(
                children: [
                  _GradientTitle('Track ', 'Every', '\nStep You Take'),
                  const SizedBox(height: 16),
                  _Subtitle('Visualize your daily movement as a journey of wellness'),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// SCREEN 2: ALL YOUR FITNESS DATA IN ONE PLACE
// ═══════════════════════════════════════════════════════════════
class _Screen2 extends StatelessWidget {
  final double glowPulse, contentFade, contentSlide, floatAnim;
  final Size size;

  const _Screen2({
    required this.glowPulse,
    required this.contentFade,
    required this.contentSlide,
    required this.floatAnim,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Background
        Container(
          decoration: const BoxDecoration(
            gradient: RadialGradient(
              center: Alignment(0, -0.1),
              radius: 1.3,
              colors: [Color(0xFF1A0F00), Color(0xFF0D0D0D)],
            ),
          ),
        ),

        // Data cards
        Positioned(
          top: size.height * 0.08,
          left: 28,
          right: 28,
          child: Transform.translate(
            offset: Offset(0, floatAnim * 2),
            child: Column(
              children: [
                _DataCard(
                  icon: Icons.directions_walk,
                  label: 'Steps',
                  value: '10,350',
                  unit: 'today',
                  glowPulse: glowPulse,
                ),
                const SizedBox(height: 12),
                _DataCard(
                  icon: Icons.local_fire_department,
                  label: 'Calories',
                  value: '325',
                  unit: 'burned',
                  glowPulse: glowPulse,
                ),
                const SizedBox(height: 12),
                _DataCard(
                  icon: Icons.route,
                  label: 'Distance',
                  value: '2.54',
                  unit: 'km',
                  glowPulse: glowPulse,
                ),
              ],
            ),
          ),
        ),

        // Glow
        Positioned.fill(
          child: IgnorePointer(
            child: Opacity(
              opacity: 0.1 * glowPulse,
              child: Container(
                decoration: const BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment(0, 0.3),
                    radius: 0.8,
                    colors: [Color(0xFFFF7A00), Colors.transparent],
                  ),
                ),
              ),
            ),
          ),
        ),

        // Vignette
        Positioned.fill(
          child: IgnorePointer(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  radius: 1.2,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.4),
                  ],
                ),
              ),
            ),
          ),
        ),

        // Content
        Positioned(
          bottom: 160,
          left: 32,
          right: 32,
          child: Opacity(
            opacity: contentFade,
            child: Transform.translate(
              offset: Offset(0, contentSlide),
              child: Column(
                children: [
                  _GradientTitle('All Your ', 'Fitness', '\nData in One Place'),
                  const SizedBox(height: 14),
                  _Subtitle('Steps, calories, distance & heart rate beautifully tracked'),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// SCREEN 3: SET GOALS. ACHIEVE MORE.
// ═══════════════════════════════════════════════════════════════
class _Screen3 extends StatelessWidget {
  final double glowPulse, contentFade, contentSlide, floatAnim, progressAnim;
  final Size size;

  const _Screen3({
    required this.glowPulse,
    required this.contentFade,
    required this.contentSlide,
    required this.floatAnim,
    required this.progressAnim,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Background
        Container(
          decoration: const BoxDecoration(
            gradient: RadialGradient(
              center: Alignment(0, 0.1),
              radius: 1.3,
              colors: [Color(0xFF1A0A00), Color(0xFF0D0D0D)],
            ),
          ),
        ),

        // Progress ring
        Positioned(
          top: size.height * 0.12,
          left: 0,
          right: 0,
          child: Transform.translate(
            offset: Offset(0, floatAnim * 2),
            child: Center(
              child: SizedBox(
                width: 160,
                height: 160,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Glow
                    Container(
                      width: 180,
                      height: 180,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFFF7A00)
                                .withOpacity(0.3 * glowPulse),
                            blurRadius: 36,
                            spreadRadius: 8,
                          ),
                        ],
                      ),
                    ),
                    // Ring
                    CustomPaint(
                      painter: _ProgressRingPainter(
                        progress: progressAnim,
                        glowPulse: glowPulse,
                      ),
                      size: const Size(160, 160),
                    ),
                    // Center text
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '${(progressAnim * 100).toStringAsFixed(0)}%',
                          style: GoogleFonts.poppins(
                            fontSize: 32,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Weekly Goal',
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            fontWeight: FontWeight.w400,
                            color: Colors.white54,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),

        // Glow
        Positioned.fill(
          child: IgnorePointer(
            child: Opacity(
              opacity: 0.12 * glowPulse,
              child: Container(
                decoration: const BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment(0, 0),
                    radius: 0.9,
                    colors: [Color(0xFFFF7A00), Colors.transparent],
                  ),
                ),
              ),
            ),
          ),
        ),

        // Vignette
        Positioned.fill(
          child: IgnorePointer(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  radius: 1.2,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.4),
                  ],
                ),
              ),
            ),
          ),
        ),

        // Content
        Positioned(
          bottom: 160,
          left: 32,
          right: 32,
          child: Opacity(
            opacity: contentFade,
            child: Transform.translate(
              offset: Offset(0, contentSlide),
              child: Column(
                children: [
                  Text(
                    'Set Goals.',
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 34,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      letterSpacing: -0.3,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  ShaderMask(
                    shaderCallback: (bounds) => const LinearGradient(
                      colors: [Color(0xFFFF7A00), Color(0xFFFFB347)],
                    ).createShader(bounds),
                    child: Text(
                      'Achieve More.',
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 34,
                        fontWeight: FontWeight.w700,
                        fontStyle: FontStyle.italic,
                        color: Colors.white,
                        letterSpacing: -0.3,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 14),
                  _Subtitle('Set daily goals, track progress, and earn achievements'),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// SCREEN 4: UNLOCK YOUR FULL POTENTIAL
// ═══════════════════════════════════════════════════════════════
class _Screen4 extends StatelessWidget {
  final double glowPulse, contentFade, contentSlide, floatAnim;
  final Size size;

  const _Screen4({
    required this.glowPulse,
    required this.contentFade,
    required this.contentSlide,
    required this.floatAnim,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Background
        Container(
          decoration: const BoxDecoration(
            gradient: RadialGradient(
              center: Alignment(0, -0.2),
              radius: 1.3,
              colors: [Color(0xFF1A0F00), Color(0xFF0D0D0D)],
            ),
          ),
        ),

        // Premium badge
        Positioned(
          top: size.height * 0.1,
          left: 0,
          right: 0,
          child: Transform.translate(
            offset: Offset(0, floatAnim * 3),
            child: Center(
              child: Container(
                width: 130,
                height: 130,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFF7A00), Color(0xFFFFB347)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFFF7A00)
                          .withOpacity(0.5 * glowPulse),
                      blurRadius: 40,
                      spreadRadius: 10,
                    ),
                  ],
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Icon(
                      Icons.auto_awesome,
                      color: Colors.white,
                      size: 52,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),

        // Animated glow circles
        Positioned.fill(
          child: IgnorePointer(
            child: CustomPaint(
              painter: _AbstractGlowPainter(glowPulse: glowPulse),
            ),
          ),
        ),

        // Vignette
        Positioned.fill(
          child: IgnorePointer(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  radius: 1.2,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.5),
                  ],
                ),
              ),
            ),
          ),
        ),

        // Content
        Positioned(
          bottom: 160,
          left: 32,
          right: 32,
          child: Opacity(
            opacity: contentFade,
            child: Transform.translate(
              offset: Offset(0, contentSlide),
              child: Column(
                children: [
                  Text(
                    'Unlock Your',
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 34,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      letterSpacing: -0.3,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  ShaderMask(
                    shaderCallback: (bounds) => const LinearGradient(
                      colors: [Color(0xFFFF7A00), Color(0xFFFFB347)],
                    ).createShader(bounds),
                    child: Text(
                      'Full Potential',
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 34,
                        fontWeight: FontWeight.w700,
                        fontStyle: FontStyle.italic,
                        color: Colors.white,
                        letterSpacing: -0.3,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 14),
                  _Subtitle('Get advanced insights, personalized goals & AI recommendations'),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// REUSABLE COMPONENTS
// ═══════════════════════════════════════════════════════════════

class _GradientTitle extends StatelessWidget {
  final String before;
  final String highlight;
  final String after;

  const _GradientTitle(this.before, this.highlight, this.after);

  @override
  Widget build(BuildContext context) {
    return RichText(
      textAlign: TextAlign.center,
      text: TextSpan(
        children: [
          TextSpan(
            text: before,
            style: GoogleFonts.playfairDisplay(
              fontSize: 32,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              letterSpacing: -0.3,
              height: 1.25,
            ),
          ),
          WidgetSpan(
            child: ShaderMask(
              shaderCallback: (bounds) => const LinearGradient(
                colors: [Color(0xFFFF7A00), Color(0xFFFFB347)],
              ).createShader(bounds),
              child: Text(
                highlight,
                style: GoogleFonts.playfairDisplay(
                  fontSize: 32,
                  fontWeight: FontWeight.w700,
                  fontStyle: FontStyle.italic,
                  color: Colors.white,
                  letterSpacing: -0.3,
                  height: 1.25,
                ),
              ),
            ),
          ),
          TextSpan(
            text: after,
            style: GoogleFonts.playfairDisplay(
              fontSize: 32,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              letterSpacing: -0.3,
              height: 1.25,
            ),
          ),
        ],
      ),
    );
  }
}

class _Subtitle extends StatelessWidget {
  final String text;

  const _Subtitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: GoogleFonts.poppins(
        fontSize: 14,
        fontWeight: FontWeight.w300,
        color: Colors.white.withOpacity(0.55),
        height: 1.6,
        letterSpacing: 0.2,
      ),
      textAlign: TextAlign.center,
    );
  }
}

class _DataCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final String unit;
  final double glowPulse;

  const _DataCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.unit,
    required this.glowPulse,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              colors: [
                Colors.white.withOpacity(0.11),
                Colors.white.withOpacity(0.03),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            border: Border.all(
              color: const Color(0xFFFF7A00).withOpacity(0.25 * glowPulse),
              width: 1.5,
            ),
            boxShadow: [
              // Outer glow halo
              BoxShadow(
                color: const Color(0xFFFF7A00).withOpacity(0.12 * glowPulse),
                blurRadius: 28,
                spreadRadius: 4,
              ),
              // Mid glow layer
              BoxShadow(
                color: const Color(0xFFFF7A00).withOpacity(0.18 * glowPulse),
                blurRadius: 16,
                spreadRadius: 1,
              ),
              // Core shadow
              BoxShadow(
                color: const Color(0xFFFF7A00).withOpacity(0.08 * glowPulse),
                blurRadius: 8,
              ),
            ],
          ),
          child: Row(
            children: [
              // Icon
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFF7A00), Color(0xFFFFB347)],
                  ),
                ),
                child: Icon(icon, color: Colors.white, size: 24),
              ),
              const SizedBox(width: 16),
              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: Colors.white54,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          value,
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          unit,
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                            color: Colors.white30,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// CUSTOM PAINTERS
// ═══════════════════════════════════════════════════════════════

class _AnimatedPathPainter extends CustomPainter {
  final double progress;

  _AnimatedPathPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    // Create flowing path
    final path = Path();
    path.moveTo(size.width * 0.15, size.height * 0.2);
    path.quadraticBezierTo(
      size.width * 0.3,
      size.height * 0.35,
      size.width * 0.5,
      size.height * 0.45,
    );
    path.quadraticBezierTo(
      size.width * 0.75,
      size.height * 0.55,
      size.width * 0.85,
      size.height * 0.75,
    );

    // Draw outer glow layer (outermost glow halo)
    canvas.drawPath(
      path,
      Paint()
        ..strokeWidth = 24
        ..color = const Color(0xFFFF7A00).withOpacity(0.06)
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round,
    );

    // Draw middle glow layer
    canvas.drawPath(
      path,
      Paint()
        ..strokeWidth = 12
        ..color = const Color(0xFFFF7A00).withOpacity(0.15)
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round,
    );

    // Draw bright core line
    canvas.drawPath(
      path,
      Paint()
        ..strokeWidth = 4
        ..color = const Color(0xFFFF7A00).withOpacity(0.8)
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round,
    );

    // Draw animated glowing dots
    final offset = progress * 100;

    for (double i = 0; i < 300; i += 25) {
      final t = ((i - offset) % 300) / 300;
      if (t > 0 && t < 0.15) {
        final dx = t * size.width * 0.7;
        final dy = ((t * t) * size.height * 0.6);
        final dotCenter = Offset(size.width * 0.15 + dx, size.height * 0.2 + dy);
        final brightness = 1 - t;

        // Outer glow halo
        canvas.drawCircle(
          dotCenter,
          16 * brightness,
          Paint()
            ..color = const Color(0xFFFF7A00).withOpacity(0.08 * brightness)
            ..style = PaintingStyle.fill,
        );

        // Bright core
        canvas.drawCircle(
          dotCenter,
          5 * brightness,
          Paint()
            ..color = const Color(0xFFFF7A00).withOpacity(0.9 * brightness)
            ..style = PaintingStyle.fill,
        );
      }
    }
  }

  @override
  bool shouldRepaint(_AnimatedPathPainter old) => old.progress != progress;
}

class _ProgressRingPainter extends CustomPainter {
  final double progress;
  final double glowPulse;

  _ProgressRingPainter({required this.progress, required this.glowPulse});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 10;

    // Background ring with glow
    canvas.drawArc(
      Rect.fromCenter(center: center, width: size.width - 20, height: size.height - 20),
      -math.pi / 2,
      2 * math.pi,
      false,
      Paint()
        ..strokeWidth = 7
        ..color = Colors.white.withOpacity(0.1)
        ..style = PaintingStyle.stroke,
    );

    // Outer glow halo for progress ring
    canvas.drawArc(
      Rect.fromCenter(center: center, width: size.width - 20, height: size.height - 20),
      -math.pi / 2,
      2 * math.pi * progress,
      false,
      Paint()
        ..strokeWidth = 20
        ..shader = const LinearGradient(
          colors: [
            Color(0xFFFF7A00),
            Color(0xFFFFB347),
          ],
        ).createShader(Rect.fromCircle(center: center, radius: radius))
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..color = const Color(0xFFFF7A00).withOpacity(0.08 * glowPulse),
    );

    // Progress ring - main core
    canvas.drawArc(
      Rect.fromCenter(center: center, width: size.width - 20, height: size.height - 20),
      -math.pi / 2,
      2 * math.pi * progress,
      false,
      Paint()
        ..strokeWidth = 7
        ..shader = const LinearGradient(
          colors: [Color(0xFFFF7A00), Color(0xFFFFB347)],
        ).createShader(Rect.fromCircle(center: center, radius: radius))
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(_ProgressRingPainter old) =>
      old.progress != progress || old.glowPulse != glowPulse;
}

class _AbstractGlowPainter extends CustomPainter {
  final double glowPulse;

  _AbstractGlowPainter({required this.glowPulse});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height * 0.35);

    // Outer glow layers (dark > bright)
    for (int i = 5; i >= 1; i--) {
      final scale = 0.6 + (i * 0.15);
      final opacity = (0.04 * glowPulse) / i;
      
      canvas.drawCircle(
        center,
        (size.width * scale) * glowPulse,
        Paint()
          ..shader = RadialGradient(
            colors: [
              const Color(0xFFFF7A00).withOpacity(opacity),
              const Color(0xFFFF7A00).withOpacity(0),
            ],
          ).createShader(Rect.fromCircle(
            center: center,
            radius: (size.width * scale) * glowPulse,
          ))
          ..blendMode = BlendMode.screen,
      );
    }

    // Core bright glow
    canvas.drawCircle(
      center,
      (size.width * 0.5) * glowPulse,
      Paint()
        ..shader = RadialGradient(
          colors: [
            const Color(0xFFFF7A00).withOpacity(0.2 * glowPulse),
            const Color(0xFFFFB347).withOpacity(0.08 * glowPulse),
            const Color(0xFFFF7A00).withOpacity(0),
          ],
        ).createShader(Rect.fromCircle(
          center: center,
          radius: (size.width * 0.5) * glowPulse,
        ))
        ..blendMode = BlendMode.screen,
    );
  }

  @override
  bool shouldRepaint(_AbstractGlowPainter old) => old.glowPulse != glowPulse;
}

class _ParticlePainter extends CustomPainter {
  final double progress;
  final int seed;

  _ParticlePainter({required this.progress, required this.seed});

  @override
  void paint(Canvas canvas, Size size) {
    final rng = math.Random(seed);
    final paint = Paint()..style = PaintingStyle.fill;

    for (int i = 0; i < 35; i++) {
      final x = rng.nextDouble() * size.width;
      final baseY = rng.nextDouble() * size.height;
      final speed = 0.15 + rng.nextDouble() * 0.4;
      final radius = 1 + rng.nextDouble() * 2;
      final baseOpacity = 0.08 + rng.nextDouble() * 0.3;

      final y = (baseY - progress * speed * size.height * 0.35) % size.height;
      final phaseFade = (math.sin(progress * math.pi * 2.5 + i * 0.6) + 1) / 2;

      // Outer glow halo
      paint.color = const Color(0xFFFF7A00).withOpacity(baseOpacity * phaseFade * 0.3);
      canvas.drawCircle(Offset(x, y), radius * 3.5, paint);

      // Particle core
      paint.color = const Color(0xFFFF7A00).withOpacity(baseOpacity * phaseFade);
      canvas.drawCircle(Offset(x, y), radius, paint);
    }
  }

  @override
  bool shouldRepaint(_ParticlePainter old) => old.progress != progress;
}
