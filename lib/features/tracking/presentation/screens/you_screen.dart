// you_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'dart:math' as math;           // ← MUST be here at top
import '../../../../core/router/route_names.dart';


// ─── Colours (same tokens as dashboard) ───
class _C {
  static const bg       = Color(0xFF0A0A0A);
  static const card     = Color(0xFF141414);
  static const card2    = Color(0xFF1C1C1C);
  static const divider  = Color(0xFF252525);
  static const hi       = Color(0xFFFFFFFF);
  static const mid      = Color(0xFF8A8A8A);
  static const lo       = Color(0xFF3A3A3A);
  static const accent   = Color(0xFFFF6B2B);
  static const accentDim = Color(0x1AFF6B2B);
  static const green    = Color(0xFF30D158);
  static const accentGrad = LinearGradient(
    colors: [Color(0xFFFF6B2B), Color(0xFFFF9A3C)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

class YouScreen extends StatefulWidget {
  const YouScreen({super.key});
  @override
  State<YouScreen> createState() => _YouScreenState();
}

class _YouScreenState extends State<YouScreen> {
  int _tab = 0; // 0 = Progress, 1 = Activities

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _C.bg,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _header(),
            _tabBar(),
            Expanded(
              child: _tab == 0
                  ? _progressContent()
                  : _activitiesContent(),
            ),
          ],
        ),
      ),
    );
  }

  // ── HEADER ──────────────────────────────
Widget _header() {
  return Padding(
    padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
    child: Row(
      children: [
        // ── Back button ──────────────────────
        GestureDetector(
          onTap: () => context.go(RouteNames.dashboard),
          child: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: _C.card2,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.arrow_back_rounded,
              color: _C.mid,
              size: 19,
            ),
          ),
        ),
        const SizedBox(width: 12),

        // ── Title ────────────────────────────
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('You',
                style: GoogleFonts.inter(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    color: _C.hi)),
            Text('Progress',
                style: GoogleFonts.inter(
                    fontSize: 13, color: _C.mid)),
          ],
        ),
        const Spacer(),

        // ── Avatar ───────────────────────────
        _iconBtn(Icons.person_rounded),
        const SizedBox(width: 10),

        // ── Search ───────────────────────────
        _iconBtn(Icons.search_rounded),
        const SizedBox(width: 10),

        // ── Settings with red dot ────────────
        Stack(
          clipBehavior: Clip.none,
          children: [
            _iconBtn(Icons.settings_outlined),
            Positioned(
              top: 5,
              right: 5,
              child: Container(
                width: 7,
                height: 7,
                decoration: const BoxDecoration(
                  color: _C.accent,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ],
        ),
      ],
    ),
  );
}

  Widget _iconBtn(IconData icon, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap ?? () {},
      child: Container(
        width: 36, height: 36,
        decoration: BoxDecoration(
          color: _C.card2,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: _C.mid, size: 19),
      ),
    );
  }

  // ── TAB BAR ─────────────────────────────
  Widget _tabBar() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              _tabItem(0, 'Progress'),
              const SizedBox(width: 28),
              _tabItem(1, 'Activities'),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Container(height: 1, color: _C.divider),
      ],
    );
  }

  Widget _tabItem(int idx, String label) {
    final active = _tab == idx;
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        setState(() => _tab = idx);
      },
      child: Column(
        children: [
          Text(label,
              style: GoogleFonts.inter(
                fontSize: 15,
                fontWeight: active ? FontWeight.w700 : FontWeight.w400,
                color: active ? _C.hi : _C.mid,
              )),
          const SizedBox(height: 8),
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            height: 2,
            width: active ? label.length * 7.5 : 0,
            decoration: BoxDecoration(
              color: _C.accent,
              borderRadius: BorderRadius.circular(1),
            ),
          ),
        ],
      ),
    );
  }

  // ════════════════════════════════════════
  //  PROGRESS CONTENT
  // ════════════════════════════════════════
  Widget _progressContent() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
      child: Column(
        children: [
          // Best Efforts
          _card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _sectionTitle('Best Efforts'),
                const SizedBox(height: 16),
                _effortRow('🥇', '5K PR', 'Mar 28, 2026', '26:54', true),
                _div(),
                _effortRow('🥈', '2nd-fastest 5K', 'Mar 28, 2025', '30:12', false),
                const SizedBox(height: 12),
                _chevronRow(),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Goals + Relative Effort
          Row(
            children: [
              Expanded(
                child: _card(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _sectionTitle('Goals'),
                      const SizedBox(height: 14),
                      // Goal ring
                      SizedBox(
                        width: 52, height: 52,
                        child: CustomPaint(
                          painter: _RingPainter(
                              progress: 0.25, color: _C.accent),
                          child: Center(
                            child: Icon(Icons.directions_run_rounded,
                                color: _C.accent, size: 22),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text('Weekly Run Goal',
                          style: GoogleFonts.inter(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: _C.hi)),
                      const SizedBox(height: 4),
                      Text('1/4 runs',
                          style: GoogleFonts.inter(
                              fontSize: 12, color: _C.mid)),
                      const SizedBox(height: 12),
                      _chevronRow(),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _card(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _sectionTitle('Relative Effort'),
                      const SizedBox(height: 14),
                      // Current week
                      Text('89',
                          style: GoogleFonts.inter(
                              fontSize: 28,
                              fontWeight: FontWeight.w800,
                              color: _C.accent)),
                      Text('Mar 23 – Mar 29, 2026',
                          style: GoogleFonts.inter(
                              fontSize: 11, color: _C.mid)),
                      const SizedBox(height: 14),
                      // Previous week
                      Text('22',
                          style: GoogleFonts.inter(
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                              color: _C.mid)),
                      Text('Mar 16 – Mar 22, 2026',
                          style: GoogleFonts.inter(
                              fontSize: 11, color: _C.lo)),
                      const SizedBox(height: 12),
                      _chevronRow(),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Training Log
          _card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _sectionTitle('Training Log'),
                    Text('10.9 km',
                        style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: _C.hi,
                            fontFeatures: [const FontFeature.tabularFigures()])),
                  ],
                ),
                const SizedBox(height: 4),
                Text('Mar 23 – Mar 29, 2026',
                    style: GoogleFonts.inter(
                        fontSize: 12, color: _C.mid)),
                const SizedBox(height: 16),
                _trainingCalendar(),
                const SizedBox(height: 12),
                _chevronRow(),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Subscribe banner
          _subscribeBanner(),
        ],
      ),
    );
  }

  Widget _trainingCalendar() {
    const days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
    // 0=nothing, 1=small dot, 2=3.7km, 3=6.4km (today)
    const data = [0, 1, 0, 2, 0, 3, 0];
    const labels = ['', '', '', '3.7 km', '', '6.4 km', ''];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(7, (i) {
        return Column(
          children: [
            Text(days[i],
                style: GoogleFonts.inter(
                    fontSize: 11, color: _C.mid)),
            const SizedBox(height: 8),
            _trainDot(data[i], labels[i]),
          ],
        );
      }),
    );
  }

  Widget _trainDot(int type, String label) {
    if (type == 0) return const SizedBox(height: 40);
    if (type == 1) {
      return Container(
        width: 10, height: 10,
        decoration: BoxDecoration(
          color: _C.green.withOpacity(0.5),
          shape: BoxShape.circle,
        ),
      );
    }
    final size = type == 3 ? 42.0 : 36.0;
    return Container(
      width: size, height: size,
      decoration: BoxDecoration(
        color: _C.green,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(label,
            style: GoogleFonts.inter(
                fontSize: 9,
                fontWeight: FontWeight.w700,
                color: Colors.white)),
      ),
    );
  }

  Widget _subscribeBanner() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [_C.accent.withOpacity(0.12), _C.bg],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _C.accent.withOpacity(0.2)),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(
              color: _C.accentDim,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.lock_outline_rounded,
                color: _C.accent, size: 18),
          ),
          const SizedBox(height: 14),
          Text('Unlock your full potential.',
              style: GoogleFonts.inter(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: _C.hi)),
          const SizedBox(height: 6),
          Text(
            'Track your progress and reach your goals\nwith Premium features.',
            style: GoogleFonts.inter(
                fontSize: 13, color: _C.mid, height: 1.5),
          ),
          const SizedBox(height: 18),
          GestureDetector(
            onTap: () {},
            child: Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 24, vertical: 14),
              decoration: BoxDecoration(
                gradient: _C.accentGrad,
                borderRadius: BorderRadius.circular(30),
              ),
              child: Text('Subscribe',
                  style: GoogleFonts.inter(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }

  // ════════════════════════════════════════
  //  ACTIVITIES CONTENT
  // ════════════════════════════════════════
  Widget _activitiesContent() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.directions_run_rounded, color: _C.lo, size: 52),
          const SizedBox(height: 18),
          Text('No activities yet',
              style: GoogleFonts.inter(
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                  color: _C.mid)),
          const SizedBox(height: 8),
          Text('Record a workout to see it here',
              style: GoogleFonts.inter(fontSize: 13, color: _C.lo)),
        ],
      ),
    );
  }

  // ── HELPERS ─────────────────────────────
  Widget _card({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: _C.card,
        borderRadius: BorderRadius.circular(18),
      ),
      child: child,
    );
  }

  Widget _sectionTitle(String t) {
    return Text(t,
        style: GoogleFonts.inter(
            fontSize: 15, fontWeight: FontWeight.w700, color: _C.hi));
  }

  Widget _div() => Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Container(height: 1, color: _C.divider),
      );

  Widget _chevronRow() => Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [Icon(Icons.chevron_right_rounded, color: _C.lo, size: 20)],
      );

  Widget _effortRow(String emoji, String label, String date,
      String value, bool bold) {
    return Row(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 28)),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: bold ? FontWeight.w700 : FontWeight.w500,
                      color: bold ? _C.hi : _C.mid)),
              const SizedBox(height: 2),
              Text(date,
                  style: GoogleFonts.inter(
                      fontSize: 12, color: _C.mid)),
            ],
          ),
        ),
        Text(value,
            style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: bold ? _C.hi : _C.mid,
                fontFeatures: [const FontFeature.tabularFigures()])),
      ],
    );
  }
}

// ── RING PAINTER ────────────────────────
class _RingPainter extends CustomPainter {
  final double progress;
  final Color color;
  const _RingPainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    // NO import here — math is imported at the top of the file
    final c = Offset(size.width / 2, size.height / 2);
    final r = math.min(size.width, size.height) / 2 - 4;

    canvas.drawCircle(c, r,
        Paint()
          ..color = color.withOpacity(0.15)
          ..strokeWidth = 4
          ..style = PaintingStyle.stroke);

    canvas.drawArc(
      Rect.fromCircle(center: c, radius: r),
      -math.pi / 2,
      2 * math.pi * progress,
      false,
      Paint()
        ..color = color
        ..strokeWidth = 4
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(_) => false;
}