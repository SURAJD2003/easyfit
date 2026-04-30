
// import 'dart:math' as math;
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:go_router/go_router.dart';
// import '../../../../core/router/route_names.dart';

// // ───────────────────────────────────────────
// //  DESIGN TOKENS
// // ───────────────────────────────────────────
// class _T {
//   static const bg        = Color(0xFF0A0A0A);
//   static const card      = Color(0xFF141414);
//   static const card2     = Color(0xFF1C1C1C);
//   static const divider   = Color(0xFF252525);
//   static const hi        = Color(0xFFFFFFFF);
//   static const mid       = Color(0xFF8A8A8A);
//   static const lo        = Color(0xFF3A3A3A);
//   static const accent    = Color(0xFFFF6B2B);
//   static const accentDim = Color(0x1AFF6B2B);
//   static const green     = Color(0xFF30D158);
//   static const blue      = Color(0xFF0A84FF);
//   static const purple    = Color(0xFFBF5AF2);
//   static const gold      = Color(0xFFFFCC00);
//   static const accentGrad = LinearGradient(
//     colors: [Color(0xFFFF6B2B), Color(0xFFFF9A3C)],
//     begin: Alignment.topLeft,
//     end: Alignment.bottomRight,
//   );
// }

// extension _Txt on TextStyle {
//   static TextStyle label = GoogleFonts.inter(
//     fontSize: 11, fontWeight: FontWeight.w500,
//     color: _T.mid, letterSpacing: 0.6,
//   );
//   static TextStyle body = GoogleFonts.inter(
//     fontSize: 14, fontWeight: FontWeight.w400, color: _T.mid,
//   );
//   static TextStyle bodyBold = GoogleFonts.inter(
//     fontSize: 14, fontWeight: FontWeight.w600, color: _T.hi,
//   );
//   static TextStyle title = GoogleFonts.inter(
//     fontSize: 17, fontWeight: FontWeight.w600, color: _T.hi,
//   );
//   static TextStyle numSm = GoogleFonts.inter(
//     fontSize: 20, fontWeight: FontWeight.w700, color: _T.hi,
//     fontFeatures: [const FontFeature.tabularFigures()],
//   );
// }

// class DashboardScreen extends StatefulWidget {
//   const DashboardScreen({super.key});
//   @override
//   State<DashboardScreen> createState() => _DashboardScreenState();
// }

// class _DashboardScreenState extends State<DashboardScreen>
//     with TickerProviderStateMixin {
//   int _tab = 0;
//   late final AnimationController _ac;
//   late final Animation<double> _ring;
//   late final AnimationController _glowAc;
//   late final Animation<double> _glow;

//   final Map<String, double> _weeklyData = {
//     'Mon': 320, 'Tue': 180, 'Wed': 540, 'Thu': 120, 'Fri': 410, 'Sat': 280, 'Sun': 0,
//   };

//   @override
//   void initState() {
//     super.initState();
//     SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
//       statusBarColor: Colors.transparent,
//       statusBarBrightness: Brightness.dark,
//       statusBarIconBrightness: Brightness.light,
//     ));
//     _ac = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200))..forward();
//     _ring = CurvedAnimation(parent: _ac, curve: Curves.easeOutQuart);
//     _glowAc = AnimationController(vsync: this, duration: const Duration(milliseconds: 2000))
//       ..repeat(reverse: true);
//     _glow = CurvedAnimation(parent: _glowAc, curve: Curves.easeInOut);
//   }

//   @override
//   void dispose() { _ac.dispose(); _glowAc.dispose(); super.dispose(); }

//   Widget _body() {
//     switch (_tab) {
//       case 1: return _placeholderTab('Workout');
//       case 2: return _placeholderTab('Stats');
//       case 3: return _youTab();
//       default: return _homeTab();
//     }
//   }

//   Widget _placeholderTab(String name) => Center(
//     child: Text(name, style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w600, color: _T.mid)),
//   );

//   Widget _youTab() => const SizedBox.shrink();

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: _T.bg,
//       extendBody: true,
//       body: SafeArea(bottom: false, child: _body()),
//       bottomNavigationBar: _bottomPill(),
//       floatingActionButton: _continueFab(),
//       floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
//     );
//   }

//   Widget _homeTab() {
//     return SingleChildScrollView(
//       physics: const BouncingScrollPhysics(),
//       padding: const EdgeInsets.only(bottom: 110),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           _header(),
//           _heroCard(),
//           _sectionLabel('Morning Habits'),
//           _morningHabitsSection(),
//           _sectionLabel('Streak'),
//           _premiumStreakCard(),
//           _sectionLabel('WEEKLY OVERVIEW'),
//           _weekChart(),
//           const SizedBox(height: 8),
//         ],
//       ),
//     );
//   }

//   // ── HEADER ─────────────────────────────────────────────
//   Widget _header() {
//     return Padding(
//       padding: const EdgeInsets.fromLTRB(22, 18, 22, 0),
//       child: Row(
//         children: [
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text('Saturday, 28 Mar', style: _Txt.label),
//                 const SizedBox(height: 3),
//                 Text('Good morning, Suraj', style: _Txt.title),
//               ],
//             ),
//           ),
//           GestureDetector(
//             onTap: _openSearch,
//             child: Container(
//               width: 38, height: 38,
//               decoration: BoxDecoration(color: _T.card, borderRadius: BorderRadius.circular(12)),
//               child: const Icon(Icons.search_rounded, color: _T.mid, size: 20),
//             ),
//           ),
//           const SizedBox(width: 10),
//           GestureDetector(
//             onTap: _openProfile,
//             child: Container(
//               width: 38, height: 38,
//               decoration: const BoxDecoration(shape: BoxShape.circle, gradient: _T.accentGrad),
//               child: Center(
//                 child: Text('S', style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w700, color: Colors.white)),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

// // ── HERO CARD — FINAL FIXED ──────────────────────────────
// Widget _heroCard() {
//   return Padding(
//     padding: const EdgeInsets.fromLTRB(22, 20, 22, 0),
//     child: Container(
//       decoration: BoxDecoration(
//         color: _T.card,
//         borderRadius: BorderRadius.circular(24),
//       ),
//       padding: const EdgeInsets.fromLTRB(20, 18, 20, 36),
//       child: Column(
//         children: [
//           // ── kcal top left ──
//           Align(
//             alignment: Alignment.centerLeft,
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text('432',
//                     style: GoogleFonts.inter(
//                         fontSize: 20,
//                         fontWeight: FontWeight.w800,
//                         color: _T.hi)),
//                 Text('kcal burned',
//                     style: GoogleFonts.inter(
//                         fontSize: 11, color: _T.mid)),
//               ],
//             ),
//           ),

//           const SizedBox(height: 16),

//           // ── Arc ──
//           AnimatedBuilder(
//             animation: _ring,
//             builder: (_, __) {
//               return AspectRatio(
//                 aspectRatio: 1.4,
//                 child: CustomPaint(
//                   painter: _HeroArcPainter(
//                       progress: _ring.value * 0.89),
//                   child: Padding(
//                     // Push content DOWN into the arc center
//                     padding: const EdgeInsets.only(top: 40),
//                     child: Column(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         Text(
//                           '6,240',
//                           style: GoogleFonts.inter(
//                             fontSize: 44,
//                             fontWeight: FontWeight.w900,
//                             color: _T.hi,
//                             height: 1,
//                           ),
//                         ),
//                         const SizedBox(height: 4),
//                         Text(
//                           'steps',
//                           style: GoogleFonts.inter(
//                             fontSize: 14,
//                             color: _T.mid,
//                             fontWeight: FontWeight.w500,
//                           ),
//                         ),
//                         const SizedBox(height: 14),
//                         Container(
//                           padding: const EdgeInsets.symmetric(
//                               horizontal: 18, vertical: 7),
//                           decoration: BoxDecoration(
//                             gradient: const LinearGradient(
//                               colors: [
//                                 Color(0xFFFF6B2B),
//                                 Color(0xFFFF9A3C)
//                               ],
//                             ),
//                             borderRadius: BorderRadius.circular(20),
//                           ),
//                           child: Text(
//                             'Fat Loss',
//                             style: GoogleFonts.inter(
//                               fontSize: 13,
//                               fontWeight: FontWeight.w700,
//                               color: Colors.white,
//                             ),
//                           ),
//                         ),
//                         const SizedBox(height: 8),
//                         Text(
//                           'Goal: 7,000',
//                           style: GoogleFonts.inter(
//                             fontSize: 12,
//                             color: _T.mid,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//               );
//             },
//           ),
//         ],
//       ),
//     ),
//   );
// }



//   // ══════════════════════════════════════════════════════════
// //  MORNING HABITS — CLEAN REMINDER CARDS (STATIC)
// // ══════════════════════════════════════════════════════════
// // ══════════════════════════════════════════════════════════
// //  MORNING HABITS — EXACTLY LIKE REFERENCE IMAGE
// // ══════════════════════════════════════════════════════════
// Widget _morningHabitsSection() {
//   return Padding(
//     padding: const EdgeInsets.symmetric(horizontal: 22),
//     child: IntrinsicHeight(  // <-- THIS is the fix
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.stretch, // <-- stretch all to same height
//         children: [
//           Expanded(
//             child: _habitCard(
//               icon: '💊',
//               title: 'Take Tablet',
//               subtitle: 'Take your\nmorning tablet',
//               done: true,
//             ),
//           ),
//           const SizedBox(width: 10),
//           Expanded(
//             child: _habitCard(
//               icon: '💧',
//               title: 'Drink Water',
//               subtitle: 'Drink a glass\nof water',
//               done: true,
//             ),
//           ),
//           const SizedBox(width: 10),
//           Expanded(
//             child: _habitCard(
//               icon: '🚶',
//               title: 'Walk',
//               subtitle: 'Walk 10 minutes\n(-1000 steps)',
//               done: false,
//             ),
//           ),
//         ],
//       ),
//     ),
//   );
// }

// Widget _habitCard({
//   required String icon,
//   required String title,
//   required String subtitle,
//   required bool done,
// }) {
//   return Container(
//     padding: const EdgeInsets.fromLTRB(12, 14, 12, 14),
//     decoration: BoxDecoration(
//       color: _T.card,
//       borderRadius: BorderRadius.circular(18),
//       border: Border.all(color: _T.divider),
//     ),
//     child: Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         // Top row: emoji icon + lock/unlock icon
//         Row(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(icon, style: const TextStyle(fontSize: 22)),
//             const Spacer(),
//             Icon(
//               done ? Icons.lock_open_rounded : Icons.lock_rounded,
//               color: done ? _T.lo : _T.lo,
//               size: 14,
//             ),
//           ],
//         ),
//         const SizedBox(height: 10),
//         // Title
//         Text(
//           title,
//           style: GoogleFonts.inter(
//             fontSize: 13,
//             fontWeight: FontWeight.w700,
//             color: _T.hi,
//           ),
//         ),
//         const SizedBox(height: 6),
//         // Subtitle lines with checkmark
//         Row(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Padding(
//               padding: const EdgeInsets.only(top: 1),
//               child: Icon(
//                 Icons.check_rounded,
//                 size: 12,
//                 color: done ? _T.accent : _T.lo,
//               ),
//             ),
//             const SizedBox(width: 4),
//             Expanded(
//               child: Text(
//                 subtitle,
//                 style: GoogleFonts.inter(
//                   fontSize: 11,
//                   color: _T.mid,
//                   height: 1.5,
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ],
//     ),
//   );
// }
// // ══════════════════════════════════════════════════════════
// //  PREMIUM STREAK CARD — COMPACT HORIZONTAL STYLE
// // ══════════════════════════════════════════════════════════
// Widget _premiumStreakCard() {
//   const dayLabels   = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
//   const doneIndices = [0, 1, 2, 3];
//   const currentIndex = 3;

//   return Padding(
//     padding: const EdgeInsets.symmetric(horizontal: 22),
//     child: AnimatedBuilder(
//       animation: _glow,
//       builder: (_, __) {
//         return Container(
//           decoration: BoxDecoration(
//             borderRadius: BorderRadius.circular(22),
//             color: const Color(0xFF1A1208),
//             border: Border.all(
//               color: _T.accent.withOpacity(0.15 + _glow.value * 0.1),
//               width: 1.2,
//             ),
//             boxShadow: [
//               BoxShadow(
//                 color: _T.accent.withOpacity(0.06 + _glow.value * 0.05),
//                 blurRadius: 20,
//                 spreadRadius: 2,
//               ),
//             ],
//           ),
//           padding: const EdgeInsets.fromLTRB(16, 16, 16, 18),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [

//               // ── TOP ROW: flame info left + badge right ──
//               Row(
//                 crossAxisAlignment: CrossAxisAlignment.center,
//                 children: [

//                   // Flame circle
//                   AnimatedBuilder(
//                     animation: _glow,
//                     builder: (_, __) => Container(
//                       width: 46, height: 46,
//                       decoration: BoxDecoration(
//                         shape: BoxShape.circle,
//                         color: _T.accent.withOpacity(0.15),
//                         border: Border.all(
//                           color: _T.accent.withOpacity(0.4 + _glow.value * 0.2),
//                           width: 1.5,
//                         ),
//                         boxShadow: [
//                           BoxShadow(
//                             color: _T.accent.withOpacity(0.2 + _glow.value * 0.15),
//                             blurRadius: 12,
//                           ),
//                         ],
//                       ),
//                       child: const Icon(
//                         Icons.local_fire_department_rounded,
//                         color: _T.accent,
//                         size: 24,
//                       ),
//                     ),
//                   ),

//                   const SizedBox(width: 12),

//                   // Title + subtitle
//                   Expanded(
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                           '3 Days Streak',
//                           style: GoogleFonts.inter(
//                             fontSize: 16,
//                             fontWeight: FontWeight.w800,
//                             color: _T.hi,
//                           ),
//                         ),
//                         const SizedBox(height: 3),
//                         Text(
//                           'Keep it up! 2 days to Fat Loss Badge',
//                           style: GoogleFonts.inter(
//                             fontSize: 11,
//                             color: _T.mid,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),

//                   const SizedBox(width: 12),

//                   // Right: Badge panel
//                   GestureDetector(
//                     onTap: () => HapticFeedback.lightImpact(),
//                     child: AnimatedBuilder(
//                       animation: _glow,
//                       builder: (_, __) => Container(
//                         width: 62,
//                         decoration: BoxDecoration(
//                           borderRadius: BorderRadius.circular(14),
//                           color: _T.accent.withOpacity(0.08),
//                           border: Border.all(
//                             color: _T.accent.withOpacity(0.25 + _glow.value * 0.1),
//                           ),
//                         ),
//                         padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
//                         child: Column(
//                           mainAxisSize: MainAxisSize.min,
//                           mainAxisAlignment: MainAxisAlignment.center,
//                           children: [
//                             Icon(
//                               Icons.local_fire_department_rounded,
//                               color: _T.accent,
//                               size: 20,
//                             ),
//                             const SizedBox(height: 4),
//                             Text(
//                               'FAT LOSS',
//                               textAlign: TextAlign.center,
//                               style: GoogleFonts.inter(
//                                 fontSize: 8,
//                                 fontWeight: FontWeight.w800,
//                                 color: _T.accent,
//                                 letterSpacing: 0.4,
//                                 height: 1.2,
//                               ),
//                             ),
//                             const SizedBox(height: 4),
//                             Text(
//                               '+300 XP',
//                               style: GoogleFonts.inter(
//                                 fontSize: 9,
//                                 fontWeight: FontWeight.w700,
//                                 color: _T.gold,
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),

//               const SizedBox(height: 20),

//               // ── TIMELINE DOT ROW ──
//               SizedBox(
//                 height: 48,
//                 child: Row(
//                   children: List.generate(dayLabels.length, (i) {
//                     final isDone = doneIndices.contains(i);
//                     final isToday = i == currentIndex;
//                     final isLast = i == dayLabels.length - 1;

//                     return Expanded(
//                       child: Row(
//                         children: [
//                           Expanded(
//                             child: Column(
//                               mainAxisAlignment: MainAxisAlignment.center,
//                               children: [
//                                 AnimatedContainer(
//                                   duration: const Duration(milliseconds: 300),
//                                   width: isToday ? 28 : 24,
//                                   height: isToday ? 28 : 24,
//                                   decoration: BoxDecoration(
//                                     shape: BoxShape.circle,
//                                     gradient: isDone
//                                         ? const LinearGradient(
//                                             colors: [Color(0xFFFF6B2B), Color(0xFFFF9A3C)],
//                                             begin: Alignment.topLeft,
//                                             end: Alignment.bottomRight,
//                                           )
//                                         : null,
//                                     color: isDone ? null : _T.card2,
//                                     border: isToday
//                                         ? Border.all(color: _T.accent, width: 2)
//                                         : Border.all(
//                                             color: isDone
//                                                 ? Colors.transparent
//                                                 : _T.lo.withOpacity(0.4),
//                                           ),
//                                     boxShadow: isDone
//                                         ? [BoxShadow(
//                                             color: _T.accent.withOpacity(0.4),
//                                             blurRadius: 6,
//                                           )]
//                                         : null,
//                                   ),
//                                   child: Center(
//                                     child: isDone
//                                         ? const Icon(Icons.check_rounded,
//                                             color: Colors.white, size: 13)
//                                         : isToday
//                                             ? Container(
//                                                 width: 6, height: 6,
//                                                 decoration: const BoxDecoration(
//                                                   shape: BoxShape.circle,
//                                                   color: _T.accent,
//                                                 ),
//                                               )
//                                             : null,
//                                   ),
//                                 ),
//                                 const SizedBox(height: 5),
//                                 Text(
//                                   dayLabels[i],
//                                   style: GoogleFonts.inter(
//                                     fontSize: 9,
//                                     fontWeight: isToday
//                                         ? FontWeight.w700
//                                         : FontWeight.w400,
//                                     color: isToday
//                                         ? _T.accent
//                                         : isDone
//                                             ? _T.mid
//                                             : _T.lo,
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//                           // Connector line
//                           if (!isLast)
//                             Container(
//                               height: 2,
//                               width: 4,
//                               decoration: BoxDecoration(
//                                 borderRadius: BorderRadius.circular(2),
//                                 color: i < currentIndex
//                                     ? _T.accent.withOpacity(0.6)
//                                     : _T.lo.withOpacity(0.25),
//                               ),
//                             ),
//                         ],
//                       ),
//                     );
//                   }),
//                 ),
//               ),
//             ],
//           ),
//         );
//       },
//     ),
//   );
// }
//   // ── WEEKLY CHART ───────────────────────────────────────
//   Widget _weekChart() {
//     const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
//     const values = [320, 180, 540, 120, 410, 280, 0];
//     const todayIndex = 5;
//     final total = values.reduce((a, b) => a + b);
//     final avg = (total / 7).round();
//     final maxVal = values.reduce(math.max).toDouble();
//     final bestDay = days[values.indexOf(values.reduce(math.max))];

//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 22),
//       child: GestureDetector(
//         onTap: _showWeekDetails,
//         child: Container(
//           padding: const EdgeInsets.fromLTRB(18, 20, 18, 20),
//           decoration: BoxDecoration(color: _T.card, borderRadius: BorderRadius.circular(24)),
//           child: Column(
//             children: [
//               Row(
//                 children: [
//                   Expanded(child: _weekStat('$total kcal', 'This week')),
//                   Container(width: 1, height: 32, color: _T.divider),
//                   Expanded(child: _weekStat('$avg kcal', 'Avg / day')),
//                   Container(width: 1, height: 32, color: _T.divider),
//                   Expanded(child: _weekStat(bestDay, 'Best day')),
//                 ],
//               ),
//               const SizedBox(height: 20),
//               SizedBox(
//                 height: 96,
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   crossAxisAlignment: CrossAxisAlignment.end,
//                   children: List.generate(7, (i) {
//                     final isToday = i == todayIndex;
//                     final barHeight = maxVal > 0
//                         ? (values[i] / maxVal * 56).clamp(4, 56).toDouble()
//                         : 4.0;
//                     return GestureDetector(
//                       onTap: () {
//                         HapticFeedback.lightImpact();
//                         ScaffoldMessenger.of(context).showSnackBar(SnackBar(
//                           content: Text('${days[i]}: ${values[i]} kcal'),
//                           backgroundColor: _T.card,
//                           behavior: SnackBarBehavior.floating,
//                           duration: const Duration(seconds: 1),
//                         ));
//                       },
//                       child: Column(
//                         mainAxisSize: MainAxisSize.min,
//                         children: [
//                           Container(
//                             width: 26, height: 56,
//                             alignment: Alignment.bottomCenter,
//                             child: Container(
//                               width: 26, height: barHeight,
//                               decoration: BoxDecoration(
//                                 gradient: isToday ? _T.accentGrad : null,
//                                 color: isToday ? null : _T.card2,
//                                 borderRadius: BorderRadius.circular(5),
//                                 border: isToday
//                                     ? Border.all(color: _T.accent.withOpacity(0.5), width: 1)
//                                     : null,
//                               ),
//                             ),
//                           ),
//                           const SizedBox(height: 6),
//                           Text(days[i], style: GoogleFonts.inter(
//                             fontSize: 11,
//                             fontWeight: isToday ? FontWeight.w600 : FontWeight.w400,
//                             color: isToday ? _T.accent : _T.mid,
//                           )),
//                         ],
//                       ),
//                     );
//                   }),
//                 ),
//               ),
//               const SizedBox(height: 4),
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   Icon(Icons.touch_app_rounded, color: _T.lo, size: 11),
//                   const SizedBox(width: 4),
//                   Text('Tap for details', style: GoogleFonts.inter(fontSize: 10, color: _T.lo)),
//                 ],
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   void _showWeekDetails() {
//     showModalBottomSheet(
//       context: context,
//       backgroundColor: Colors.transparent,
//       isScrollControlled: true,
//       builder: (_) => const _WeekDetailsSheet(),
//     );
//   }

//   Widget _weekStat(String val, String label) {
//     return Column(children: [
//       Text(val, style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w700, color: _T.hi)),
//       const SizedBox(height: 3),
//       Text(label, style: _Txt.label),
//     ]);
//   }

//   void _openSearch() {
//     showModalBottomSheet(
//       context: context, backgroundColor: Colors.transparent,
//       isScrollControlled: true, builder: (_) => _SearchSheet(),
//     );
//   }

//   void _openProfile() {
//     showModalBottomSheet(
//       context: context, backgroundColor: Colors.transparent,
//       isScrollControlled: true,
//       builder: (_) => Container(
//         decoration: const BoxDecoration(
//           color: Color(0xFF141414),
//           borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
//         ),
//         padding: EdgeInsets.fromLTRB(24, 16, 24, MediaQuery.of(context).padding.bottom + 32),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Container(width: 36, height: 4, decoration: BoxDecoration(color: _T.lo, borderRadius: BorderRadius.circular(2))),
//             const SizedBox(height: 24),
//             Row(children: [
//               Container(
//                 width: 56, height: 56,
//                 decoration: const BoxDecoration(shape: BoxShape.circle, gradient: _T.accentGrad),
//                 child: Center(child: Text('S', style: GoogleFonts.inter(fontSize: 22, fontWeight: FontWeight.w700, color: Colors.white))),
//               ),
//               const SizedBox(width: 16),
//               Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//                 Text('Suraj Dubey', style: _Txt.title),
//                 const SizedBox(height: 3),
//                 Text('suraj@easyfit.com', style: _Txt.body),
//               ]),
//             ]),
//             const SizedBox(height: 24),
//             Container(height: 1, color: _T.divider),
//             const SizedBox(height: 16),
//             _profileTile(Icons.person_outline_rounded, 'Edit Profile'),
//             _profileTile(Icons.workspace_premium_rounded, 'Subscription', badge: 'Free'),
//             _profileTile(Icons.notifications_outlined, 'Notifications'),
//             _profileTile(Icons.help_outline_rounded, 'Help & Support'),
//             const SizedBox(height: 8),
//             _profileTile(Icons.logout_rounded, 'Sign Out', danger: true),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _profileTile(IconData icon, String label, {String? badge, bool danger = false}) {
//     return GestureDetector(
//       onTap: () {},
//       child: Padding(
//         padding: const EdgeInsets.symmetric(vertical: 12),
//         child: Row(children: [
//           Icon(icon, color: danger ? Colors.redAccent : _T.mid, size: 20),
//           const SizedBox(width: 14),
//           Expanded(child: Text(label, style: GoogleFonts.inter(
//             fontSize: 15, fontWeight: FontWeight.w500,
//             color: danger ? Colors.redAccent : _T.hi,
//           ))),
//           if (badge != null)
//             Container(
//               padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
//               decoration: BoxDecoration(color: _T.accentDim, borderRadius: BorderRadius.circular(20)),
//               child: Text(badge, style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600, color: _T.accent)),
//             )
//           else
//             Icon(Icons.chevron_right_rounded, color: _T.lo, size: 20),
//         ]),
//       ),
//     );
//   }

//   void _onContinue() {
//     HapticFeedback.mediumImpact();
//     showModalBottomSheet(
//       context: context, backgroundColor: Colors.transparent,
//       builder: (_) => _SportPickerSheet(onSelected: (sport) {
//         Navigator.pop(context);
//         Navigator.push(context, MaterialPageRoute(builder: (_) => _TrackingMapScreen(sport: sport)));
//       }),
//     );
//   }

//   Widget _continueFab() {
//     return GestureDetector(
//       onTap: _onContinue,
//       child: AnimatedBuilder(
//         animation: _ring,
//         builder: (_, __) {
//           final pulse = 1 + (_ring.value * 0.08);
//           return Container(
//             width: 58 * pulse, height: 58 * pulse,
//             decoration: BoxDecoration(
//               gradient: _T.accentGrad, shape: BoxShape.circle,
//               boxShadow: [BoxShadow(color: _T.accent.withOpacity(0.45), blurRadius: 16 + (_ring.value * 8), offset: const Offset(0, 4))],
//             ),
//             child: const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 28),
//           );
//         },
//       ),
//     );
//   }

//   // ── BOTTOM PILL NAV (100% UNTOUCHED) ───────────────────
//   Widget _bottomPill() {
//     final bottomPad = MediaQuery.of(context).padding.bottom;
//     return Container(
//       color: Colors.transparent,
//       child: Padding(
//         padding: EdgeInsets.only(left: 20, right: 20, bottom: bottomPad + 12, top: 0),
//         child: Container(
//           height: 64,
//           decoration: BoxDecoration(
//             color: const Color(0xFF1C1C1C),
//             borderRadius: BorderRadius.circular(32),
//             boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.5), blurRadius: 24, offset: const Offset(0, 8))],
//           ),
//           child: Row(
//             mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//             children: [
//               _navItem(0, Icons.home_rounded, 'Home'),
//               _navItem(1, Icons.fitness_center_rounded, 'Workout'),
//               const SizedBox(width: 60),
//               _navItem(2, Icons.bar_chart_rounded, 'Stats'),
//               _navItem(3, Icons.person_rounded, 'You'),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _sectionLabel(String t) {
//     return Padding(
//       padding: const EdgeInsets.fromLTRB(22, 28, 22, 12),
//       child: Text(t, style: _Txt.label),
//     );
//   }

//   Widget _navItem(int idx, IconData icon, String label) {
//     final active = _tab == idx;
//     return GestureDetector(
//       onTap: () {
//         HapticFeedback.selectionClick();
//         if (idx == 2) { context.go(RouteNames.stats); } 
//         else if (idx == 3) { context.go(RouteNames.you); } 
//         else { setState(() => _tab = idx); }
//       },
//       behavior: HitTestBehavior.opaque,
//       child: Padding(
//         padding: const EdgeInsets.symmetric(horizontal: 8),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Icon(icon, color: active ? _T.accent : _T.mid, size: active ? 20 : 22),
//             const SizedBox(height: 4),
//             if (active) Text(label, style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w600, color: _T.accent)),
//           ],
//         ),
//       ),
//     );
//   }
// }

// // ═══════════════════════════════════════════
// //  SEARCH SHEET
// // ═══════════════════════════════════════════
// class _SearchSheet extends StatefulWidget {
//   @override
//   State<_SearchSheet> createState() => _SearchSheetState();
// }

// class _SearchSheetState extends State<_SearchSheet> {
//   final _controller = TextEditingController();
//   final List<String> _suggestions = ['Morning Run', 'Upper Body', 'Evening Stretch', 'Yoga Flow', 'HIIT Session', 'Cycling', 'Swimming'];
//   List<String> _filtered = [];

//   @override
//   void initState() { super.initState(); _filtered = _suggestions; _controller.addListener(_filter); }
//   @override
//   void dispose() { _controller.dispose(); super.dispose(); }

//   void _filter() {
//     final q = _controller.text.toLowerCase();
//     setState(() { _filtered = q.isEmpty ? _suggestions : _suggestions.where((s) => s.toLowerCase().contains(q)).toList(); });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       decoration: const BoxDecoration(color: Color(0xFF141414), borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
//       padding: EdgeInsets.fromLTRB(24, 16, 24, MediaQuery.of(context).padding.bottom + 24),
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Container(width: 36, height: 4, decoration: BoxDecoration(color: _T.lo, borderRadius: BorderRadius.circular(2))),
//           const SizedBox(height: 20),
//           Container(
//             padding: const EdgeInsets.symmetric(horizontal: 16),
//             decoration: BoxDecoration(color: _T.card2, borderRadius: BorderRadius.circular(14), border: Border.all(color: _T.divider)),
//             child: Row(children: [
//               Icon(Icons.search_rounded, color: _T.mid, size: 20),
//               const SizedBox(width: 12),
//               Expanded(child: TextField(
//                 controller: _controller,
//                 style: GoogleFonts.inter(fontSize: 15, color: _T.hi, fontWeight: FontWeight.w500),
//                 decoration: const InputDecoration(hintText: 'Search workouts, metrics...', hintStyle: TextStyle(color: _T.lo), border: InputBorder.none, isCollapsed: true),
//               )),
//               if (_controller.text.isNotEmpty)
//                 GestureDetector(onTap: () { _controller.clear(); _filter(); }, child: Icon(Icons.clear_rounded, color: _T.mid, size: 18)),
//             ]),
//           ),
//           const SizedBox(height: 16),
//           Expanded(
//             child: _filtered.isEmpty
//                 ? Center(child: Text('No results found', style: GoogleFonts.inter(fontSize: 14, color: _T.lo)))
//                 : ListView.separated(
//                     itemCount: _filtered.length,
//                     separatorBuilder: (_, __) => Container(height: 1, color: _T.divider),
//                     itemBuilder: (context, i) {
//                       final item = _filtered[i];
//                       return ListTile(
//                         contentPadding: EdgeInsets.zero,
//                         leading: Container(width: 36, height: 36, decoration: BoxDecoration(color: _T.accentDim, borderRadius: BorderRadius.circular(10)), child: Icon(Icons.fitness_center_rounded, color: _T.accent, size: 18)),
//                         title: Text(item, style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w500, color: _T.hi)),
//                         trailing: Icon(Icons.chevron_right_rounded, color: _T.lo, size: 20),
//                         onTap: () {
//                           Navigator.pop(context);
//                           ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Opening: $item'), backgroundColor: _T.card, behavior: SnackBarBehavior.floating));
//                         },
//                       );
//                     },
//                   ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// // ═══════════════════════════════════════════
// //  WEEK DETAILS SHEET
// // ═══════════════════════════════════════════
// class _WeekDetailsSheet extends StatelessWidget {
//   const _WeekDetailsSheet();
//   @override
//   Widget build(BuildContext context) {
//     const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
//     const values = [320, 180, 540, 120, 410, 280, 0];
//     final maxVal = values.reduce(math.max).toDouble();
//     return Container(
//       decoration: const BoxDecoration(color: Color(0xFF141414), borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
//       padding: EdgeInsets.fromLTRB(24, 16, 24, MediaQuery.of(context).padding.bottom + 24),
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Container(width: 36, height: 4, decoration: BoxDecoration(color: _T.lo, borderRadius: BorderRadius.circular(2))),
//           const SizedBox(height: 20),
//           Text('Weekly Breakdown', style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white)),
//           const SizedBox(height: 24),
//           ...List.generate(7, (i) {
//             final pct = maxVal > 0 ? (values[i] / maxVal * 100).clamp(5, 100) : 5;
//             return Padding(
//               padding: const EdgeInsets.symmetric(vertical: 8),
//               child: Row(children: [
//                 SizedBox(width: 40, child: Text(days[i], style: _Txt.body)),
//                 Expanded(child: Container(
//                   height: 8,
//                   decoration: BoxDecoration(color: _T.card2, borderRadius: BorderRadius.circular(4)),
//                   child: FractionallySizedBox(
//                     alignment: Alignment.centerLeft,
//                     widthFactor: pct / 100,
//                     child: Container(decoration: BoxDecoration(gradient: _T.accentGrad, borderRadius: BorderRadius.circular(4))),
//                   ),
//                 )),
//                 const SizedBox(width: 12),
//                 SizedBox(width: 60, child: Text('${values[i]} kcal', textAlign: TextAlign.end, style: _Txt.bodyBold)),
//               ]),
//             );
//           }),
//           const SizedBox(height: 20),
//           Container(
//             width: double.infinity, padding: const EdgeInsets.symmetric(vertical: 14),
//             decoration: BoxDecoration(color: _T.card2, borderRadius: BorderRadius.circular(14)),
//             child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
//               Icon(Icons.trending_up_rounded, color: _T.green, size: 18),
//               const SizedBox(width: 8),
//               Text("You're 260 kcal ahead of last week!", style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w500, color: _T.green)),
//             ]),
//           ),
//         ],
//       ),
//     );
//   }
// }

// // ═══════════════════════════════════════════
// //  SPORT PICKER SHEET
// // ═══════════════════════════════════════════
// class _SportPickerSheet extends StatelessWidget {
//   final void Function(String sport) onSelected;
//   const _SportPickerSheet({required this.onSelected});
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       decoration: const BoxDecoration(color: Color(0xFF141414), borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
//       padding: const EdgeInsets.fromLTRB(24, 16, 24, 40),
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Container(width: 36, height: 4, decoration: BoxDecoration(color: const Color(0xFF3A3A3A), borderRadius: BorderRadius.circular(2))),
//           const SizedBox(height: 24),
//           Text('Choose Activity', style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w700, color: Colors.white)),
//           const SizedBox(height: 6),
//           Text('Select the type of activity to track', style: GoogleFonts.inter(fontSize: 13, color: const Color(0xFF8A8A8A))),
//           const SizedBox(height: 28),
//           Row(children: [
//             Expanded(child: _sportCard(icon: Icons.directions_walk_rounded, label: 'Walk', subtitle: 'Casual pace\nSteps & distance', color: const Color(0xFF30D158), onTap: () => onSelected('Walk'))),
//             const SizedBox(width: 14),
//             Expanded(child: _sportCard(icon: Icons.directions_run_rounded, label: 'Run', subtitle: 'Active pace\nCalories & speed', color: const Color(0xFFFF6B2B), onTap: () => onSelected('Run'))),
//           ]),
//         ],
//       ),
//     );
//   }

//   Widget _sportCard({required IconData icon, required String label, required String subtitle, required Color color, required VoidCallback onTap}) {
//     return GestureDetector(
//       onTap: onTap,
//       child: Container(
//         padding: const EdgeInsets.all(20),
//         decoration: BoxDecoration(color: color.withOpacity(0.08), borderRadius: BorderRadius.circular(20), border: Border.all(color: color.withOpacity(0.25))),
//         child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//           Container(width: 48, height: 48, decoration: BoxDecoration(color: color.withOpacity(0.15), borderRadius: BorderRadius.circular(14)), child: Icon(icon, color: color, size: 26)),
//           const SizedBox(height: 16),
//           Text(label, style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white)),
//           const SizedBox(height: 4),
//           Text(subtitle, style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFF8A8A8A), height: 1.5)),
//         ]),
//       ),
//     );
//   }
// }

// // ═══════════════════════════════════════════
// //  TRACKING MAP SCREEN
// // ═══════════════════════════════════════════
// class _TrackingMapScreen extends StatefulWidget {
//   final String sport;
//   const _TrackingMapScreen({required this.sport});
//   @override
//   State<_TrackingMapScreen> createState() => _TrackingMapScreenState();
// }

// class _TrackingMapScreenState extends State<_TrackingMapScreen>
//     with SingleTickerProviderStateMixin {
//   bool _isRunning = false;
//   late final AnimationController _pulse;

//   @override
//   void initState() {
//     super.initState();
//     _pulse = AnimationController(vsync: this, duration: const Duration(milliseconds: 900))..repeat(reverse: true);
//   }
//   @override
//   void dispose() { _pulse.dispose(); super.dispose(); }

//   @override
//   Widget build(BuildContext context) {
//     final isWalk = widget.sport == 'Walk';
//     final sportColor = isWalk ? const Color(0xFF30D158) : const Color(0xFFFF6B2B);
//     final sportIcon = isWalk ? Icons.directions_walk_rounded : Icons.directions_run_rounded;

//     return Scaffold(
//       backgroundColor: const Color(0xFF0A0A0A),
//       body: Stack(children: [
//         Positioned.fill(child: CustomPaint(painter: _StaticMapPainter(sportColor: sportColor))),
//         SafeArea(child: Padding(
//           padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
//           child: Row(children: [
//             GestureDetector(
//               onTap: () => Navigator.pop(context),
//               child: Container(width: 40, height: 40, decoration: BoxDecoration(color: Colors.black.withOpacity(0.6), shape: BoxShape.circle), child: const Icon(Icons.arrow_back_rounded, color: Colors.white, size: 20)),
//             ),
//             const SizedBox(width: 12),
//             Container(
//               padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
//               decoration: BoxDecoration(color: Colors.black.withOpacity(0.6), borderRadius: BorderRadius.circular(20)),
//               child: Row(children: [Icon(sportIcon, color: sportColor, size: 16), const SizedBox(width: 6), Text(widget.sport, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white))]),
//             ),
//             const Spacer(),
//             AnimatedBuilder(
//               animation: _pulse,
//               builder: (_, __) => Container(
//                 padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
//                 decoration: BoxDecoration(
//                   color: _isRunning ? sportColor.withOpacity(0.15 + _pulse.value * 0.1) : Colors.black.withOpacity(0.6),
//                   borderRadius: BorderRadius.circular(20),
//                   border: Border.all(color: _isRunning ? sportColor.withOpacity(0.4) : Colors.transparent),
//                 ),
//                 child: Row(children: [
//                   Container(width: 8, height: 8, decoration: BoxDecoration(color: _isRunning ? sportColor : const Color(0xFF8A8A8A), shape: BoxShape.circle)),
//                   const SizedBox(width: 6),
//                   Text(_isRunning ? 'LIVE' : 'READY', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w700, color: _isRunning ? sportColor : const Color(0xFF8A8A8A), letterSpacing: 0.8)),
//                 ]),
//               ),
//             ),
//           ]),
//         )),
//         Positioned(
//           top: 100, left: 20, right: 20,
//           child: Row(children: [
//             _mapStat('0.00', 'km', 'Distance'), const SizedBox(width: 10),
//             _mapStat('00:00', 'min', 'Duration'), const SizedBox(width: 10),
//             _mapStat('0', 'kcal', 'Calories'),
//           ]),
//         ),
//         Center(child: AnimatedBuilder(
//           animation: _pulse,
//           builder: (_, __) => Stack(alignment: Alignment.center, children: [
//             Container(width: 50 + _pulse.value * 20, height: 50 + _pulse.value * 20, decoration: BoxDecoration(shape: BoxShape.circle, color: sportColor.withOpacity(0.1 * (1 - _pulse.value)))),
//             Container(width: 20, height: 20, decoration: BoxDecoration(color: sportColor, shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 3), boxShadow: [BoxShadow(color: sportColor.withOpacity(0.5), blurRadius: 8)])),
//           ]),
//         )),
//         Positioned(
//           bottom: 0, left: 0, right: 0,
//           child: Container(
//             decoration: BoxDecoration(color: const Color(0xFF141414), borderRadius: const BorderRadius.vertical(top: Radius.circular(28)), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.4), blurRadius: 20)]),
//             padding: EdgeInsets.fromLTRB(24, 20, 24, MediaQuery.of(context).padding.bottom + 24),
//             child: Column(mainAxisSize: MainAxisSize.min, children: [
//               Container(width: 36, height: 4, decoration: BoxDecoration(color: const Color(0xFF3A3A3A), borderRadius: BorderRadius.circular(2))),
//               const SizedBox(height: 24),
//               Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
//                 _bottomStat('— /km', 'Pace'),
//                 Container(width: 1, height: 32, color: const Color(0xFF252525)),
//                 _bottomStat('— bpm', 'Heart Rate'),
//                 Container(width: 1, height: 32, color: const Color(0xFF252525)),
//                 _bottomStat('0', 'Steps'),
//               ]),
//               const SizedBox(height: 24),
//               GestureDetector(
//                 onTap: () { HapticFeedback.heavyImpact(); setState(() => _isRunning = !_isRunning); },
//                 child: Container(
//                   width: double.infinity, height: 56,
//                   decoration: BoxDecoration(
//                     gradient: _isRunning
//                         ? const LinearGradient(colors: [Color(0xFFEF4444), Color(0xFFDC2626)])
//                         : const LinearGradient(colors: [Color(0xFFFF6B2B), Color(0xFFFF9A3C)]),
//                     borderRadius: BorderRadius.circular(18),
//                     boxShadow: [BoxShadow(color: (_isRunning ? const Color(0xFFEF4444) : const Color(0xFFFF6B2B)).withOpacity(0.3), blurRadius: 16, offset: const Offset(0, 4))],
//                   ),
//                   child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
//                     Icon(_isRunning ? Icons.stop_rounded : Icons.play_arrow_rounded, color: Colors.white, size: 26),
//                     const SizedBox(width: 8),
//                     Text(_isRunning ? 'Stop Session' : 'Start Session', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white)),
//                   ]),
//                 ),
//               ),
//             ]),
//           ),
//         ),
//       ]),
//     );
//   }

//   Widget _mapStat(String val, String unit, String label) {
//     return Expanded(child: Container(
//       padding: const EdgeInsets.symmetric(vertical: 12),
//       decoration: BoxDecoration(color: Colors.black.withOpacity(0.7), borderRadius: BorderRadius.circular(14)),
//       child: Column(children: [
//         RichText(text: TextSpan(children: [
//           TextSpan(text: val, style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w700, color: Colors.white)),
//           TextSpan(text: ' $unit', style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFF8A8A8A))),
//         ])),
//         const SizedBox(height: 2),
//         Text(label, style: GoogleFonts.inter(fontSize: 11, color: const Color(0xFF6B6B6B))),
//       ]),
//     ));
//   }

//   Widget _bottomStat(String val, String label) {
//     return Column(children: [
//       Text(val, style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white)),
//       const SizedBox(height: 3),
//       Text(label, style: GoogleFonts.inter(fontSize: 11, color: const Color(0xFF8A8A8A))),
//     ]);
//   }
// }

// // ═══════════════════════════════════════════
// //  PAINTERS
// // ═══════════════════════════════════════════
// class _StaticMapPainter extends CustomPainter {
//   final Color sportColor;
//   const _StaticMapPainter({required this.sportColor});

//   @override
//   void paint(Canvas canvas, Size size) {
//     final w = size.width; final h = size.height;
//     canvas.drawRect(Rect.fromLTWH(0, 0, w, h), Paint()..color = const Color(0xFF1A1F2E));
//     final sp = Paint()..color = const Color(0xFF252D3D)..strokeWidth = 1;
//     for (double x = 0; x < w; x += 40) canvas.drawLine(Offset(x, 0), Offset(x, h), sp);
//     for (double y = 0; y < h; y += 40) canvas.drawLine(Offset(0, y), Offset(w, y), sp);
//     final rp = Paint()..color = const Color(0xFF2D3748)..strokeWidth = 8..strokeCap = StrokeCap.round;
//     canvas.drawLine(Offset(0, h * 0.3), Offset(w, h * 0.3), rp);
//     canvas.drawLine(Offset(0, h * 0.6), Offset(w, h * 0.6), rp);
//     canvas.drawLine(Offset(w * 0.25, 0), Offset(w * 0.25, h), rp);
//     canvas.drawLine(Offset(w * 0.7, 0), Offset(w * 0.7, h), rp);
//     final bp = Paint()..color = const Color(0xFF222A3A);
//     for (final b in [
//       Rect.fromLTWH(w*.05,h*.05,w*.15,h*.2), Rect.fromLTWH(w*.3,h*.05,w*.35,h*.2),
//       Rect.fromLTWH(w*.75,h*.05,w*.2,h*.2),  Rect.fromLTWH(w*.05,h*.35,w*.15,h*.2),
//       Rect.fromLTWH(w*.3,h*.35,w*.35,h*.2),  Rect.fromLTWH(w*.75,h*.35,w*.2,h*.2),
//       Rect.fromLTWH(w*.05,h*.65,w*.15,h*.28),Rect.fromLTWH(w*.3,h*.65,w*.35,h*.28),
//       Rect.fromLTWH(w*.75,h*.65,w*.2,h*.28),
//     ]) canvas.drawRRect(RRect.fromRectAndRadius(b, const Radius.circular(4)), bp);

//     final rs = Paint()..color = sportColor.withOpacity(0.25)..strokeWidth = 10..style = PaintingStyle.stroke..strokeCap = StrokeCap.round..strokeJoin = StrokeJoin.round;
//     final rpt = Paint()..color = sportColor..strokeWidth = 4..style = PaintingStyle.stroke..strokeCap = StrokeCap.round..strokeJoin = StrokeJoin.round;
//     final path = Path()
//       ..moveTo(w*.25,h*.65)..lineTo(w*.25,h*.60)..lineTo(w*.70,h*.60)
//       ..lineTo(w*.70,h*.30)..lineTo(w*.25,h*.30)..lineTo(w*.25,h*.50);
//     canvas.drawPath(path, rs);
//     canvas.drawPath(path, rpt);
//     canvas.drawCircle(Offset(w*.25,h*.65), 8, Paint()..color = sportColor);
//     canvas.drawCircle(Offset(w*.25,h*.65), 5, Paint()..color = Colors.white);
//   }

//   @override
//   bool shouldRepaint(_StaticMapPainter o) => o.sportColor != sportColor;
// }

// class _HeroArcPainter extends CustomPainter {
//   final double progress;
//   const _HeroArcPainter({required this.progress});

//   @override
//   void paint(Canvas c, Size s) {
//     // Center is at TRUE center of the box
//     final center = Offset(s.width / 2, s.height / 2);
//     final r = s.width / 2 - 16;

//     final trackPaint = Paint()
//       ..color = const Color(0xFF2A2A2A)
//       ..strokeWidth = 14
//       ..style = PaintingStyle.stroke
//       ..strokeCap = StrokeCap.round;

//     final progressPaint = Paint()
//       ..shader = LinearGradient(
//         colors: const [Color(0xFFFF6B2B), Color(0xFFFFCC00)],
//         begin: Alignment.centerLeft,
//         end: Alignment.centerRight,
//       ).createShader(Rect.fromCircle(center: center, radius: r))
//       ..strokeWidth = 14
//       ..style = PaintingStyle.stroke
//       ..strokeCap = StrokeCap.round;

//     // Arc starts bottom-left, sweeps almost full circle, open at bottom-right
//     const startAngle = math.pi * 0.65;
//     const sweepAngle = math.pi * 1.7;

//     c.drawArc(Rect.fromCircle(center: center, radius: r),
//         startAngle, sweepAngle, false, trackPaint);

//     if (progress > 0) {
//       c.drawArc(Rect.fromCircle(center: center, radius: r),
//           startAngle, sweepAngle * progress, false, progressPaint);
//     }
//   }

//   @override
//   bool shouldRepaint(_HeroArcPainter o) => o.progress != progress;
// }
import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/router/route_names.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'package:intl/intl.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:permission_handler/permission_handler.dart';
import '../providers/dashboard_provider.dart';
import '../providers/dashboard_state.dart';
import '../providers/pedometer_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart' as provider;
import '../../../../providers/auth_provider.dart';
import '../../../../core/api_client.dart';
import '../widgets/milestone_celebration_overlay.dart';
import '../widgets/report_share_utils.dart';


// ───────────────────────────────────────────
//  DESIGN TOKENS
// ───────────────────────────────────────────
class _T {
  static const bg        = Color(0xFF0A0A0A);
  static const card      = Color(0xFF141414);
  static const card2     = Color(0xFF1C1C1C);
  static const divider   = Color(0xFF252525);
  static const hi        = Color(0xFFFFFFFF);
  static const mid       = Color(0xFF8A8A8A);
  static const lo        = Color(0xFF3A3A3A);
  static const accent    = Color(0xFFFF6B2B);
  static const accentDim = Color(0x1AFF6B2B);
  static const green     = Color(0xFF30D158);
  static const blue      = Color(0xFF0A84FF);
  static const purple    = Color(0xFFBF5AF2);
  static const gold      = Color(0xFFFFCC00);
  static const accentGrad = LinearGradient(
    colors: [Color(0xFFFF6B2B), Color(0xFFFF9A3C)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

extension _Txt on TextStyle {
  static TextStyle label = GoogleFonts.inter(
    fontSize: 11, fontWeight: FontWeight.w500,
    color: _T.mid, letterSpacing: 0.6,
  );
  static TextStyle body = GoogleFonts.inter(
    fontSize: 14, fontWeight: FontWeight.w400, color: _T.mid,
  );
  static TextStyle bodyBold = GoogleFonts.inter(
    fontSize: 14, fontWeight: FontWeight.w600, color: _T.hi,
  );
  static TextStyle title = GoogleFonts.inter(
    fontSize: 17, fontWeight: FontWeight.w600, color: _T.hi,
  );
  static TextStyle numSm = GoogleFonts.inter(
    fontSize: 20, fontWeight: FontWeight.w700, color: _T.hi,
    fontFeatures: [const FontFeature.tabularFigures()],
  );
}

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});
  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  int _tab = 0;
  int _statsSegment = 0; // 0=Day, 1=Week, 2=Month
  bool _isTracking = false; // ← play/pause state
  int _lastCompletedSteps = 0; // steps from last stopped session (survive cross-check zero)
  
  // Morning habit completion state (per-day)
  bool _habitTablet = false;
  bool _habitWater = false;
  bool _habitWalk = false;
  int _lastCelebratedMilestone = 0;
  late final AnimationController _ac;
  late final Animation<double> _ring;
  late final AnimationController _glowAc;
  late final Animation<double> _glow;
  late final AnimationController _habitPulseAc;
  late final Animation<double> _habitPulse;
  Timer? _midnightTimer; // fires at 00:00 to reset daily data

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarBrightness: Brightness.dark,
      statusBarIconBrightness: Brightness.light,
    ));
    _ac = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200))..forward();
    _ring = CurvedAnimation(parent: _ac, curve: Curves.easeOutQuart);
    _glowAc = AnimationController(vsync: this, duration: const Duration(milliseconds: 2000))
      ..repeat(reverse: true);
    _glow = CurvedAnimation(parent: _glowAc, curve: Curves.easeInOut);
    _habitPulseAc = AnimationController(vsync: this, duration: const Duration(milliseconds: 1500))
      ..repeat(reverse: true);
    _habitPulse = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _habitPulseAc, curve: Curves.easeInOut),
    );
    _checkActiveSession();
    _loadHabitState();
    _scheduleMidnightReset();
    _loadCompletedSteps(); // restore persisted step count after navigation/restart
    
    // Attach milestone controller & listen for milestones
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final pedNotifier = ref.read(pedometerProvider.notifier);
      final milestoneCtrl = ref.read(milestoneProvider.notifier);
      pedNotifier.attachMilestoneController(milestoneCtrl);
    });
  }

  /// Restore persisted completed steps from today (survives navigation & restarts)
  Future<void> _loadCompletedSteps() async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final savedDate = prefs.getString('completed_steps_date') ?? '';
    if (savedDate == today) {
      final saved = prefs.getInt('completed_steps_today') ?? 0;
      if (saved > 0) {
        setState(() => _lastCompletedSteps = saved);
        debugPrint('📱 Restored completed steps: $saved');
      }
    } else if (savedDate.isNotEmpty) {
      // Old date — clear stale data
      await prefs.remove('completed_steps_today');
      await prefs.remove('completed_steps_date');
    }
  }

  /// Load today's habit completion state from SharedPreferences + server
  Future<void> _loadHabitState() async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    
    // Load local state first (fast)
    bool tablet = prefs.getBool('habit_tablet_$today') ?? false;
    bool water = prefs.getBool('habit_water_$today') ?? false;
    bool walk = prefs.getBool('habit_walk_$today') ?? false;
    
    // SAFETY: If habits are marked done but we don't actually have 1000 steps, clear them
    // (they were set by a bug using stale API data)
    final liveSteps = ref.read(pedometerProvider).valueOrNull ?? 0;
    final apiSteps = ref.read(dashboardProvider).todayActivity?['steps'] ?? 0;
    final effectiveSteps = [liveSteps, apiSteps, _lastCompletedSteps].reduce((a, b) => a > b ? a : b);
    
    if ((tablet || water || walk) && effectiveSteps < 1000) {
      debugPrint('🧹 Clearing stale habit data for $today (effective steps $effectiveSteps < 1000)');
      tablet = false;
      water = false;
      walk = false;
      await prefs.remove('habit_tablet_$today');
      await prefs.remove('habit_water_$today');
      await prefs.remove('habit_walk_$today');
    }
    
    // Also check server for cross-device sync
    try {
      final dio = ApiClient().dio;
      final resp = await dio.get('/habits', queryParameters: {'date': today});
      var data = resp.data;
      if (data is String) {
        try { data = jsonDecode(data); } catch (_) {}
      }
      if (data is Map<String, dynamic>) {
        final serverTablet = data['tablet'] == true;
        final serverWater = data['water'] == true;
        final serverWalk = data['walk'] == true;
        // Merge: if either local or server says done, it's done
        tablet = tablet || serverTablet;
        water = water || serverWater;
        walk = walk || serverWalk;
        // Persist merged state locally
        await prefs.setBool('habit_tablet_$today', tablet);
        await prefs.setBool('habit_water_$today', water);
        await prefs.setBool('habit_walk_$today', walk);
      }
    } catch (e) {
      debugPrint('⚠️ Habits server fetch failed: $e');
    }
    
    if (mounted) {
      setState(() {
        _habitTablet = tablet;
        _habitWater = water;
        _habitWalk = walk;
      });
    }
    
    // Stop pulse animation if all done
    if (tablet && water && walk) {
      _habitPulseAc.stop();
    }
    
    // Auto-check habits if TOTAL daily steps >= 1000
    // Uses apiSteps (all previous sessions) + liveSteps (current session)
    final totalDailySteps = apiSteps + liveSteps;
    if (totalDailySteps >= 1000 && !tablet && !water && !walk) {
      _autoCompleteHabits();
    }
  }

  /// Sync habit state to server for cross-device access
  Future<void> _syncHabitsToServer() async {
    try {
      final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
      final dio = ApiClient().dio;
      await dio.post('/habits', data: {
        'date': today,
        'tablet': _habitTablet,
        'water': _habitWater,
        'walk': _habitWalk,
      });
      debugPrint('✅ Habits synced to server');
    } catch (e) {
      debugPrint('⚠️ Habits server sync failed: $e');
    }
  }

  /// Auto-complete all 3 habits with sequential celebrations
  Future<void> _autoCompleteHabits() async {
    if (_habitTablet && _habitWater && _habitWalk) return; // already done
    
    final prefs = await SharedPreferences.getInstance();
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    
    // Mark all as done locally
    await prefs.setBool('habit_tablet_$today', true);
    await prefs.setBool('habit_water_$today', true);
    await prefs.setBool('habit_walk_$today', true);
    
    if (!mounted) return;
    
    setState(() {
      _habitTablet = true;
      _habitWater = true;
      _habitWalk = true;
    });
    
    // Stop pulse since all done
    _habitPulseAc.stop();
    
    // Sync to server for cross-device
    _syncHabitsToServer();
    
    HapticFeedback.heavyImpact();
    
    // Show celebration for all habits completing
    MilestoneCelebrationOverlay.show(
      context,
      icon: '✅',
      title: 'All Habits Done!',
      subtitle: '💊 Tablet · 💧 Water · 🚶 Walk\nGreat start to the day!',
      accentColor: const Color(0xFF30D158),
    );
  }

  /// Schedule a timer to fire at midnight and reset all daily data
  void _scheduleMidnightReset() {
    _midnightTimer?.cancel();
    final now = DateTime.now();
    final nextMidnight = DateTime(now.year, now.month, now.day + 1);
    final duration = nextMidnight.difference(now);
    debugPrint('⏰ Midnight reset scheduled in ${duration.inMinutes} minutes');
    
    _midnightTimer = Timer(duration, () async {
      debugPrint('🌙 MIDNIGHT! Resetting daily data...');
      
      // 1. Reset pedometer steps to zero
      ref.read(pedometerProvider.notifier).resetForNewDay();
      
      // 2. Reset habit cards (new day = unchecked)
      if (mounted) {
        setState(() {
          _habitTablet = false;
          _habitWater = false;
          _habitWalk = false;
        });
        // Restart pulse animation for the new day
        if (!_habitPulseAc.isAnimating) {
          _habitPulseAc.repeat(reverse: true);
        }
      }
      
      // 3. Clear hourly step data for the new day
      final prefs = await SharedPreferences.getInstance();
      for (int h = 0; h < 24; h++) {
        await prefs.remove('hourly_steps_$h');
      }
      
      // 4. Refresh dashboard API data (will fetch new "today")
      ref.read(dashboardProvider.notifier).refresh();
      
      // 5. Schedule next midnight
      _scheduleMidnightReset();
    });
  }

  /// Handle app lifecycle — refresh tracking state when app resumes
  @override
  void didChangeAppLifecycleState(AppLifecycleState lifecycleState) {
    if (lifecycleState == AppLifecycleState.resumed) {
      _refreshTrackingState();
    }
  }

  /// Refresh tracking state from SharedPreferences when app comes to foreground
  Future<void> _refreshTrackingState() async {
    final prefs = await SharedPreferences.getInstance();
    final sessionId = prefs.getString('active_session_id');
    final hasSession = sessionId != null && sessionId.isNotEmpty;
    
    if (mounted) {
      setState(() {
        _isTracking = hasSession;
        if (_isTracking) {
          if (!_ac.isAnimating) _ac.repeat(reverse: true);
          if (!_glowAc.isAnimating) _glowAc.repeat(reverse: true);
        } else {
          _ac.stop();
          _glowAc.stop();
        }
      });
    }
    
    // Also reload habit states (user may have crossed midnight)
    _loadHabitState();
    
    // Re-schedule midnight timer (in case the old one expired while app was backgrounded)
    _scheduleMidnightReset();
    
    // Refresh dashboard API data (fetches fresh "today" data)
    ref.read(dashboardProvider.notifier).refresh();
    
    debugPrint('🔄 Dashboard resumed — tracking: $hasSession');
  }

  Future<void> _checkActiveSession() async {
    final prefs = await SharedPreferences.getInstance();
    final sessionId = prefs.getString('active_session_id');
    if (sessionId != null && sessionId.isNotEmpty) {
      // Resume pedometer tracking (it will recover accumulated steps)
      // The PedometerNotifier._recoverSession() handles this automatically
      if (mounted) {
        setState(() {
          _isTracking = true;
          _ac.repeat(reverse: true);
          _glowAc.repeat(reverse: true);
        });
      }
      
      // Ensure background service is running
      final service = FlutterBackgroundService();
      final isRunning = await service.isRunning();
      if (!isRunning) {
        debugPrint('🔄 Restarting background service on session recovery');
        service.startService();
      }
      
      // Start auto-refreshing stats since we have an active session
      ref.read(dashboardProvider.notifier).startAutoRefresh();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _ac.dispose();
    _glowAc.dispose();
    _habitPulseAc.dispose();
    _midnightTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(dashboardProvider);
    final pedometerState = ref.watch(pedometerProvider);
    final sessionSteps = pedometerState.valueOrNull ?? 0;
    
    // Listen for milestone events and show celebrations
    ref.listen<int>(milestoneProvider, (prev, next) {
      if (next > 0 && next != _lastCelebratedMilestone) {
        _lastCelebratedMilestone = next;
        
        // At 1000 steps: auto-complete all morning habits
        if (next >= 1000 && (!_habitTablet || !_habitWater || !_habitWalk)) {
          _autoCompleteHabits();
        } else {
          // Other milestones: just show the step celebration
          MilestoneCelebrationOverlay.show(
            context,
            icon: '🏆',
            title: '$next Steps!',
            subtitle: 'Amazing progress, keep going!',
            accentColor: const Color(0xFFFFCC00),
          );
        }
      }
    });
    
    // Also check TOTAL daily steps for habit auto-complete
    // (handles case where 1000 steps are spread across multiple sessions)
    if (_isTracking && (!_habitTablet || !_habitWater || !_habitWalk)) {
      final apiSteps = (state.todayActivity?['steps'] ?? 0) as num;
      final totalDailySteps = apiSteps.toInt() + sessionSteps;
      if (totalDailySteps >= 1000) {
        // Use addPostFrameCallback to avoid setState during build
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted && (!_habitTablet || !_habitWater || !_habitWalk)) {
            _autoCompleteHabits();
          }
        });
      }
    }
    
    return Scaffold(
      backgroundColor: _T.bg,
      extendBody: true,
      body: SafeArea(bottom: false, child: _body(state, sessionSteps)),
      bottomNavigationBar: _bottomPill(),
      // FAB only on Home tab
      floatingActionButton: _tab == 0 ? _continueFab() : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  Widget _body(DashboardState state, int sessionSteps) {
    switch (_tab) {
      case 1: return _reportsTab();   // ← Reports tab
      case 2: return _statsTab(state);
      case 3: return _youTab();
      default: return _homeTab(state, sessionSteps);
    }
  }

  // State for stats date navigation
  DateTime _statsDate = DateTime.now();

  Widget _statsTab(DashboardState state) {
    if (state.isLoading) return const Center(child: CircularProgressIndicator(color: Color(0xFFFF6B2B)));

    final segments = ['Day', 'Week', 'Month'];

    return ListView(
      padding: const EdgeInsets.fromLTRB(22, 20, 22, 110),
      children: [
        // ── Title ──
        Text('STATS', style: _Txt.label),
        const SizedBox(height: 3),
        Text('Your Activity', style: GoogleFonts.inter(fontSize: 22, fontWeight: FontWeight.w800, color: _T.hi)),
        const SizedBox(height: 16),

        // ── Segmented Control ──
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: _T.card,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            children: List.generate(3, (i) {
              final isActive = _statsSegment == i;
              return Expanded(
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _statsSegment = i;
                      _statsDate = DateTime.now();
                    });
                    _fetchStatsForSegment(i, DateTime.now());
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: isActive ? _T.accent : Colors.transparent,
                      borderRadius: BorderRadius.circular(11),
                    ),
                    child: Center(
                      child: Text(
                        segments[i],
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: isActive ? Colors.white : _T.mid,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
        const SizedBox(height: 14),

        // ── Date Picker: depends on segment ──
        if (_statsSegment == 0) _dayDatePicker(),
        if (_statsSegment == 1) _weekDatePicker(),
        if (_statsSegment == 2) _monthDatePicker(),
        const SizedBox(height: 20),

        // ── Content based on segment ──
        if (_statsSegment == 0) ..._statsDayView(state),
        if (_statsSegment == 1) ..._statsWeekView(state),
        if (_statsSegment == 2) ..._statsMonthView(state),
      ],
    );
  }

  // ── DAY: left/right arrows with date ──
  Widget _dayDatePicker() {
    final label = DateFormat('EEEE, d MMMM yyyy').format(_statsDate);
    final now = DateTime.now();
    final canForward = _statsDate.isBefore(DateTime(now.year, now.month, now.day));
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
      decoration: BoxDecoration(color: _T.card, borderRadius: BorderRadius.circular(14), border: Border.all(color: _T.divider)),
      child: Row(children: [
        _navArrow(Icons.chevron_left_rounded, () {
          setState(() => _statsDate = _statsDate.subtract(const Duration(days: 1)));
        }),
        const SizedBox(width: 8),
        Expanded(child: Center(child: Text(label, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: _T.hi)))),
        const SizedBox(width: 8),
        _navArrow(Icons.chevron_right_rounded, canForward ? () {
          setState(() => _statsDate = _statsDate.add(const Duration(days: 1)));
        } : null),
      ]),
    );
  }

  // ── WEEK: Scrollable chips of week ranges ──
  Widget _weekDatePicker() {
    final now = DateTime.now();
    // Generate last 8 weeks
    final List<DateTime> weekStarts = [];
    DateTime ws = now.subtract(Duration(days: now.weekday - 1)); // current week Monday
    for (int i = 0; i < 8; i++) {
      weekStarts.insert(0, ws);
      ws = ws.subtract(const Duration(days: 7));
    }

    final selectedWeekStart = _statsDate.subtract(Duration(days: _statsDate.weekday - 1));
    final selectedKey = DateFormat('yyyy-MM-dd').format(selectedWeekStart);

    return SizedBox(
      height: 42,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: weekStarts.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (ctx, i) {
          final wStart = weekStarts[i];
          final wEnd = wStart.add(const Duration(days: 6));
          final key = DateFormat('yyyy-MM-dd').format(wStart);
          final isActive = key == selectedKey;
          final label = '${DateFormat('d MMM').format(wStart)} – ${DateFormat('d MMM').format(wEnd)}';

          return GestureDetector(
            onTap: () {
              setState(() => _statsDate = wStart);
              _fetchStatsForSegment(1, wStart);
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: isActive ? _T.accent : _T.card,
                borderRadius: BorderRadius.circular(12),
                border: isActive ? null : Border.all(color: _T.divider),
              ),
              child: Center(
                child: Text(label, style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: isActive ? Colors.white : _T.mid)),
              ),
            ),
          );
        },
      ),
    );
  }

  // ── MONTH: Horizontal pills Jan–Dec ──
  Widget _monthDatePicker() {
    final now = DateTime.now();
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    final selectedMonth = _statsDate.month;
    final selectedYear = _statsDate.year;

    return Column(children: [
      // Year selector
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
        decoration: BoxDecoration(color: _T.card, borderRadius: BorderRadius.circular(14), border: Border.all(color: _T.divider)),
        child: Row(children: [
          _navArrow(Icons.chevron_left_rounded, () {
            setState(() => _statsDate = DateTime(selectedYear - 1, selectedMonth, 1));
            _fetchStatsForSegment(2, DateTime(selectedYear - 1, selectedMonth, 1));
          }),
          const SizedBox(width: 8),
          Expanded(child: Center(child: Text('$selectedYear', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700, color: _T.hi)))),
          const SizedBox(width: 8),
          _navArrow(Icons.chevron_right_rounded, selectedYear < now.year ? () {
            setState(() => _statsDate = DateTime(selectedYear + 1, selectedMonth, 1));
            _fetchStatsForSegment(2, DateTime(selectedYear + 1, selectedMonth, 1));
          } : null),
        ]),
      ),
      const SizedBox(height: 10),
      // Month pills
      SizedBox(
        height: 38,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: 12,
          separatorBuilder: (_, __) => const SizedBox(width: 6),
          itemBuilder: (ctx, i) {
            final m = i + 1;
            final isActive = m == selectedMonth;
            // Disable future months of the current year
            final isDisabled = selectedYear == now.year && m > now.month;

            return GestureDetector(
              onTap: isDisabled ? null : () {
                setState(() => _statsDate = DateTime(selectedYear, m, 1));
                _fetchStatsForSegment(2, DateTime(selectedYear, m, 1));
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: isActive ? _T.accent : _T.card,
                  borderRadius: BorderRadius.circular(10),
                  border: isActive ? null : Border.all(color: isDisabled ? _T.divider.withOpacity(0.3) : _T.divider),
                ),
                child: Center(
                  child: Text(
                    months[i],
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isActive ? Colors.white : (isDisabled ? _T.lo : _T.mid),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    ]);
  }

  Widget _navArrow(IconData icon, VoidCallback? onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36, height: 36,
        decoration: BoxDecoration(color: onTap != null ? _T.card2 : _T.card, borderRadius: BorderRadius.circular(10)),
        child: Icon(icon, color: onTap != null ? _T.hi : _T.lo, size: 22),
      ),
    );
  }

  bool _canNavigateForward() {
    final now = DateTime.now();
    switch (_statsSegment) {
      case 0: return _statsDate.isBefore(DateTime(now.year, now.month, now.day));
      case 1:
        final weekStart = _statsDate.subtract(Duration(days: _statsDate.weekday - 1));
        final currentWeekStart = now.subtract(Duration(days: now.weekday - 1));
        return weekStart.isBefore(currentWeekStart);
      case 2:
        return _statsDate.year < now.year || (_statsDate.year == now.year && _statsDate.month < now.month);
      default: return false;
    }
  }

  void _navigateStats(int direction) {
    DateTime newDate;
    switch (_statsSegment) {
      case 0: // Day: +/- 1 day
        newDate = _statsDate.add(Duration(days: direction));
        break;
      case 1: // Week: +/- 7 days
        newDate = _statsDate.add(Duration(days: 7 * direction));
        break;
      default: // Month: +/- 1 month
        newDate = DateTime(_statsDate.year, _statsDate.month + direction, _statsDate.day);
    }
    setState(() => _statsDate = newDate);
    _fetchStatsForSegment(_statsSegment, newDate);
  }

  void _fetchStatsForSegment(int segment, DateTime date) {
    final notifier = ref.read(dashboardProvider.notifier);
    switch (segment) {
      case 1: // Week
        final weekStart = date.subtract(Duration(days: date.weekday - 1));
        final weekEnd = weekStart.add(const Duration(days: 6));
        notifier.fetchWeeklyStats(weekStart, weekEnd);
        break;
      case 2: // Month
        final monthStart = DateTime(date.year, date.month, 1);
        final monthEnd = DateTime(date.year, date.month + 1, 0);
        notifier.fetchMonthlyStats(monthStart, monthEnd);
        break;
      // Day: uses todayActivity, already loaded
    }
  }

  // ────────────────────────────── DAY VIEW ──────────────────────────────
  List<Widget> _statsDayView(DashboardState state) {
    final today = state.todayActivity ?? {};
    final steps = today['steps'] ?? 0;
    final calories = today['calories'] ?? 0;
    final distance = today['distance'] ?? 0;
    final activeMinutes = today['activeMinutes'] ?? 0;
    final goal = today['goalSteps'] ?? 10000;
    final progress = goal > 0 ? (steps / goal).clamp(0.0, 1.0) : 0.0;

    return [
      // Summary cards
      Row(
        children: [
          Expanded(child: _statSummaryCard(icon: Icons.directions_walk_rounded, value: _formatSteps(steps), label: 'Steps', color: _T.green)),
          const SizedBox(width: 12),
          Expanded(child: _statSummaryCard(icon: Icons.local_fire_department_rounded, value: calories.toString(), label: 'Calories', color: _T.accent)),
          const SizedBox(width: 12),
          Expanded(child: _statSummaryCard(icon: Icons.timer_outlined, value: '${activeMinutes}m', label: 'Active', color: _T.blue)),
        ],
      ),
      const SizedBox(height: 20),

      // Goal progress
      Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(color: _T.card, borderRadius: BorderRadius.circular(20)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Daily Goal', style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w700, color: _T.hi)),
                Text('$steps / ${_formatSteps(goal)}', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: _T.accent)),
              ],
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: progress.toDouble(),
                minHeight: 8,
                backgroundColor: _T.divider,
                valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFFF6B2B)),
              ),
            ),
            const SizedBox(height: 8),
            Text('${(progress * 100).toStringAsFixed(0)}% completed', style: GoogleFonts.inter(fontSize: 11, color: _T.mid)),
          ],
        ),
      ),
      const SizedBox(height: 16),

      // Distance card
      Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(color: _T.card, borderRadius: BorderRadius.circular(20)),
        child: Row(
          children: [
            Container(
              width: 44, height: 44,
              decoration: BoxDecoration(color: _T.purple.withOpacity(0.12), borderRadius: BorderRadius.circular(14)),
              child: const Icon(Icons.straighten_rounded, color: _T.purple, size: 22),
            ),
            const SizedBox(width: 14),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('$distance km', style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w800, color: _T.hi)),
                Text('Distance walked', style: GoogleFonts.inter(fontSize: 11, color: _T.mid)),
              ],
            ),
          ],
        ),
      ),
    ];
  }

  // ────────────────────────────── WEEK VIEW ──────────────────────────────
  List<Widget> _statsWeekView(DashboardState state) {
    final weeklyData = state.weeklyStats ?? {};
    final daysList = (weeklyData['days'] as List<dynamic>?) ?? [];
    final totalSteps = weeklyData['totalSteps'] ?? 0;
    final totalCalories = weeklyData['totalCalories'] ?? 0;
    final avgStepsPerDay = weeklyData['avgStepsPerDay'] ?? 0;

    return [
      Row(
        children: [
          Expanded(child: _statSummaryCard(icon: Icons.directions_walk_rounded, value: _formatSteps(totalSteps), label: 'Total Steps', color: _T.green)),
          const SizedBox(width: 12),
          Expanded(child: _statSummaryCard(icon: Icons.local_fire_department_rounded, value: totalCalories.toString(), label: 'Calories', color: _T.accent)),
          const SizedBox(width: 12),
          Expanded(child: _statSummaryCard(icon: Icons.speed_rounded, value: _formatSteps(avgStepsPerDay), label: 'Avg/Day', color: _T.blue)),
        ],
      ),
      const SizedBox(height: 20),

      // Daily breakdown
      Text('Daily Breakdown', style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w700, color: _T.hi)),
      const SizedBox(height: 12),
      if (daysList.isEmpty)
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(color: _T.card, borderRadius: BorderRadius.circular(20)),
          child: Center(child: Text('No data this week.', style: GoogleFonts.inter(color: _T.mid))),
        ),
      ...daysList.map((d) {
        final day = d as Map<String, dynamic>;
        final dateStr = day['date'] ?? '';
        final steps = day['steps'] ?? 0;
        final cals = day['calories'] ?? 0;

        String label = dateStr;
        bool isToday = false;
        try {
          final dt = DateTime.parse(dateStr);
          label = DateFormat('EEE, d MMM').format(dt);
          isToday = DateFormat('yyyy-MM-dd').format(dt) == DateFormat('yyyy-MM-dd').format(DateTime.now());
        } catch (_) {}

        final maxSteps = daysList.fold<int>(0, (prev, d2) {
          final s = (d2 as Map<String, dynamic>)['steps'] ?? 0;
          return (s as int) > prev ? s : prev;
        });
        final progress = maxSteps > 0 ? (steps / maxSteps).clamp(0.0, 1.0) : 0.0;

        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: _T.card,
            borderRadius: BorderRadius.circular(16),
            border: isToday ? Border.all(color: _T.accent.withOpacity(0.4), width: 1) : null,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(children: [
                    if (isToday) ...[Container(width: 6, height: 6, decoration: const BoxDecoration(color: _T.accent, shape: BoxShape.circle)), const SizedBox(width: 6)],
                    Text(label, style: GoogleFonts.inter(fontSize: 13, fontWeight: isToday ? FontWeight.w700 : FontWeight.w500, color: isToday ? _T.accent : _T.hi)),
                  ]),
                  Text('$steps steps · $cals kcal', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: _T.mid)),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: progress.toDouble(),
                  minHeight: 5,
                  backgroundColor: _T.divider,
                  valueColor: AlwaysStoppedAnimation<Color>(isToday ? _T.accent : _T.green),
                ),
              ),
            ],
          ),
        );
      }),
    ];
  }

  // ────────────────────────────── MONTH VIEW ──────────────────────────────
  List<Widget> _statsMonthView(DashboardState state) {
    final history = state.history ?? [];
    final monthlyData = state.monthlyStats ?? {};
    final weeks = (monthlyData['weeks'] as List<dynamic>?) ?? [];
    final totalSteps = monthlyData['totalSteps'] ?? 0;
    final totalCalories = monthlyData['totalCalories'] ?? 0;
    final avgStepsPerDay = monthlyData['avgStepsPerDay'] ?? 0;

    return [
      Row(
        children: [
          Expanded(child: _statSummaryCard(icon: Icons.directions_walk_rounded, value: _formatSteps(totalSteps), label: 'Total Steps', color: _T.green)),
          const SizedBox(width: 12),
          Expanded(child: _statSummaryCard(icon: Icons.local_fire_department_rounded, value: totalCalories.toString(), label: 'Calories', color: _T.accent)),
          const SizedBox(width: 12),
          Expanded(child: _statSummaryCard(icon: Icons.speed_rounded, value: _formatSteps(avgStepsPerDay), label: 'Avg/Day', color: _T.blue)),
        ],
      ),
      const SizedBox(height: 20),

      Text('Weekly Breakdown', style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w700, color: _T.hi)),
      const SizedBox(height: 12),
      if (weeks.isEmpty)
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(color: _T.card, borderRadius: BorderRadius.circular(20)),
          child: Center(child: Text('No monthly data yet.', style: GoogleFonts.inter(color: _T.mid))),
        ),
      ...weeks.asMap().entries.map((entry) {
        final i = entry.key;
        final w = entry.value as Map<String, dynamic>;
        final wStart = w['weekStart'] ?? '';
        final wEnd = w['weekEnd'] ?? '';
        final wSteps = w['steps'] ?? 0;
        final wCals = w['calories'] ?? 0;

        String weekLabel = 'Week ${i + 1}';
        try {
          final startDate = DateTime.parse(wStart);
          final endDate = DateTime.parse(wEnd);
          weekLabel = '${DateFormat('d MMM').format(startDate)} – ${DateFormat('d MMM').format(endDate)}';
        } catch (_) {}

        final maxSteps = weeks.fold<int>(0, (prev, w2) {
          final s = (w2 as Map<String, dynamic>)['steps'] ?? 0;
          return (s as int) > prev ? s : prev;
        });
        final progress = maxSteps > 0 ? (wSteps / maxSteps).clamp(0.0, 1.0) : 0.0;

        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: _T.card, borderRadius: BorderRadius.circular(18)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(weekLabel, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: _T.hi)),
                  Text('$wSteps steps', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w700, color: _T.accent)),
                ],
              ),
              const SizedBox(height: 10),
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(
                  value: progress.toDouble(),
                  minHeight: 6,
                  backgroundColor: _T.divider,
                  valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFFF6B2B)),
                ),
              ),
              const SizedBox(height: 8),
              Text('$wCals kcal burned', style: GoogleFonts.inter(fontSize: 11, color: _T.mid)),
            ],
          ),
        );
      }),

      // Activity History
      const SizedBox(height: 20),
      Text('Activity History', style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w700, color: _T.hi)),
      const SizedBox(height: 12),
      if (history.isEmpty)
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(color: _T.card, borderRadius: BorderRadius.circular(20)),
          child: Center(child: Text('No sessions recorded yet.', style: GoogleFonts.inter(color: _T.mid))),
        ),
      ...history.map((h) {
        final steps = h['steps'] ?? 0;
        final calories = h['calories'] ?? 0;
        final duration = h['duration'] ?? 0;
        final startTime = h['startTime'] ?? h['start_time'] ?? '';

        String dateLabel = startTime.toString();
        try {
          final dt = DateTime.parse(startTime);
          dateLabel = DateFormat('d MMM, h:mm a').format(dt);
        } catch (_) {}

        String durationLabel = '${duration}s';
        if (duration >= 60) durationLabel = '${(duration / 60).round()}m';
        if (duration >= 3600) durationLabel = '${(duration / 3600).toStringAsFixed(1)}h';

        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: _T.card, borderRadius: BorderRadius.circular(18)),
          child: Row(
            children: [
              Container(
                width: 44, height: 44,
                decoration: BoxDecoration(color: _T.accent.withOpacity(0.12), borderRadius: BorderRadius.circular(14)),
                child: const Icon(Icons.directions_walk_rounded, color: _T.accent, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('$steps steps · $calories kcal', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: _T.hi)),
                  const SizedBox(height: 3),
                  Text(dateLabel, style: GoogleFonts.inter(fontSize: 11, color: _T.mid)),
                ],
              )),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(color: _T.green.withOpacity(0.12), borderRadius: BorderRadius.circular(10)),
                child: Text(durationLabel, style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700, color: _T.green)),
              ),
            ],
          ),
        );
      }),
    ];
  }

  String _formatSteps(dynamic steps) {
    final n = steps is int ? steps : int.tryParse(steps.toString()) ?? 0;
    if (n >= 1000) return '${(n / 1000).toStringAsFixed(1)}k';
    return n.toString();
  }

  Widget _statSummaryCard({required IconData icon, required String value, required String label, required Color color}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _T.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.15)),
      ),
      child: Column(
        children: [
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(11)),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(height: 10),
          Text(value, style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w800, color: _T.hi)),
          const SizedBox(height: 3),
          Text(label, style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w500, color: _T.mid)),
        ],
      ),
    );
  }

  Widget _placeholderTab(String name) => Center(
    child: Text(name, style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w600, color: _T.mid)),
  );

  Widget _youTab() => const SizedBox.shrink();



  // ══════════════════════════════════════════════════════════
  //  REPORTS TAB — Day / Week / Month reports + Share
  // ══════════════════════════════════════════════════════════
  int _reportSegment = 0; // 0=Day, 1=Week, 2=Month
  DateTime _reportDate = DateTime.now();
  Map<String, dynamic>? _reportData;
  bool _reportLoading = false;
  bool _shareLoading = false;

  Widget _reportsTab() {
    final segments = ['Day', 'Last 7 Days', 'Month'];
    final shareTypes = ['daily', 'weekly', 'monthly'];

    // Date subtitle for current segment
    String dateSubtitle;
    switch (_reportSegment) {
      case 0:
        dateSubtitle = DateFormat('EEEE, d MMMM yyyy').format(_reportDate);
        break;
      case 1:
        // Last 7 days — always relative to today, no date picker
        final last7Start = DateTime.now().subtract(const Duration(days: 6));
        final last7End = DateTime.now();
        dateSubtitle = '${DateFormat('d MMM').format(last7Start)} – ${DateFormat('d MMM').format(last7End)}, ${last7End.year}';
        break;
      default:
        dateSubtitle = DateFormat('MMMM yyyy').format(_reportDate);
    }

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(22, 20, 22, 110),
        children: [
          Text('REPORTS', style: _Txt.label),
          const SizedBox(height: 3),
          Text('Activity Reports', style: GoogleFonts.inter(fontSize: 22, fontWeight: FontWeight.w800, color: _T.hi)),
          const SizedBox(height: 16),

          // Segmented control
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(color: _T.card, borderRadius: BorderRadius.circular(14)),
            child: Row(
              children: List.generate(3, (i) {
                final isActive = _reportSegment == i;
                return Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() { _reportSegment = i; _reportData = null; });
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: isActive ? _T.accent : Colors.transparent,
                        borderRadius: BorderRadius.circular(11),
                      ),
                      child: Center(
                        child: Text(segments[i], style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: isActive ? Colors.white : _T.mid)),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
          const SizedBox(height: 14),

          // Date picker — hidden for "Last 7 Days" (always uses today - 6 days)
          if (_reportSegment != 1)
            GestureDetector(
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: _reportDate,
                  firstDate: DateTime(2024),
                  lastDate: DateTime.now(),
                  builder: (ctx, child) => Theme(
                    data: ThemeData.dark().copyWith(
                      colorScheme: const ColorScheme.dark(primary: Color(0xFFFF6B2B), onPrimary: Colors.white, surface: Color(0xFF141414), onSurface: Colors.white),
                      dialogBackgroundColor: const Color(0xFF141414),
                    ),
                    child: child!,
                  ),
                );
                if (picked != null) {
                  setState(() { _reportDate = picked; _reportData = null; });
                }
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(color: _T.card, borderRadius: BorderRadius.circular(16), border: Border.all(color: _T.divider)),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today_rounded, color: _T.accent, size: 18),
                    const SizedBox(width: 12),
                    Expanded(child: Text(dateSubtitle, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: _T.hi))),
                    const Icon(Icons.chevron_right_rounded, color: _T.mid, size: 20),
                  ],
                ),
              ),
            ),
          // "Last 7 Days" static label
          if (_reportSegment == 1)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(color: _T.accent.withOpacity(0.08), borderRadius: BorderRadius.circular(16), border: Border.all(color: _T.accent.withOpacity(0.2))),
              child: Row(
                children: [
                  const Icon(Icons.date_range_rounded, color: _T.accent, size: 18),
                  const SizedBox(width: 12),
                  Expanded(child: Text(dateSubtitle, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700, color: _T.accent))),
                ],
              ),
            ),
          const SizedBox(height: 12),

          // Fetch + Share buttons row
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: _reportLoading ? null : _fetchReport,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(gradient: _T.accentGrad, borderRadius: BorderRadius.circular(16)),
                    child: Center(
                      child: _reportLoading
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : Text('Fetch Report', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white)),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              GestureDetector(
                onTap: (_shareLoading || _reportData == null) ? null : () => _shareReport(shareTypes[_reportSegment]),
                child: Container(
                  width: 52, height: 48,
                  decoration: BoxDecoration(
                    color: _reportData != null ? _T.green.withOpacity(0.15) : _T.card,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: _reportData != null ? _T.green.withOpacity(0.3) : _T.divider),
                  ),
                  child: _shareLoading
                    ? const Center(child: SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: _T.green)))
                    : Icon(Icons.share_rounded, color: _reportData != null ? _T.green : _T.lo, size: 20),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Report content (wrapped in RepaintBoundary for screenshot capture)
          if (_reportData != null)
            RepaintBoundary(
              key: _reportCardKey,
              child: ShareableReportCard(
                reportType: segments[_reportSegment],
                dateLabel: dateSubtitle,
                data: _reportData!,
                segment: _reportSegment,
              ),
            ),
          if (_reportData != null) const SizedBox(height: 16),
          if (_reportData != null) ..._buildReportContent(),
          if (_reportData == null && !_reportLoading)
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(color: _T.card, borderRadius: BorderRadius.circular(20)),
              child: Column(
                children: [
                  Icon(Icons.assessment_rounded, color: _T.lo, size: 40),
                  const SizedBox(height: 12),
                  Text('Select a date and tap Fetch Report', style: GoogleFonts.inter(color: _T.mid, fontSize: 13)),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _fetchReport() async {
    setState(() { _reportLoading = true; });
    try {
      final ds = ref.read(remoteDatasourceProvider);
      Map<String, dynamic> data;
      switch (_reportSegment) {
        case 0:
          final dateStr = DateFormat('yyyy-MM-dd').format(_reportDate);
          debugPrint('📡 DAILY → GET /reports/daily?date=$dateStr');
          data = await ds.getDailyReport(dateStr);
          break;
        case 1:
          // Last 7 Days — always use today minus 6 days
          final last7Start = DateTime.now().subtract(const Duration(days: 6));
          final weekStr = DateFormat('yyyy-MM-dd').format(last7Start);
          debugPrint('📡 WEEKLY (Last 7 Days) → GET /reports/weekly?week=$weekStr');
          data = await ds.getWeeklyReport(weekStr);
          break;
        default:
          final monthStr = DateFormat('yyyy-MM').format(_reportDate);
          debugPrint('📡 MONTHLY → GET /reports/monthly?month=$monthStr');
          data = await ds.getMonthlyReport(monthStr);
      }
      debugPrint('✅ REPORT response: $data');
      setState(() { _reportData = data; _reportLoading = false; });
    } catch (e) {
      debugPrint('❌ REPORT error: $e');
      if (e is DioException) {
        debugPrint('❌ Status: ${e.response?.statusCode}');
        debugPrint('❌ Response body: ${e.response?.data}');
        debugPrint('❌ Response body type: ${e.response?.data?.runtimeType}');
        debugPrint('❌ Response headers: ${e.response?.headers}');
        debugPrint('❌ Request URL: ${e.requestOptions.uri}');
        debugPrint('❌ Request headers: ${e.requestOptions.headers}');
      }
      setState(() { _reportLoading = false; });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Failed to load report', style: GoogleFonts.inter(color: Colors.white)),
          backgroundColor: Colors.redAccent, behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), margin: const EdgeInsets.all(16),
        ));
      }
    }
  }

  final GlobalKey _reportCardKey = GlobalKey();

  Future<void> _shareReport(String type) async {
    if (_reportData == null) return;
    
    final segments = ['Daily', 'Weekly', 'Monthly'];
    final reportType = segments[_reportSegment];
    
    String dateLabel;
    switch (_reportSegment) {
      case 0:
        dateLabel = DateFormat('EEEE, d MMMM yyyy').format(_reportDate);
        break;
      case 1:
        final shareStart = DateTime.now().subtract(const Duration(days: 6));
        final shareEnd = DateTime.now();
        dateLabel = '${DateFormat('d MMM').format(shareStart)} \u2013 ${DateFormat('d MMM').format(shareEnd)}, ${shareEnd.year}';
        break;
      default:
        dateLabel = DateFormat('MMMM yyyy').format(_reportDate);
    }
    
    if (!mounted) return;
    
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        decoration: const BoxDecoration(
          color: Color(0xFF141414),
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        padding: EdgeInsets.fromLTRB(24, 16, 24, MediaQuery.of(context).padding.bottom + 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 36, height: 4, decoration: BoxDecoration(color: _T.lo, borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 20),
            Row(children: [
              const Icon(Icons.share_rounded, color: _T.green, size: 22),
              const SizedBox(width: 12),
              Text('Share Report', style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w700, color: _T.hi)),
            ]),
            const SizedBox(height: 20),
            _shareOptionTile(
              icon: Icons.picture_as_pdf_rounded,
              iconColor: const Color(0xFFFF4444),
              title: 'Download as PDF',
              subtitle: 'Beautiful branded report document',
              onTap: () async {
                Navigator.pop(context);
                setState(() { _shareLoading = true; });
                try {
                  await ReportShareUtils.sharePdf(reportType: reportType, dateLabel: dateLabel, data: _reportData!, segment: _reportSegment);
                } catch (e) {
                  debugPrint('\u274c PDF error: $e');
                  if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to generate PDF', style: GoogleFonts.inter(color: Colors.white)), backgroundColor: Colors.redAccent, behavior: SnackBarBehavior.floating, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), margin: const EdgeInsets.all(16)));
                }
                if (mounted) setState(() { _shareLoading = false; });
              },
            ),
            const SizedBox(height: 12),
            _shareOptionTile(
              icon: Icons.camera_alt_rounded,
              iconColor: const Color(0xFF0A84FF),
              title: 'Share as Image',
              subtitle: 'Share on WhatsApp, Instagram, etc.',
              onTap: () async {
                Navigator.pop(context);
                setState(() { _shareLoading = true; });
                try {
                  await Future.delayed(const Duration(milliseconds: 300));
                  await ReportShareUtils.captureAndShare(_reportCardKey);
                } catch (e) {
                  debugPrint('\u274c Screenshot error: $e');
                  if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to capture screenshot', style: GoogleFonts.inter(color: Colors.white)), backgroundColor: Colors.redAccent, behavior: SnackBarBehavior.floating, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), margin: const EdgeInsets.all(16)));
                }
                if (mounted) setState(() { _shareLoading = false; });
              },
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _shareOptionTile({required IconData icon, required Color iconColor, required String title, required String subtitle, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: _T.bg, borderRadius: BorderRadius.circular(18), border: Border.all(color: _T.divider)),
        child: Row(children: [
          Container(width: 44, height: 44, decoration: BoxDecoration(color: iconColor.withOpacity(0.12), borderRadius: BorderRadius.circular(14)), child: Icon(icon, color: iconColor, size: 22)),
          const SizedBox(width: 14),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700, color: _T.hi)),
            const SizedBox(height: 2),
            Text(subtitle, style: GoogleFonts.inter(fontSize: 11, color: _T.mid)),
          ])),
          const Icon(Icons.chevron_right_rounded, color: _T.mid, size: 20),
        ]),
      ),
    );
  }


  List<Widget> _buildReportContent() {
    final d = _reportData!;

    switch (_reportSegment) {
      case 0: return _buildDailyReport(d);
      case 1: return _buildWeeklyReport(d);
      case 2: return _buildMonthlyReport(d);
      default: return [];
    }
  }

  // ── DAILY REPORT ──
  List<Widget> _buildDailyReport(Map<String, dynamic> d) {
    final steps = d['steps'] ?? 0;
    final calories = d['calories'] ?? 0;
    final distance = d['distance'] ?? 0;
    final activeMinutes = d['activeMinutes'] ?? 0;
    final goalAchieved = d['goalAchieved'] ?? false;
    final date = d['date'] ?? '';

    return [
      _goalBadge(goalAchieved, date),
      const SizedBox(height: 16),
      Row(children: [
        Expanded(child: _statSummaryCard(icon: Icons.directions_walk_rounded, value: _formatSteps(steps), label: 'Steps', color: _T.green)),
        const SizedBox(width: 12),
        Expanded(child: _statSummaryCard(icon: Icons.local_fire_department_rounded, value: calories.toString(), label: 'Calories', color: _T.accent)),
      ]),
      const SizedBox(height: 12),
      Row(children: [
        Expanded(child: _statSummaryCard(icon: Icons.straighten_rounded, value: '$distance', label: 'Distance (km)', color: _T.purple)),
        const SizedBox(width: 12),
        Expanded(child: _statSummaryCard(icon: Icons.timer_outlined, value: '${activeMinutes}m', label: 'Active Mins', color: _T.blue)),
      ]),
    ];
  }

  // ── WEEKLY REPORT ──
  List<Widget> _buildWeeklyReport(Map<String, dynamic> d) {
    final weekStart = d['weekStart'] ?? '';
    final weekEnd = d['weekEnd'] ?? '';
    final dailyData = (d['dailyData'] as List<dynamic>?) ?? [];
    final totalSteps = d['totalSteps'] ?? 0;
    final totalCalories = d['totalCalories'] ?? 0;

    String rangeLabel = '$weekStart → $weekEnd';
    try {
      final s = DateTime.parse(weekStart);
      final e = DateTime.parse(weekEnd);
      rangeLabel = '${DateFormat('d MMM').format(s)} – ${DateFormat('d MMM').format(e)}';
    } catch (_) {}

    return [
      // Range header
      Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: _T.accent.withOpacity(0.08), borderRadius: BorderRadius.circular(18), border: Border.all(color: _T.accent.withOpacity(0.2))),
        child: Row(children: [
          const Icon(Icons.date_range_rounded, color: _T.accent, size: 22),
          const SizedBox(width: 12),
          Text(rangeLabel, style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w700, color: _T.accent)),
        ]),
      ),
      const SizedBox(height: 16),
      // Show averages for Last 7 Days — 3 cards in one row
      () {
        final dayCount = dailyData.isNotEmpty ? dailyData.length : 7;
        final avgSteps = dayCount > 0 ? (totalSteps / dayCount).round() : 0;
        final avgCals = dayCount > 0 ? (totalCalories / dayCount).round() : 0;
        // Count days where any habit/tablet was taken (fallback: count active days)
        final activeDays = dailyData.where((d) => ((d as Map)['steps'] ?? 0) > 0).length;
        return Row(children: [
          Expanded(child: _statSummaryCard(icon: Icons.directions_walk_rounded, value: _formatSteps(avgSteps), label: 'Avg Steps', color: _T.green)),
          const SizedBox(width: 10),
          Expanded(child: _statSummaryCard(icon: Icons.local_fire_department_rounded, value: avgCals.toString(), label: 'Avg Calories', color: _T.accent)),
          const SizedBox(width: 10),
          Expanded(child: _statSummaryCard(icon: Icons.medication_rounded, value: '$activeDays / $dayCount', label: 'Avg Tablets', color: _T.blue)),
        ]);
      }(),
      const SizedBox(height: 20),
      Text('Daily Breakdown', style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w700, color: _T.hi)),
      const SizedBox(height: 12),
      if (dailyData.isEmpty)
        Container(padding: const EdgeInsets.all(24), decoration: BoxDecoration(color: _T.card, borderRadius: BorderRadius.circular(20)),
          child: Center(child: Text('No daily data.', style: GoogleFonts.inter(color: _T.mid)))),
      ...dailyData.map((day) {
        final dd = day as Map<String, dynamic>;
        final dateStr = dd['date'] ?? '';
        final steps = dd['steps'] ?? 0;
        final cals = dd['calories'] ?? 0;
        String label = dateStr;
        try { label = DateFormat('EEE, d MMM').format(DateTime.parse(dateStr)); } catch (_) {}
        final max = dailyData.fold<int>(0, (p, d2) { final s = (d2 as Map)['steps'] ?? 0; return (s as int) > p ? s : p; });
        final prog = max > 0 ? (steps / max).clamp(0.0, 1.0) : 0.0;
        return Container(
          margin: const EdgeInsets.only(bottom: 8), padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(color: _T.card, borderRadius: BorderRadius.circular(16)),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text(label, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w500, color: _T.hi)),
              Text('$steps steps · $cals kcal', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: _T.mid)),
            ]),
            const SizedBox(height: 8),
            ClipRRect(borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(value: prog.toDouble(), minHeight: 5, backgroundColor: _T.divider, valueColor: const AlwaysStoppedAnimation(Color(0xFFFF6B2B)))),
          ]),
        );
      }),
    ];
  }

  // ── MONTHLY REPORT ──
  List<Widget> _buildMonthlyReport(Map<String, dynamic> d) {
    final month = d['month'] ?? '';
    final weeklyData = (d['weeklyData'] as List<dynamic>?) ?? [];
    final totalSteps = d['totalSteps'] ?? 0;
    final totalCalories = d['totalCalories'] ?? 0;
    final avgDaily = d['avgDailySteps'] ?? 0;

    return [
      Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: _T.purple.withOpacity(0.08), borderRadius: BorderRadius.circular(18), border: Border.all(color: _T.purple.withOpacity(0.2))),
        child: Row(children: [
          const Icon(Icons.calendar_month_rounded, color: _T.purple, size: 22),
          const SizedBox(width: 12),
          Text(month.toString(), style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w700, color: _T.purple)),
        ]),
      ),
      const SizedBox(height: 16),
      Row(children: [
        Expanded(child: _statSummaryCard(icon: Icons.directions_walk_rounded, value: _formatSteps(totalSteps), label: 'Total Steps', color: _T.green)),
        const SizedBox(width: 12),
        Expanded(child: _statSummaryCard(icon: Icons.local_fire_department_rounded, value: totalCalories.toString(), label: 'Calories', color: _T.accent)),
        const SizedBox(width: 12),
        Expanded(child: _statSummaryCard(icon: Icons.speed_rounded, value: _formatSteps(avgDaily), label: 'Avg/Day', color: _T.blue)),
      ]),
      const SizedBox(height: 20),
      Text('Weekly Breakdown', style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w700, color: _T.hi)),
      const SizedBox(height: 12),
      if (weeklyData.isEmpty)
        Container(padding: const EdgeInsets.all(24), decoration: BoxDecoration(color: _T.card, borderRadius: BorderRadius.circular(20)),
          child: Center(child: Text('No weekly data.', style: GoogleFonts.inter(color: _T.mid)))),
      ...weeklyData.asMap().entries.map((entry) {
        final i = entry.key;
        final w = entry.value as Map<String, dynamic>;
        final wStart = w['weekStart'] ?? '';
        final wEnd = w['weekEnd'] ?? '';
        final wSteps = w['steps'] ?? 0;
        final wCals = w['calories'] ?? 0;
        String weekLabel = 'Week ${i + 1}';
        try { weekLabel = '${DateFormat('d MMM').format(DateTime.parse(wStart))} – ${DateFormat('d MMM').format(DateTime.parse(wEnd))}'; } catch (_) {}
        final max = weeklyData.fold<int>(0, (p, w2) { final s = (w2 as Map)['steps'] ?? 0; return (s as int) > p ? s : p; });
        final prog = max > 0 ? (wSteps / max).clamp(0.0, 1.0) : 0.0;
        return Container(
          margin: const EdgeInsets.only(bottom: 10), padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: _T.card, borderRadius: BorderRadius.circular(18)),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text(weekLabel, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: _T.hi)),
              Text('$wSteps steps', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w700, color: _T.accent)),
            ]),
            const SizedBox(height: 10),
            ClipRRect(borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(value: prog.toDouble(), minHeight: 6, backgroundColor: _T.divider, valueColor: const AlwaysStoppedAnimation(Color(0xFFFF6B2B)))),
            const SizedBox(height: 8),
            Text('$wCals kcal burned', style: GoogleFonts.inter(fontSize: 11, color: _T.mid)),
          ]),
        );
      }),
    ];
  }

  Widget _goalBadge(bool goalAchieved, String date) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: goalAchieved ? _T.green.withOpacity(0.1) : _T.accent.withOpacity(0.08),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: goalAchieved ? _T.green.withOpacity(0.3) : _T.accent.withOpacity(0.2)),
      ),
      child: Row(children: [
        Icon(goalAchieved ? Icons.emoji_events_rounded : Icons.flag_rounded, color: goalAchieved ? _T.green : _T.accent, size: 28),
        const SizedBox(width: 14),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(goalAchieved ? 'Goal Achieved! 🎉' : 'Keep Going!', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700, color: goalAchieved ? _T.green : _T.accent)),
          const SizedBox(height: 2),
          Text(date, style: GoogleFonts.inter(fontSize: 12, color: _T.mid)),
        ])),
      ]),
    );
  }

  // 移除多余的 build 方法
  Widget _homeTab(DashboardState state, int sessionSteps) {
    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator(color: Color(0xFFFF6B2B)));
    }
  
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.only(bottom: 110),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _header(),
          _heroCard(state, sessionSteps),
          _sectionLabel('Morning Habits'),
          _morningHabitsSection(),
          _sectionLabel('Streak'),
          _premiumStreakCard(),
          _sectionLabel('WEEKLY OVERVIEW'),
          _weekChart(state),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  // ── HEADER ──────────────────────────────────────────────
  Widget _header() {
    final auth = provider.Provider.of<AuthProvider>(context);
    final profile = auth.userProfile;
    final name = profile?['name'] ?? 'Guest';
    final initial = name.isNotEmpty ? name[0].toUpperCase() : 'G';
    
    final formatter = DateFormat('EEEE, d MMM');
    final dateStr = formatter.format(DateTime.now());

    final hour = DateTime.now().hour;
    String greeting = 'Good morning';
    if (hour >= 12 && hour < 17) greeting = 'Good afternoon';
    else if (hour >= 17) greeting = 'Good evening';

    return Padding(
      padding: const EdgeInsets.fromLTRB(22, 18, 22, 0),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(dateStr, style: _Txt.label),
                const SizedBox(height: 3),
                Text('$greeting, $name', style: _Txt.title),
              ],
            ),
          ),
          GestureDetector(
            onTap: _openSearch,
            child: Container(
              width: 38, height: 38,
              decoration: BoxDecoration(color: _T.card, borderRadius: BorderRadius.circular(12)),
              child: const Icon(Icons.search_rounded, color: _T.mid, size: 20),
            ),
          ),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: _openProfile,
            child: Container(
              width: 38, height: 38,
              decoration: const BoxDecoration(shape: BoxShape.circle, gradient: _T.accentGrad),
              child: Center(
                child: Text(initial, style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w700, color: Colors.white)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── STEP PHASE HELPER ──────────────────────────────────
  /// Returns the phase name and next-phase info based on current step count.
  /// Phases:
  ///   0 – 5000     → Activation Phase
  ///   5001 – 7000  → Fat Loss Phase
  ///   7001 – 10000 → Metabolic Phase
  ///  10001 – 12000 → Transformation Phase
  ///  12000+        → Limit Zone
  static String _getPhaseName(int steps) {
    if (steps <= 5000) return 'Activation';
    if (steps <= 7000) return 'Fat Loss';
    if (steps <= 10000) return 'Metabolic';
    if (steps <= 12000) return 'Transformation';
    return 'Limit Zone';
  }

  static String? _getNextPhaseName(int steps) {
    if (steps <= 5000) return 'Fat Loss';
    if (steps <= 7000) return 'Metabolic';
    if (steps <= 10000) return 'Transformation';
    if (steps <= 12000) return 'Limit Zone';
    return null; // already at max
  }

  static int _stepsToNextPhase(int steps) {
    if (steps <= 5000) return 5001 - steps;
    if (steps <= 7000) return 7001 - steps;
    if (steps <= 10000) return 10001 - steps;
    if (steps <= 12000) return 12001 - steps;
    return 0;
  }

  /// Goal for each phase (the upper limit of that phase)
  static int _getPhaseGoal(int steps) {
    if (steps <= 5000) return 5000;
    if (steps <= 7000) return 7000;
    if (steps <= 10000) return 10000;
    if (steps <= 12000) return 12000;
    return 15000; // Limit Zone stretch goal
  }

  // ── HERO CARD ────────────────────────────────────────────
  Widget _heroCard(DashboardState state, int sessionSteps) {
    var rawCalories = state.todayActivity?['calories'] ?? 0.0;
    final apiSteps = (state.todayActivity?['steps'] ?? 0) as num;
    
    // Use apiSteps directly — _lastCompletedSteps is a fallback only for
    // the brief gap between stopping a session and the server updating
    final baseSteps = apiSteps.toInt() >= _lastCompletedSteps
        ? apiSteps.toInt()
        : _lastCompletedSteps;
    
    // When tracking, add live session steps on top of what server knows
    final steps = _isTracking ? (baseSteps + sessionSteps) : baseSteps;
    
    // Fallback: If API gave us 0 calories, dynamically generate it based on total steps
    if (rawCalories == 0.0 || rawCalories == 0) {
      rawCalories = steps * 0.045; // Approx 45 calories per 1000 steps
    }
    final calories = rawCalories.toInt();
    
    final goal = _getPhaseGoal(steps);
    final progress = (steps / goal).clamp(0.0, 1.0);
    final phaseName = _getPhaseName(steps);
    
    return Padding(
      padding: const EdgeInsets.fromLTRB(22, 20, 22, 0),
      child: Container(
        decoration: BoxDecoration(color: _T.card, borderRadius: BorderRadius.circular(24)),
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 36),
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(calories.toString(), style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w800, color: _T.hi)),
                  Text('kcal burned', style: GoogleFonts.inter(fontSize: 11, color: _T.mid)),
                ],
              ),
            ),
            const SizedBox(height: 16),
            AnimatedBuilder(
              animation: _ring,
              builder: (_, __) {
                return AspectRatio(
                  aspectRatio: 1.4,
                  child: CustomPaint(
                    painter: _HeroArcPainter(progress: _ring.value * progress),
                    child: Padding(
                      padding: const EdgeInsets.only(top: 40),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(steps.toString(), style: GoogleFonts.inter(fontSize: 44, fontWeight: FontWeight.w900, color: _T.hi, height: 1)),
                          const SizedBox(height: 4),
                          Text('steps', style: GoogleFonts.inter(fontSize: 14, color: _T.mid, fontWeight: FontWeight.w500)),
                          const SizedBox(height: 14),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 7),
                            decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFFFF6B2B), Color(0xFFFF9A3C)]), borderRadius: BorderRadius.circular(20)),
                            child: Text(phaseName, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.white)),
                          ),
                          const SizedBox(height: 8),
                          Text('Goal: ${goal}', style: GoogleFonts.inter(fontSize: 12, color: _T.mid)),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  // ── MORNING HABITS (AUTO-COMPLETE AT 1000 STEPS) ──────────
  Widget _morningHabitsSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 22),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(child: _habitCard(icon: '💊', title: 'Take Tablet', subtitle: 'Take your\nmorning tablet', done: _habitTablet)),
            const SizedBox(width: 10),
            Expanded(child: _habitCard(icon: '💧', title: 'Drink Water', subtitle: 'Drink a glass\nof water', done: _habitWater)),
            const SizedBox(width: 10),
            Expanded(child: _habitCard(icon: '🚶', title: 'Walk', subtitle: 'Completes at\n1000 steps', done: _habitWalk)),
          ],
        ),
      ),
    );
  }

  Widget _habitCard({required String icon, required String title, required String subtitle, required bool done}) {
    if (done) {
      // Completed state — no animation
      return AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.fromLTRB(12, 14, 12, 14),
        decoration: BoxDecoration(
          color: _T.accent.withOpacity(0.08),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: _T.accent.withOpacity(0.4)),
          boxShadow: [BoxShadow(color: _T.accent.withOpacity(0.1), blurRadius: 12, spreadRadius: 1)],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(icon, style: const TextStyle(fontSize: 22)),
              const Spacer(),
              const Icon(Icons.check_circle_rounded, color: _T.accent, size: 18),
            ]),
            const SizedBox(height: 10),
            Text(title, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w700, color: _T.accent)),
            const SizedBox(height: 6),
            Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Padding(padding: EdgeInsets.only(top: 1), child: Icon(Icons.check_rounded, size: 12, color: _T.accent)),
              const SizedBox(width: 4),
              Expanded(child: Text(subtitle, style: GoogleFonts.inter(fontSize: 11, color: _T.accent.withOpacity(0.7), height: 1.5))),
            ]),
          ],
        ),
      );
    }
    // Incomplete — pulse/glow animation to grab attention
    return AnimatedBuilder(
      animation: _habitPulse,
      builder: (context, child) {
        final pulse = _habitPulse.value; // 0.0 → 1.0
        final borderColor = Color.lerp(const Color(0xFF252525), const Color(0xFFFF6B2B), pulse * 0.6)!;
        final glowOpacity = pulse * 0.15;
        final iconScale = 1.0 + pulse * 0.1;
        return Container(
          padding: const EdgeInsets.fromLTRB(12, 14, 12, 14),
          decoration: BoxDecoration(
            color: _T.card,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: borderColor, width: 1.0 + pulse * 0.5),
            boxShadow: [
              BoxShadow(color: _T.accent.withOpacity(glowOpacity), blurRadius: 16, spreadRadius: 1),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Transform.scale(scale: iconScale, child: Text(icon, style: const TextStyle(fontSize: 22))),
                const Spacer(),
                Icon(Icons.radio_button_unchecked_rounded, color: Color.lerp(_T.lo, _T.accent, pulse * 0.5), size: 18),
              ]),
              const SizedBox(height: 10),
              Text(title, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w700, color: _T.hi)),
              const SizedBox(height: 6),
              Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Padding(padding: const EdgeInsets.only(top: 1), child: Icon(Icons.circle_outlined, size: 12, color: Color.lerp(_T.lo, _T.accent, pulse * 0.4))),
                const SizedBox(width: 4),
                Expanded(child: Text(subtitle, style: GoogleFonts.inter(fontSize: 11, color: _T.mid, height: 1.5))),
              ]),
            ],
          ),
        );
      },
    );
  }

  // ── PREMIUM STREAK CARD ──────────────────────────────────
  Widget _premiumStreakCard() {
    // Get current steps for phase calculation
    final state = ref.watch(dashboardProvider);
    final apiSteps = (state.todayActivity?['steps'] ?? 0) as int;
    final liveSteps = ref.watch(pedometerProvider).valueOrNull ?? 0;
    final currentSteps = [apiSteps, liveSteps, _lastCompletedSteps].reduce((a, b) => a > b ? a : b);
    final currentPhase = _getPhaseName(currentSteps);
    final nextPhase = _getNextPhaseName(currentSteps);
    final remaining = _stepsToNextPhase(currentSteps);

    // Calculate streak: how many consecutive days (including today) the user
    // has been in the current phase, using the weekly stats daily data.
    final weeklyData = state.weeklyStats ?? {};
    final daysList = (weeklyData['days'] as List<dynamic>?) ?? [];

    // Build a list of per-day phases from the API (most recent last)
    // Then walk backwards from today counting consecutive days in currentPhase.
    int streakDays = 1; // today always counts
    if (daysList.isNotEmpty) {
      // daysList is ordered oldest → newest; walk backwards skipping today
      for (int i = daysList.length - 1; i >= 0; i--) {
        final d = daysList[i] as Map<String, dynamic>;
        final dateStr = d['date'] ?? '';
        // Skip today — we already counted it
        final todayStr = DateFormat('yyyy-MM-dd').format(DateTime.now());
        if (dateStr == todayStr) continue;
        final daySteps = (d['steps'] ?? 0) as int;
        // A day with 0 steps doesn't count — user wasn't active
        if (daySteps > 0 && _getPhaseName(daySteps) == currentPhase) {
          streakDays++;
        } else {
          break; // streak broken (inactive or different phase)
        }
      }
    }
    streakDays = streakDays.clamp(1, 7);

    // Build day labels: last 7 days ending at today (today = rightmost)
    final allDays = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
    final dayLabels = List.generate(7, (i) {
      final d = DateTime.now().subtract(Duration(days: 6 - i));
      return allDays[d.weekday % 7];
    });

    // Today is always the last dot (index 6)
    const currentIndex = 6;
    // Mark streak days: count backwards from today (index 6)
    final doneIndices = List.generate(streakDays, (i) => 6 - i);

    final streakSubtitle = nextPhase != null
        ? '$streakDays day streak! $remaining steps to $nextPhase'
        : '🔥 $streakDays day streak in Limit Zone!';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 22),
      child: AnimatedBuilder(
        animation: _glow,
        builder: (_, __) {
          return Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(22),
              color: const Color(0xFF1A1208),
              border: Border.all(color: _T.accent.withOpacity(0.15 + _glow.value * 0.1), width: 1.2),
              boxShadow: [BoxShadow(color: _T.accent.withOpacity(0.06 + _glow.value * 0.05), blurRadius: 20, spreadRadius: 2)],
            ),
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
                  AnimatedBuilder(
                    animation: _glow,
                    builder: (_, __) => Container(
                      width: 46, height: 46,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _T.accent.withOpacity(0.15),
                        border: Border.all(color: _T.accent.withOpacity(0.4 + _glow.value * 0.2), width: 1.5),
                        boxShadow: [BoxShadow(color: _T.accent.withOpacity(0.2 + _glow.value * 0.15), blurRadius: 12)],
                      ),
                      child: const Icon(Icons.local_fire_department_rounded, color: _T.accent, size: 24),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('$currentPhase Phase', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w800, color: _T.hi)),
                    const SizedBox(height: 3),
                    Text(streakSubtitle, style: GoogleFonts.inter(fontSize: 11, color: _T.mid)),
                  ])),
                  const SizedBox(width: 12),
                  GestureDetector(
                    onTap: () => HapticFeedback.lightImpact(),
                    child: AnimatedBuilder(
                      animation: _glow,
                      builder: (_, __) => Container(
                        width: 62,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(14),
                          color: _T.accent.withOpacity(0.08),
                          border: Border.all(color: _T.accent.withOpacity(0.25 + _glow.value * 0.1)),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
                        child: Column(mainAxisSize: MainAxisSize.min, mainAxisAlignment: MainAxisAlignment.center, children: [
                          Icon(Icons.local_fire_department_rounded, color: _T.accent, size: 20),
                          const SizedBox(height: 4),
                          Text(currentPhase.toUpperCase(), textAlign: TextAlign.center, style: GoogleFonts.inter(fontSize: 8, fontWeight: FontWeight.w800, color: _T.accent, letterSpacing: 0.4, height: 1.2)),
                          const SizedBox(height: 4),
                          Text(nextPhase != null ? '+${(remaining * 0.045).round()} cal' : '🔥 MAX', style: GoogleFonts.inter(fontSize: 9, fontWeight: FontWeight.w700, color: _T.gold)),
                        ]),
                      ),
                    ),
                  ),
                ]),
                const SizedBox(height: 20),
                SizedBox(
                  height: 48,
                  child: Row(
                    children: List.generate(dayLabels.length, (i) {
                      final isDone = doneIndices.contains(i);
                      final isToday = i == currentIndex;
                      final isLast = i == dayLabels.length - 1;
                      return Expanded(
                        child: Row(children: [
                          Expanded(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              width: isToday ? 28 : 24, height: isToday ? 28 : 24,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: isDone ? const LinearGradient(colors: [Color(0xFFFF6B2B), Color(0xFFFF9A3C)], begin: Alignment.topLeft, end: Alignment.bottomRight) : null,
                                color: isDone ? null : _T.card2,
                                border: isToday ? Border.all(color: _T.accent, width: 2) : Border.all(color: isDone ? Colors.transparent : _T.lo.withOpacity(0.4)),
                                boxShadow: isDone ? [BoxShadow(color: _T.accent.withOpacity(0.4), blurRadius: 6)] : null,
                              ),
                              child: Center(child: isDone
                                  ? const Icon(Icons.check_rounded, color: Colors.white, size: 13)
                                  : isToday
                                      ? Container(width: 6, height: 6, decoration: const BoxDecoration(shape: BoxShape.circle, color: _T.accent))
                                      : null),
                            ),
                            const SizedBox(height: 5),
                            Text(dayLabels[i], style: GoogleFonts.inter(
                              fontSize: 9,
                              fontWeight: isToday ? FontWeight.w700 : FontWeight.w400,
                              color: isToday ? _T.accent : isDone ? _T.mid : _T.lo,
                            )),
                          ])),
                          if (!isLast)
                            Container(height: 2, width: 4, decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(2),
                              color: i < currentIndex ? _T.accent.withOpacity(0.6) : _T.lo.withOpacity(0.25),
                            )),
                        ]),
                      );
                    }),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // ── WEEKLY CHART ─────────────────────────────────────────
  Widget _weekChart(DashboardState state) {
    final weeklyData = state.weeklyStats ?? {};
    final daysList = (weeklyData['days'] as List<dynamic>?) ?? [];
    final totalSteps = weeklyData['totalSteps'] ?? 0;
    final totalCalories = weeklyData['totalCalories'] ?? 0;
    final avgStepsPerDay = weeklyData['avgStepsPerDay'] ?? 0;

    // Build 7-day data from API response
    final List<String> dayLabels = [];
    final List<int> stepValues = [];
    final List<int> calValues = [];
    int todayIndex = -1;
    final todayStr = DateFormat('yyyy-MM-dd').format(DateTime.now());

    for (int i = 0; i < daysList.length && i < 7; i++) {
      final d = daysList[i] as Map<String, dynamic>;
      final dateStr = d['date'] ?? '';
      final steps = (d['steps'] ?? 0) as int;
      final cals = (d['calories'] ?? 0) as int;

      String label = 'D${i + 1}';
      try {
        final dt = DateTime.parse(dateStr);
        label = DateFormat('E').format(dt); // Mon, Tue, etc.
        if (dateStr == todayStr) todayIndex = i;
      } catch (_) {}

      dayLabels.add(label);
      stepValues.add(steps);
      calValues.add(cals);
    }

    // Fallback if API returned empty
    if (dayLabels.isEmpty) {
      dayLabels.addAll(['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun']);
      stepValues.addAll([0, 0, 0, 0, 0, 0, 0]);
      calValues.addAll([0, 0, 0, 0, 0, 0, 0]);
    }

    final maxVal = stepValues.isEmpty ? 1.0 : stepValues.reduce(math.max).toDouble();
    final bestIdx = stepValues.indexOf(stepValues.reduce(math.max));
    final bestDay = dayLabels.length > bestIdx ? dayLabels[bestIdx] : '-';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 22),
      child: GestureDetector(
        onTap: _showWeekDetails,
        child: Container(
          padding: const EdgeInsets.fromLTRB(18, 20, 18, 20),
          decoration: BoxDecoration(color: _T.card, borderRadius: BorderRadius.circular(24)),
          child: Column(children: [
            Row(children: [
              Expanded(child: _weekStat(_formatSteps(totalSteps), 'Total steps')),
              Container(width: 1, height: 32, color: _T.divider),
              Expanded(child: _weekStat('$totalCalories', 'kcal burned')),
              Container(width: 1, height: 32, color: _T.divider),
              Expanded(child: _weekStat(_formatSteps(avgStepsPerDay), 'Avg / day')),
            ]),
            const SizedBox(height: 20),
            SizedBox(
              height: 96,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: List.generate(dayLabels.length, (i) {
                  final isToday = i == todayIndex;
                  final barHeight = maxVal > 0 ? (stepValues[i] / maxVal * 56).clamp(4, 56).toDouble() : 4.0;
                  return GestureDetector(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text('${dayLabels[i]}: ${stepValues[i]} steps · ${calValues[i]} kcal'),
                        backgroundColor: _T.card, behavior: SnackBarBehavior.floating,
                        duration: const Duration(seconds: 1),
                      ));
                    },
                    child: Column(mainAxisSize: MainAxisSize.min, children: [
                      Container(
                        width: 26, height: 56, alignment: Alignment.bottomCenter,
                        child: Container(
                          width: 26, height: barHeight,
                          decoration: BoxDecoration(
                            gradient: isToday ? _T.accentGrad : null,
                            color: isToday ? null : _T.card2,
                            borderRadius: BorderRadius.circular(5),
                            border: isToday ? Border.all(color: _T.accent.withOpacity(0.5), width: 1) : null,
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(dayLabels[i], style: GoogleFonts.inter(
                        fontSize: 11, fontWeight: isToday ? FontWeight.w600 : FontWeight.w400,
                        color: isToday ? _T.accent : _T.mid,
                      )),
                    ]),
                  );
                }),
              ),
            ),
            const SizedBox(height: 4),
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Icon(Icons.touch_app_rounded, color: _T.lo, size: 11),
              const SizedBox(width: 4),
              Text('Tap bar for details', style: GoogleFonts.inter(fontSize: 10, color: _T.lo)),
            ]),
          ]),
        ),
      ),
    );
  }

  void _showWeekDetails() {
    final state = ref.read(dashboardProvider);
    showModalBottomSheet(
      context: context, backgroundColor: Colors.transparent, isScrollControlled: true,
      builder: (_) => _WeekDetailsSheet(weeklyStats: state.weeklyStats ?? {}),
    );
  }

  Widget _weekStat(String val, String label) {
    return Column(children: [
      Text(val, style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w700, color: _T.hi)),
      const SizedBox(height: 3),
      Text(label, style: _Txt.label),
    ]);
  }

  void _openSearch() {
    showModalBottomSheet(
      context: context, backgroundColor: Colors.transparent,
      isScrollControlled: true, builder: (_) => _SearchSheet(),
    );
  }

  void _openProfile() {
    final auth = provider.Provider.of<AuthProvider>(context, listen: false);
    final profile = auth.userProfile;
    final name = profile?['name'] ?? 'Guest';
    final email = profile?['email'] ?? '';
    final initial = name.isNotEmpty ? name[0].toUpperCase() : 'G';

    showModalBottomSheet(
      context: context, backgroundColor: Colors.transparent, isScrollControlled: true,
      builder: (_) => Container(
        decoration: const BoxDecoration(color: Color(0xFF141414), borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
        padding: EdgeInsets.fromLTRB(24, 16, 24, MediaQuery.of(context).padding.bottom + 32),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(width: 36, height: 4, decoration: BoxDecoration(color: _T.lo, borderRadius: BorderRadius.circular(2))),
          const SizedBox(height: 24),
          Row(children: [
            Container(width: 56, height: 56, decoration: const BoxDecoration(shape: BoxShape.circle, gradient: _T.accentGrad),
              child: Center(child: Text(initial, style: GoogleFonts.inter(fontSize: 22, fontWeight: FontWeight.w700, color: Colors.white)))),
            const SizedBox(width: 16),
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(name, style: _Txt.title),
              const SizedBox(height: 3),
              if (email.isNotEmpty) Text(email, style: _Txt.body),
            ]),
          ]),
          const SizedBox(height: 24),
          Container(height: 1, color: _T.divider),
          const SizedBox(height: 16),
          _profileTile(Icons.person_outline_rounded, 'Edit Profile'),
          _profileTile(Icons.workspace_premium_rounded, 'Subscription', badge: 'Free'),
          _profileTile(Icons.notifications_outlined, 'Notifications'),
          _profileTile(Icons.help_outline_rounded, 'Help & Support'),
          const SizedBox(height: 8),
          _profileTile(Icons.logout_rounded, 'Sign Out', danger: true, onTap: () async {
            Navigator.pop(context); // close sheet
            final authProv = provider.Provider.of<AuthProvider>(context, listen: false);
            await authProv.logoutApi();
            // Stop background service if tracking
            FlutterBackgroundService().invoke('stopService');
            if (mounted) {
              context.go(RouteNames.login);
            }
          }),
        ]),
      ),
    );
  }

  Widget _profileTile(IconData icon, String label, {String? badge, bool danger = false, VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(children: [
          Icon(icon, color: danger ? Colors.redAccent : _T.mid, size: 20),
          const SizedBox(width: 14),
          Expanded(child: Text(label, style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w500, color: danger ? Colors.redAccent : _T.hi))),
          if (badge != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(color: _T.accentDim, borderRadius: BorderRadius.circular(20)),
              child: Text(badge, style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600, color: _T.accent)),
            )
          else
            Icon(Icons.chevron_right_rounded, color: _T.lo, size: 20),
        ]),
      ),
    );
  }

  // ── PLAY / PAUSE FAB (Spotify style) ────────────────────
  Widget _continueFab() {
    return GestureDetector(
      onTap: () async {
        HapticFeedback.mediumImpact();
        
        // Check REAL session state from SharedPreferences (not just local flag)
        final prefs = await SharedPreferences.getInstance();
        final existingSessionId = prefs.getString('active_session_id') ?? '';
        final hasActiveSession = existingSessionId.isNotEmpty;
        
        // Simple toggle: if not tracking → start, if tracking → stop
        // Stale session IDs (e.g. from backup restore) get cleaned up during start
        final shouldStart = !_isTracking;
        
        setState(() {
          _isTracking = shouldStart;
          if (_isTracking) {
            _ac.repeat(reverse: true);
            _glowAc.repeat(reverse: true);
          } else {
            _ac.stop(); _glowAc.stop();
          }
        });
        
        try {
          final repo = ref.read(trackingRepositoryProvider);
          final service = FlutterBackgroundService();
          if (shouldStart) {
             // CRITICAL: Android 13+ Notification Prompt
            await Permission.notification.request();
            // CRITICAL: Android 14 Health Foreground Rules
            await Permission.activityRecognition.request();
            
            // Stop any old stale service first
            service.invoke('stopService');
            await Future.delayed(const Duration(milliseconds: 300));
            
            // If there's an old session, stop it on backend first
            if (hasActiveSession) {
              try {
                final oldSteps = ref.read(pedometerProvider).value ?? 0;
                await repo.stopSession(
                  sessionId: existingSessionId,
                  finalSteps: oldSteps,
                  finalCalories: (oldSteps * 0.045).round(),
                  finalDistance: double.parse((oldSteps * 0.000762).toStringAsFixed(3)),
                );
                await prefs.remove('active_session_id');
                debugPrint('🧹 Cleaned up old session: $existingSessionId');
              } catch (e) {
                debugPrint('⚠️ Old session cleanup failed: $e');
                await prefs.remove('active_session_id');
              }
            }
            
            // Reset pedometer & start counting fresh for this session
            // NOTE: _lastCompletedSteps is intentionally kept — previous session steps stay visible
            ref.read(pedometerProvider.notifier).startSession();
            
            // Start session on server & save sessionId BEFORE starting service
            final sessionResponse = await repo.startSession(0);
            final sessionId = sessionResponse['sessionId'] ?? sessionResponse['id'] ?? '';
            debugPrint('🟢 Session started: $sessionId');
            
            await prefs.setString('active_session_id', sessionId.toString());
            
            // NOW start service — session ID is guaranteed saved
            await Future.delayed(const Duration(milliseconds: 100));
            service.startService();
            
            // Start auto-refreshing stats every 30 seconds
            ref.read(dashboardProvider.notifier).startAutoRefresh();
            
            debugPrint('========= SESSION STARTED VERIFIED =========');
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('⚡ Tracking session started!', style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.w600)),
                  backgroundColor: _T.green,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  margin: const EdgeInsets.all(16),
                  duration: const Duration(seconds: 3),
                )
              );
            }
          } else {
            // STOP
            service.invoke('stopService');
            
            // Stop auto-refreshing stats
            ref.read(dashboardProvider.notifier).stopAutoRefresh();
            
            // Save final steps BEFORE stopping (so hero card doesn't show 0)
            final livePedometerSteps = ref.read(pedometerProvider).value ?? 0;
            final prevApiSteps = (ref.read(dashboardProvider).todayActivity?['steps'] ?? 0) as num;
            _lastCompletedSteps = prevApiSteps.toInt() + livePedometerSteps;
            // Persist to survive navigation
            SharedPreferences.getInstance().then((p) {
              final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
              p.setInt('completed_steps_today', _lastCompletedSteps);
              p.setString('completed_steps_date', today);
            });
            debugPrint('💾 Saved completed steps: $_lastCompletedSteps');
            
            // Freeze the step counter
            ref.read(pedometerProvider.notifier).stopSession();
            
            final sessionIdToStop = prefs.getString('active_session_id') ?? existingSessionId;
            
            if (sessionIdToStop.isNotEmpty) {
              final finalSteps = ref.read(pedometerProvider).value ?? 0;
              final finalCalories = (finalSteps * 0.045).round();
              final finalDistance = double.parse((finalSteps * 0.000762).toStringAsFixed(3));
              
              await repo.stopSession(
                sessionId: sessionIdToStop,
                finalSteps: finalSteps,
                finalCalories: finalCalories,
                finalDistance: finalDistance,
              );
            }
            
            // Clear sessionId
            await prefs.remove('active_session_id');
            await prefs.remove('session_accumulated_steps');
            debugPrint('🔴 Session stopped');
            debugPrint('========= SESSION STOPPED VERIFIED =========');
            
            // Refresh dashboard data so stats update
            ref.read(dashboardProvider.notifier).refresh();
            
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('🛑 Tracking session ended.', style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.w600)),
                  backgroundColor: _T.accent,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  margin: const EdgeInsets.all(16),
                  duration: const Duration(seconds: 3),
                )
              );
            }
          }
        } catch (e) {
          if (e is provider.ProviderNotFoundException) {} // Ignore
          debugPrint('START/STOP FAILED: $e');
          if (e is DioException) {
            debugPrint('ERROR RESPONSE: ${e.response?.data}');
          }
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutBack,
        width: 58, height: 58,
        decoration: BoxDecoration(
          gradient: _T.accentGrad,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: _T.accent.withOpacity(_isTracking ? 0.65 : 0.4),
              blurRadius: _isTracking ? 28 : 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          transitionBuilder: (child, anim) => ScaleTransition(scale: anim, child: child),
          child: Icon(
            _isTracking ? Icons.pause_rounded : Icons.play_arrow_rounded,
            key: ValueKey(_isTracking),
            color: Colors.white,
            size: 28,
          ),
        ),
      ),
    );
  }

  // ── BOTTOM PILL NAV ──────────────────────────────────────
  Widget _bottomPill() {
    final bottomPad = MediaQuery.of(context).padding.bottom;
    return Container(
      color: Colors.transparent,
      child: Padding(
        padding: EdgeInsets.only(left: 20, right: 20, bottom: bottomPad + 12, top: 0),
        child: Container(
          height: 64,
          decoration: BoxDecoration(
            color: const Color(0xFF1C1C1C),
            borderRadius: BorderRadius.circular(32),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.5), blurRadius: 24, offset: const Offset(0, 8))],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _navItem(0, Icons.home_rounded, 'Home'),
              _navItem(1, Icons.assessment_rounded, 'Reports'), // ← Reports icon
              const SizedBox(width: 60),
              _navItem(2, Icons.bar_chart_rounded, 'Stats'),
              _navItem(3, Icons.person_rounded, 'You'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionLabel(String t) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(22, 28, 22, 12),
      child: Text(t, style: _Txt.label),
    );
  }

  Widget _navItem(int idx, IconData icon, String label) {
    final active = _tab == idx;
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        if (idx == 2) { context.go(RouteNames.stats); }
        else if (idx == 3) { context.go(RouteNames.you); }
        else { setState(() => _tab = idx); }
      },
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: active ? _T.accent : _T.mid, size: active ? 20 : 22),
            const SizedBox(height: 4),
            if (active) Text(label, style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w600, color: _T.accent)),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════
//  SEARCH SHEET
// ═══════════════════════════════════════════
class _SearchSheet extends StatefulWidget {
  @override
  State<_SearchSheet> createState() => _SearchSheetState();
}

class _SearchSheetState extends State<_SearchSheet> {
  final _controller = TextEditingController();
  final List<String> _suggestions = ['Morning Run', 'Upper Body', 'Evening Stretch', 'Yoga Flow', 'HIIT Session', 'Cycling', 'Swimming'];
  List<String> _filtered = [];

  @override
  void initState() { super.initState(); _filtered = _suggestions; _controller.addListener(_filter); }
  @override
  void dispose() { _controller.dispose(); super.dispose(); }

  void _filter() {
    final q = _controller.text.toLowerCase();
    setState(() { _filtered = q.isEmpty ? _suggestions : _suggestions.where((s) => s.toLowerCase().contains(q)).toList(); });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(color: Color(0xFF141414), borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      padding: EdgeInsets.fromLTRB(24, 16, 24, MediaQuery.of(context).padding.bottom + 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(width: 36, height: 4, decoration: BoxDecoration(color: _T.lo, borderRadius: BorderRadius.circular(2))),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(color: _T.card2, borderRadius: BorderRadius.circular(14), border: Border.all(color: _T.divider)),
            child: Row(children: [
              Icon(Icons.search_rounded, color: _T.mid, size: 20),
              const SizedBox(width: 12),
              Expanded(child: TextField(
                controller: _controller,
                style: GoogleFonts.inter(fontSize: 15, color: _T.hi, fontWeight: FontWeight.w500),
                decoration: const InputDecoration(hintText: 'Search workouts, metrics...', hintStyle: TextStyle(color: _T.lo), border: InputBorder.none, isCollapsed: true),
              )),
              if (_controller.text.isNotEmpty)
                GestureDetector(onTap: () { _controller.clear(); _filter(); }, child: Icon(Icons.clear_rounded, color: _T.mid, size: 18)),
            ]),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: _filtered.isEmpty
                ? Center(child: Text('No results found', style: GoogleFonts.inter(fontSize: 14, color: _T.lo)))
                : ListView.separated(
                    itemCount: _filtered.length,
                    separatorBuilder: (_, __) => Container(height: 1, color: _T.divider),
                    itemBuilder: (context, i) {
                      final item = _filtered[i];
                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: Container(width: 36, height: 36, decoration: BoxDecoration(color: _T.accentDim, borderRadius: BorderRadius.circular(10)), child: Icon(Icons.fitness_center_rounded, color: _T.accent, size: 18)),
                        title: Text(item, style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w500, color: _T.hi)),
                        trailing: Icon(Icons.chevron_right_rounded, color: _T.lo, size: 20),
                        onTap: () {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Opening: $item'), backgroundColor: _T.card, behavior: SnackBarBehavior.floating));
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════
//  WEEK DETAILS SHEET
// ═══════════════════════════════════════════
class _WeekDetailsSheet extends StatelessWidget {
  final Map<String, dynamic> weeklyStats;
  const _WeekDetailsSheet({required this.weeklyStats});
  @override
  Widget build(BuildContext context) {
    final daysList = (weeklyStats['days'] as List<dynamic>?) ?? [];
    final totalSteps = weeklyStats['totalSteps'] ?? 0;
    final totalCalories = weeklyStats['totalCalories'] ?? 0;
    final avgStepsPerDay = weeklyStats['avgStepsPerDay'] ?? 0;

    // Build day data
    final List<String> dayLabels = [];
    final List<int> stepValues = [];
    final List<int> calValues = [];
    for (int i = 0; i < daysList.length && i < 7; i++) {
      final d = daysList[i] as Map<String, dynamic>;
      final dateStr = d['date'] ?? '';
      final steps = (d['steps'] ?? 0) as int;
      final cals = (d['calories'] ?? 0) as int;
      String label = 'Day ${i + 1}';
      try { label = DateFormat('EEE').format(DateTime.parse(dateStr)); } catch (_) {}
      dayLabels.add(label);
      stepValues.add(steps);
      calValues.add(cals);
    }
    if (dayLabels.isEmpty) {
      dayLabels.addAll(['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun']);
      stepValues.addAll([0, 0, 0, 0, 0, 0, 0]);
      calValues.addAll([0, 0, 0, 0, 0, 0, 0]);
    }
    final maxSteps = stepValues.isEmpty ? 1 : stepValues.reduce(math.max);
    final todayStr = DateFormat('yyyy-MM-dd').format(DateTime.now());

    return Container(
      decoration: const BoxDecoration(color: Color(0xFF141414), borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      padding: EdgeInsets.fromLTRB(24, 16, 24, MediaQuery.of(context).padding.bottom + 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(width: 36, height: 4, decoration: BoxDecoration(color: _T.lo, borderRadius: BorderRadius.circular(2))),
          const SizedBox(height: 20),
          Text('Weekly Breakdown', style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white)),
          const SizedBox(height: 8),
          // Summary row
          Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
            _sheetStat('$totalSteps', 'Steps'),
            Container(width: 1, height: 24, color: _T.divider),
            _sheetStat('$totalCalories', 'kcal'),
            Container(width: 1, height: 24, color: _T.divider),
            _sheetStat('$avgStepsPerDay', 'Avg/Day'),
          ]),
          const SizedBox(height: 20),
          // Day rows
          ...List.generate(dayLabels.length, (i) {
            final pct = maxSteps > 0 ? (stepValues[i] / maxSteps * 100).clamp(3, 100) : 3;
            bool isToday = false;
            try {
              if (i < daysList.length) {
                isToday = (daysList[i] as Map)['date'] == todayStr;
              }
            } catch (_) {}
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(children: [
                SizedBox(width: 40, child: Text(dayLabels[i], style: GoogleFonts.inter(fontSize: 13, fontWeight: isToday ? FontWeight.w700 : FontWeight.w400, color: isToday ? _T.accent : _T.mid))),
                Expanded(child: Container(
                  height: 8,
                  decoration: BoxDecoration(color: _T.card2, borderRadius: BorderRadius.circular(4)),
                  child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: pct / 100,
                    child: Container(decoration: BoxDecoration(
                      gradient: isToday ? _T.accentGrad : const LinearGradient(colors: [Color(0xFF30D158), Color(0xFF30D158)]),
                      borderRadius: BorderRadius.circular(4),
                    )),
                  ),
                )),
                const SizedBox(width: 10),
                SizedBox(width: 80, child: Text('${stepValues[i]} · ${calValues[i]}', textAlign: TextAlign.end, style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: isToday ? _T.accent : _T.hi))),
              ]),
            );
          }),
          const SizedBox(height: 16),
          Container(
            width: double.infinity, padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(color: _T.card2, borderRadius: BorderRadius.circular(14)),
            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              const Icon(Icons.info_outline_rounded, color: _T.mid, size: 16),
              const SizedBox(width: 8),
              Text('Steps · kcal per day', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w500, color: _T.mid)),
            ]),
          ),
        ],
      ),
    );
  }

  Widget _sheetStat(String val, String label) {
    return Column(children: [
      Text(val, style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700, color: _T.hi)),
      const SizedBox(height: 2),
      Text(label, style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w500, color: _T.mid, letterSpacing: 0.5)),
    ]);
  }
}

// ═══════════════════════════════════════════
//  TRACKING MAP SCREEN
// ═══════════════════════════════════════════
class _TrackingMapScreen extends StatefulWidget {
  final String sport;
  const _TrackingMapScreen({required this.sport});
  @override
  State<_TrackingMapScreen> createState() => _TrackingMapScreenState();
}

class _TrackingMapScreenState extends State<_TrackingMapScreen>
    with SingleTickerProviderStateMixin {
  bool _isRunning = false;
  late final AnimationController _pulse;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(vsync: this, duration: const Duration(milliseconds: 900))..repeat(reverse: true);
  }
  @override
  void dispose() { _pulse.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final isWalk = widget.sport == 'Walk';
    final sportColor = isWalk ? const Color(0xFF30D158) : const Color(0xFFFF6B2B);
    final sportIcon = isWalk ? Icons.directions_walk_rounded : Icons.directions_run_rounded;

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      body: Stack(children: [
        Positioned.fill(child: CustomPaint(painter: _StaticMapPainter(sportColor: sportColor))),
        SafeArea(child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
          child: Row(children: [
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(width: 40, height: 40, decoration: BoxDecoration(color: Colors.black.withOpacity(0.6), shape: BoxShape.circle), child: const Icon(Icons.arrow_back_rounded, color: Colors.white, size: 20)),
            ),
            const SizedBox(width: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(color: Colors.black.withOpacity(0.6), borderRadius: BorderRadius.circular(20)),
              child: Row(children: [Icon(sportIcon, color: sportColor, size: 16), const SizedBox(width: 6), Text(widget.sport, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white))]),
            ),
            const Spacer(),
            AnimatedBuilder(
              animation: _pulse,
              builder: (_, __) => Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: _isRunning ? sportColor.withOpacity(0.15 + _pulse.value * 0.1) : Colors.black.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: _isRunning ? sportColor.withOpacity(0.4) : Colors.transparent),
                ),
                child: Row(children: [
                  Container(width: 8, height: 8, decoration: BoxDecoration(color: _isRunning ? sportColor : const Color(0xFF8A8A8A), shape: BoxShape.circle)),
                  const SizedBox(width: 6),
                  Text(_isRunning ? 'LIVE' : 'READY', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w700, color: _isRunning ? sportColor : const Color(0xFF8A8A8A), letterSpacing: 0.8)),
                ]),
              ),
            ),
          ]),
        )),
        Positioned(
          top: 100, left: 20, right: 20,
          child: Row(children: [
            _mapStat('0.00', 'km', 'Distance'), const SizedBox(width: 10),
            _mapStat('00:00', 'min', 'Duration'), const SizedBox(width: 10),
            _mapStat('0', 'kcal', 'Calories'),
          ]),
        ),
        Center(child: AnimatedBuilder(
          animation: _pulse,
          builder: (_, __) => Stack(alignment: Alignment.center, children: [
            Container(width: 50 + _pulse.value * 20, height: 50 + _pulse.value * 20, decoration: BoxDecoration(shape: BoxShape.circle, color: sportColor.withOpacity(0.1 * (1 - _pulse.value)))),
            Container(width: 20, height: 20, decoration: BoxDecoration(color: sportColor, shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 3), boxShadow: [BoxShadow(color: sportColor.withOpacity(0.5), blurRadius: 8)])),
          ]),
        )),
        Positioned(
          bottom: 0, left: 0, right: 0,
          child: Container(
            decoration: BoxDecoration(color: const Color(0xFF141414), borderRadius: const BorderRadius.vertical(top: Radius.circular(28)), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.4), blurRadius: 20)]),
            padding: EdgeInsets.fromLTRB(24, 20, 24, MediaQuery.of(context).padding.bottom + 24),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Container(width: 36, height: 4, decoration: BoxDecoration(color: const Color(0xFF3A3A3A), borderRadius: BorderRadius.circular(2))),
              const SizedBox(height: 24),
              Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
                _bottomStat('— /km', 'Pace'),
                Container(width: 1, height: 32, color: const Color(0xFF252525)),
                _bottomStat('— bpm', 'Heart Rate'),
                Container(width: 1, height: 32, color: const Color(0xFF252525)),
                _bottomStat('0', 'Steps'),
              ]),
              const SizedBox(height: 24),
              GestureDetector(
                onTap: () { HapticFeedback.heavyImpact(); setState(() => _isRunning = !_isRunning); },
                child: Container(
                  width: double.infinity, height: 56,
                  decoration: BoxDecoration(
                    gradient: _isRunning
                        ? const LinearGradient(colors: [Color(0xFFEF4444), Color(0xFFDC2626)])
                        : const LinearGradient(colors: [Color(0xFFFF6B2B), Color(0xFFFF9A3C)]),
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [BoxShadow(color: (_isRunning ? const Color(0xFFEF4444) : const Color(0xFFFF6B2B)).withOpacity(0.3), blurRadius: 16, offset: const Offset(0, 4))],
                  ),
                  child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Icon(_isRunning ? Icons.stop_rounded : Icons.play_arrow_rounded, color: Colors.white, size: 26),
                    const SizedBox(width: 8),
                    Text(_isRunning ? 'Stop Session' : 'Start Session', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white)),
                  ]),
                ),
              ),
            ]),
          ),
        ),
      ]),
    );
  }

  Widget _mapStat(String val, String unit, String label) {
    return Expanded(child: Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(color: Colors.black.withOpacity(0.7), borderRadius: BorderRadius.circular(14)),
      child: Column(children: [
        RichText(text: TextSpan(children: [
          TextSpan(text: val, style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w700, color: Colors.white)),
          TextSpan(text: ' $unit', style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFF8A8A8A))),
        ])),
        const SizedBox(height: 2),
        Text(label, style: GoogleFonts.inter(fontSize: 11, color: const Color(0xFF6B6B6B))),
      ]),
    ));
  }

  Widget _bottomStat(String val, String label) {
    return Column(children: [
      Text(val, style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white)),
      const SizedBox(height: 3),
      Text(label, style: GoogleFonts.inter(fontSize: 11, color: const Color(0xFF8A8A8A))),
    ]);
  }
}

// ═══════════════════════════════════════════
//  PAINTERS
// ═══════════════════════════════════════════
class _StaticMapPainter extends CustomPainter {
  final Color sportColor;
  const _StaticMapPainter({required this.sportColor});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width; final h = size.height;
    canvas.drawRect(Rect.fromLTWH(0, 0, w, h), Paint()..color = const Color(0xFF1A1F2E));
    final sp = Paint()..color = const Color(0xFF252D3D)..strokeWidth = 1;
    for (double x = 0; x < w; x += 40) canvas.drawLine(Offset(x, 0), Offset(x, h), sp);
    for (double y = 0; y < h; y += 40) canvas.drawLine(Offset(0, y), Offset(w, y), sp);
    final rp = Paint()..color = const Color(0xFF2D3748)..strokeWidth = 8..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(0, h * 0.3), Offset(w, h * 0.3), rp);
    canvas.drawLine(Offset(0, h * 0.6), Offset(w, h * 0.6), rp);
    canvas.drawLine(Offset(w * 0.25, 0), Offset(w * 0.25, h), rp);
    canvas.drawLine(Offset(w * 0.7, 0), Offset(w * 0.7, h), rp);
    final bp = Paint()..color = const Color(0xFF222A3A);
    for (final b in [
      Rect.fromLTWH(w*.05,h*.05,w*.15,h*.2), Rect.fromLTWH(w*.3,h*.05,w*.35,h*.2),
      Rect.fromLTWH(w*.75,h*.05,w*.2,h*.2),  Rect.fromLTWH(w*.05,h*.35,w*.15,h*.2),
      Rect.fromLTWH(w*.3,h*.35,w*.35,h*.2),  Rect.fromLTWH(w*.75,h*.35,w*.2,h*.2),
      Rect.fromLTWH(w*.05,h*.65,w*.15,h*.28),Rect.fromLTWH(w*.3,h*.65,w*.35,h*.28),
      Rect.fromLTWH(w*.75,h*.65,w*.2,h*.28),
    ]) canvas.drawRRect(RRect.fromRectAndRadius(b, const Radius.circular(4)), bp);

    final rs = Paint()..color = sportColor.withOpacity(0.25)..strokeWidth = 10..style = PaintingStyle.stroke..strokeCap = StrokeCap.round..strokeJoin = StrokeJoin.round;
    final rpt = Paint()..color = sportColor..strokeWidth = 4..style = PaintingStyle.stroke..strokeCap = StrokeCap.round..strokeJoin = StrokeJoin.round;
    final path = Path()
      ..moveTo(w*.25,h*.65)..lineTo(w*.25,h*.60)..lineTo(w*.70,h*.60)
      ..lineTo(w*.70,h*.30)..lineTo(w*.25,h*.30)..lineTo(w*.25,h*.50);
    canvas.drawPath(path, rs);
    canvas.drawPath(path, rpt);
    canvas.drawCircle(Offset(w*.25,h*.65), 8, Paint()..color = sportColor);
    canvas.drawCircle(Offset(w*.25,h*.65), 5, Paint()..color = Colors.white);
  }

  @override
  bool shouldRepaint(_StaticMapPainter o) => o.sportColor != sportColor;
}

class _HeroArcPainter extends CustomPainter {
  final double progress;
  const _HeroArcPainter({required this.progress});

  @override
  void paint(Canvas c, Size s) {
    final center = Offset(s.width / 2, s.height / 2);
    final r = s.width / 2 - 16;
    final trackPaint = Paint()..color = const Color(0xFF2A2A2A)..strokeWidth = 14..style = PaintingStyle.stroke..strokeCap = StrokeCap.round;
    final progressPaint = Paint()
      ..shader = LinearGradient(colors: const [Color(0xFFFF6B2B), Color(0xFFFFCC00)], begin: Alignment.centerLeft, end: Alignment.centerRight)
          .createShader(Rect.fromCircle(center: center, radius: r))
      ..strokeWidth = 14..style = PaintingStyle.stroke..strokeCap = StrokeCap.round;
    const startAngle = math.pi * 0.65;
    const sweepAngle = math.pi * 1.7;
    c.drawArc(Rect.fromCircle(center: center, radius: r), startAngle, sweepAngle, false, trackPaint);
    if (progress > 0) {
      c.drawArc(Rect.fromCircle(center: center, radius: r), startAngle, sweepAngle * progress, false, progressPaint);
    }
  }

  @override
  bool shouldRepaint(_HeroArcPainter o) => o.progress != progress;
}