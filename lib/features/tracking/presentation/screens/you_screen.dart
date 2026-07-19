// you_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart' as provider;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/router/route_names.dart';
import '../../../../providers/auth_provider.dart';
import '../providers/dashboard_provider.dart';


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

class YouScreen extends ConsumerStatefulWidget {
  const YouScreen({super.key});
  @override
  ConsumerState<YouScreen> createState() => _YouScreenState();
}

class _YouScreenState extends ConsumerState<YouScreen> {
  int _currentPhaseLevel = 0;

  @override
  void initState() {
    super.initState();
    _loadPhaseLevel();
  }

  Future<void> _loadPhaseLevel() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getInt('current_phase_level') ?? 0;
    if (mounted) setState(() => _currentPhaseLevel = saved);
  }

  /// Map phase name from API → level index
  static int _getPhaseLevelFromName(String? phaseName) {
    if (phaseName == null) return 0;
    final lower = phaseName.toLowerCase();
    for (int i = 0; i < _phaseNames.length; i++) {
      if (_phaseNames[i].toLowerCase() == lower) return i;
    }
    if (lower.contains('beginner') || lower.contains('activation')) return 0;
    if (lower.contains('fat')) return 1;
    if (lower.contains('metabolic')) return 2;
    if (lower.contains('transformation')) return 3;
    if (lower.contains('limit')) return 4;
    return 0;
  }

  static const List<String> _phaseNames = [
    'Fat Gain',
    'Fat Maintain',
    'Metabolic',
    'Transformation Phase',
    'Limit Zone',
  ];

  @override
  Widget build(BuildContext context) {
    final auth = provider.Provider.of<AuthProvider>(context);
    final profile = auth.userProfile;
    final name = profile?['name'] ?? 'Guest';
    final email = profile?['email'] ?? '';
    final initial = name.isNotEmpty ? name[0].toUpperCase() : 'G';

    // Read phase from backend progress API (same source as dashboard)
    final progress = ref.watch(dashboardProvider).progressData;
    final backendPhaseName = progress?['currentPhaseName']?.toString();
    final backendPhaseGoal = (progress?['currentPhaseGoal'] as num?)?.toInt();
    final effectivePhaseLevel = backendPhaseName != null
        ? _getPhaseLevelFromName(backendPhaseName)
        : _currentPhaseLevel;
    // Use backend phase name directly for display (not the hardcoded array)
    final displayPhaseName = backendPhaseName ?? _phaseNames[effectivePhaseLevel.clamp(0, 4)];

    // Update SharedPreferences if backend disagrees with local cache
    if (backendPhaseName != null && effectivePhaseLevel != _currentPhaseLevel) {
      _currentPhaseLevel = effectivePhaseLevel;
      SharedPreferences.getInstance().then((prefs) {
        prefs.setInt('current_phase_level', effectivePhaseLevel);
      });
    }

    final phaseData = [
      {'icon': Icons.rocket_launch_rounded,         'name': 'Fat Gain',             'range': '0 – 5,000 steps',       'color': const Color(0xFF4FC3F7), 'level': 0},
      {'icon': Icons.local_fire_department_rounded, 'name': 'Fat Maintain',         'range': '5,001 – 7,000 steps',   'color': const Color(0xFFFF6B2B), 'level': 1},
      {'icon': Icons.bolt_rounded,                  'name': 'Metabolic',            'range': '7,001 – 10,000 steps',  'color': const Color(0xFFFFCC00), 'level': 2},
      {'icon': Icons.fitness_center_rounded,        'name': 'Transformation Phase', 'range': '10,001 – 12,000 steps', 'color': const Color(0xFFBF5AF2), 'level': 3},
      {'icon': Icons.emoji_events_rounded,          'name': 'Limit Zone',            'range': '12,000+ steps',         'color': const Color(0xFFFF2D55), 'level': 4},
    ];

    return Scaffold(
      backgroundColor: _C.bg,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // ── Header ──
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => context.go(RouteNames.dashboard),
                    child: Container(
                      width: 36, height: 36,
                      decoration: BoxDecoration(color: _C.card2, borderRadius: BorderRadius.circular(10)),
                      child: const Icon(Icons.arrow_back_rounded, color: _C.mid, size: 19),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('You', style: GoogleFonts.inter(fontSize: 28, fontWeight: FontWeight.w700, color: _C.hi)),
                      Text('Your Journey', style: GoogleFonts.inter(fontSize: 13, color: _C.mid)),
                    ],
                  ),
                ],
              ),
            ),
            Container(height: 1, color: _C.divider),

            // ── Scrollable Content ──
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Profile Card ──
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF1A1208), Color(0xFF141414)],
                          begin: Alignment.topLeft, end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(color: _C.accent.withOpacity(0.15)),
                      ),
                      child: Row(children: [
                        Container(
                          width: 60, height: 60,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: _C.accentGrad,
                            boxShadow: [BoxShadow(color: _C.accent.withOpacity(0.3), blurRadius: 16, spreadRadius: 2)],
                          ),
                          child: Center(child: Text(initial, style: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.w800, color: Colors.white))),
                        ),
                        const SizedBox(width: 16),
                        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text(name, style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w800, color: _C.hi)),
                          const SizedBox(height: 4),
                          if (email.isNotEmpty) Text(email, style: GoogleFonts.inter(fontSize: 13, color: _C.mid)),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(colors: [_C.accent.withOpacity(0.2), _C.accent.withOpacity(0.05)]),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: _C.accent.withOpacity(0.3)),
                            ),
                            child: Text(
                              displayPhaseName,
                              style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w700, color: _C.accent, letterSpacing: 0.3),
                            ),
                          ),
                        ])),
                      ]),
                    ),

                    const SizedBox(height: 28),

                    // ── Section Title ──
                    Row(children: [
                      Icon(Icons.stairs_rounded, color: _C.accent, size: 20),
                      const SizedBox(width: 10),
                      Text('YOUR JOURNEY', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w800, color: _C.mid, letterSpacing: 1.2)),
                    ]),
                    const SizedBox(height: 16),

                    // ── Phase Cards ──
                    ...phaseData.map((phase) {
                      final level = phase['level'] as int;
                      final isCurrent = level == effectivePhaseLevel;
                      final isCompleted = level < effectivePhaseLevel;
                      final phaseColor = phase['color'] as Color;

                      return Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                        decoration: BoxDecoration(
                          color: isCurrent ? phaseColor.withOpacity(0.08) : isCompleted ? const Color(0xFF1A1A1A) : _C.card,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: isCurrent ? phaseColor.withOpacity(0.5) : isCompleted ? _C.green.withOpacity(0.2) : _C.divider.withOpacity(0.5),
                            width: isCurrent ? 1.5 : 1,
                          ),
                          boxShadow: isCurrent ? [BoxShadow(color: phaseColor.withOpacity(0.15), blurRadius: 12, spreadRadius: 1)] : null,
                        ),
                        child: Row(children: [
                          Container(
                            width: 44, height: 44,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isCurrent ? phaseColor.withOpacity(0.15) : isCompleted ? _C.green.withOpacity(0.1) : _C.card2,
                              border: Border.all(color: isCurrent ? phaseColor.withOpacity(0.4) : isCompleted ? _C.green.withOpacity(0.3) : _C.lo.withOpacity(0.3)),
                            ),
                            child: Icon(
                              isCompleted ? Icons.check_rounded : phase['icon'] as IconData,
                              color: isCurrent ? phaseColor : isCompleted ? _C.green : _C.lo,
                              size: 22,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Text(phase['name'] as String, style: GoogleFonts.inter(
                              fontSize: 15, fontWeight: isCurrent ? FontWeight.w700 : FontWeight.w500,
                              color: isCurrent ? phaseColor : isCompleted ? _C.hi : _C.mid,
                            )),
                            const SizedBox(height: 4),
                            Text(phase['range'] as String, style: GoogleFonts.inter(fontSize: 12, color: isCurrent ? phaseColor.withOpacity(0.7) : _C.lo)),
                          ])),
                          if (isCurrent)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                color: phaseColor.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: phaseColor.withOpacity(0.3)),
                              ),
                              child: Text('CURRENT', style: GoogleFonts.inter(fontSize: 9, fontWeight: FontWeight.w800, color: phaseColor, letterSpacing: 0.5)),
                            )
                          else if (isCompleted)
                            Icon(Icons.check_circle_rounded, color: _C.green.withOpacity(0.6), size: 22),
                        ]),
                      );
                    }),

                    const SizedBox(height: 12),

                    // ── Info Tip ──
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: _C.accent.withOpacity(0.04),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: _C.accent.withOpacity(0.1)),
                      ),
                      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Icon(Icons.info_outline_rounded, color: _C.accent.withOpacity(0.6), size: 18),
                        const SizedBox(width: 12),
                        Expanded(child: Text(
                          'Complete your daily goal for 3 consecutive days to advance to the next phase!',
                          style: GoogleFonts.inter(fontSize: 12, color: _C.mid, height: 1.5),
                        )),
                      ]),
                    ),

                    const SizedBox(height: 24),

                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }


}