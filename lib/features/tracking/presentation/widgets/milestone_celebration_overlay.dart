import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

/// Full-screen confetti celebration overlay for milestones.
/// Usage:
/// ```dart
/// MilestoneCelebrationOverlay.show(
///   context,
///   icon: '🎉',
///   title: '1000 Steps!',
///   subtitle: 'Keep going, you're crushing it!',
/// );
/// ```
class MilestoneCelebrationOverlay {
  static OverlayEntry? _currentOverlay;

  static void show(
    BuildContext context, {
    required String icon,
    required String title,
    String? subtitle,
    Color accentColor = const Color(0xFFFF6B2B),
    Duration duration = const Duration(milliseconds: 2500),
  }) {
    // Dismiss any existing overlay
    _currentOverlay?.remove();
    _currentOverlay = null;

    HapticFeedback.heavyImpact();

    final overlay = Overlay.of(context);
    late OverlayEntry entry;

    entry = OverlayEntry(
      builder: (ctx) => _CelebrationWidget(
        icon: icon,
        title: title,
        subtitle: subtitle,
        accentColor: accentColor,
        duration: duration,
        onDismiss: () {
          entry.remove();
          if (_currentOverlay == entry) _currentOverlay = null;
        },
      ),
    );

    _currentOverlay = entry;
    overlay.insert(entry);
  }
}

class _CelebrationWidget extends StatefulWidget {
  final String icon;
  final String title;
  final String? subtitle;
  final Color accentColor;
  final Duration duration;
  final VoidCallback onDismiss;

  const _CelebrationWidget({
    required this.icon,
    required this.title,
    this.subtitle,
    required this.accentColor,
    required this.duration,
    required this.onDismiss,
  });

  @override
  State<_CelebrationWidget> createState() => _CelebrationWidgetState();
}

class _CelebrationWidgetState extends State<_CelebrationWidget>
    with TickerProviderStateMixin {
  late final AnimationController _confettiController;
  late final AnimationController _badgeController;
  late final AnimationController _fadeController;
  late final Animation<double> _badgeScale;
  late final Animation<double> _badgeBounce;
  late final Animation<double> _fadeAnim;
  late final List<_ConfettiParticle> _particles;
  final _random = math.Random();

  @override
  void initState() {
    super.initState();

    // Confetti animation — runs for full duration
    _confettiController = AnimationController(
      vsync: this,
      duration: widget.duration,
    )..forward();

    // Badge scale-in with bounce
    _badgeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..forward();

    _badgeScale = CurvedAnimation(
      parent: _badgeController,
      curve: Curves.elasticOut,
    );

    _badgeBounce = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.2), weight: 40),
      TweenSequenceItem(tween: Tween(begin: 1.2, end: 0.95), weight: 20),
      TweenSequenceItem(tween: Tween(begin: 0.95, end: 1.0), weight: 40),
    ]).animate(CurvedAnimation(
      parent: _badgeController,
      curve: Curves.easeOut,
    ));

    // Fade out at the end
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _fadeAnim = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeIn),
    );

    // Generate confetti particles (lightweight — only 25)
    _particles = List.generate(25, (_) => _ConfettiParticle.random(_random));

    // Schedule fade-out and dismiss
    Future.delayed(widget.duration - const Duration(milliseconds: 800), () {
      if (mounted) {
        _fadeController.forward().then((_) {
          widget.onDismiss();
        });
      }
    });
  }

  @override
  void dispose() {
    _confettiController.dispose();
    _badgeController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnim,
      child: Material(
        color: Colors.transparent,
        child: GestureDetector(
          onTap: () {
            _fadeController.forward().then((_) => widget.onDismiss());
          },
          child: Stack(
            children: [
              // Semi-transparent background
              Positioned.fill(
                child: AnimatedBuilder(
                  animation: _badgeController,
                  builder: (_, __) => Container(
                    color: Colors.black
                        .withOpacity(0.5 * _badgeController.value),
                  ),
                ),
              ),

              // Confetti particles (isolated repaint)
              Positioned.fill(
                child: RepaintBoundary(
                  child: AnimatedBuilder(
                    animation: _confettiController,
                    builder: (_, __) => CustomPaint(
                      painter: _ConfettiPainter(
                        particles: _particles,
                        progress: _confettiController.value,
                        accentColor: widget.accentColor,
                      ),
                    ),
                  ),
                ),
              ),

              // Center badge
              Center(
                child: AnimatedBuilder(
                  animation: _badgeBounce,
                  builder: (_, __) => Transform.scale(
                    scale: _badgeBounce.value,
                    child: _buildBadge(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBadge() {
    return Container(
      width: 280,
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 36),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF1A1A2E),
            const Color(0xFF16213E),
          ],
        ),
        border: Border.all(
          color: widget.accentColor.withOpacity(0.4),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: widget.accentColor.withOpacity(0.3),
            blurRadius: 40,
            spreadRadius: 8,
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.5),
            blurRadius: 20,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Glowing icon container
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  widget.accentColor,
                  widget.accentColor.withOpacity(0.7),
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: widget.accentColor.withOpacity(0.5),
                  blurRadius: 24,
                  spreadRadius: 4,
                ),
              ],
            ),
            child: Center(
              child: Text(
                widget.icon,
                style: const TextStyle(fontSize: 40),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Title
          Text(
            widget.title,
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 24,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              height: 1.2,
            ),
          ),

          if (widget.subtitle != null) ...[
            const SizedBox(height: 8),
            Text(
              widget.subtitle!,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.white.withOpacity(0.7),
                height: 1.4,
              ),
            ),
          ],

          const SizedBox(height: 20),

          // Shimmer bar
          Container(
            height: 4,
            width: 120,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(2),
              gradient: LinearGradient(
                colors: [
                  widget.accentColor.withOpacity(0.2),
                  widget.accentColor,
                  widget.accentColor.withOpacity(0.2),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Confetti Particle Model ──────────────────────────────────────

class _ConfettiParticle {
  final double x;         // 0..1 horizontal start
  final double speed;     // fall speed multiplier
  final double size;      // particle size
  final double wobble;    // horizontal wobble amplitude
  final double rotation;  // rotation speed
  final int colorIndex;   // color palette index
  final int shape;        // 0=circle, 1=rect, 2=star

  _ConfettiParticle({
    required this.x,
    required this.speed,
    required this.size,
    required this.wobble,
    required this.rotation,
    required this.colorIndex,
    required this.shape,
  });

  factory _ConfettiParticle.random(math.Random rng) {
    return _ConfettiParticle(
      x: rng.nextDouble(),
      speed: 0.3 + rng.nextDouble() * 0.7,
      size: 4.0 + rng.nextDouble() * 8.0,
      wobble: rng.nextDouble() * 80.0,
      rotation: rng.nextDouble() * math.pi * 2,
      colorIndex: rng.nextInt(6),
      shape: rng.nextInt(3),
    );
  }
}

// ── Confetti Painter ─────────────────────────────────────────────

class _ConfettiPainter extends CustomPainter {
  final List<_ConfettiParticle> particles;
  final double progress;
  final Color accentColor;

  static final List<Color> _colors = [
    const Color(0xFFFF6B2B), // orange
    const Color(0xFFFFCC00), // gold
    const Color(0xFF30D158), // green
    const Color(0xFF0A84FF), // blue
    const Color(0xFFBF5AF2), // purple
    const Color(0xFFFF4D6A), // pink
  ];

  _ConfettiPainter({
    required this.particles,
    required this.progress,
    required this.accentColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (final p in particles) {
      final color = _colors[p.colorIndex];
      final paint = Paint()..color = color.withOpacity(1.0 - progress * 0.6);

      // Y position: start above screen, fall down
      final y = -50 + (size.height + 100) * progress * p.speed;
      // X position: base + wobble
      final x = p.x * size.width +
          math.sin(progress * math.pi * 4 + p.rotation) * p.wobble;

      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(progress * p.rotation * 6);

      switch (p.shape) {
        case 0: // Circle
          canvas.drawCircle(Offset.zero, p.size / 2, paint);
          break;
        case 1: // Rectangle
          canvas.drawRRect(
            RRect.fromRectAndRadius(
              Rect.fromCenter(center: Offset.zero, width: p.size, height: p.size * 0.6),
              const Radius.circular(1),
            ),
            paint,
          );
          break;
        case 2: // Star/diamond
          final path = Path()
            ..moveTo(0, -p.size / 2)
            ..lineTo(p.size / 3, 0)
            ..lineTo(0, p.size / 2)
            ..lineTo(-p.size / 3, 0)
            ..close();
          canvas.drawPath(path, paint);
          break;
      }

      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_ConfettiPainter old) => old.progress != progress;
}
