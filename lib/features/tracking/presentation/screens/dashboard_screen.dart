
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
import 'package:easyfit_clinics/core/router/route_names.dart';
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
import '../../../../core/api_constants.dart';
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
  bool _isTracking = true; // always-on tracking (no more play/pause)
  int _lastCompletedSteps = 0; // steps from last stopped session (survive cross-check zero)
  
  // Persisted phase level (0=Activation, 1=FatLoss, 2=Metabolic, 3=Transformation, 4=LimitZone)
  // Only advances after 3 consecutive days of meeting the current phase goal.
  int _currentPhaseLevel = 0;
  
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
    _loadPhaseLevel(); // restore persisted phase level
    
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
    } else {
      // New day (or first launch) — clear ALL stale daily data
      debugPrint('🌅 New day detected ($savedDate → $today), clearing stale data');
      _lastCompletedSteps = 0;
      await prefs.remove('completed_steps_today');
      await prefs.remove('completed_steps_date');
      // Clear stale hourly step data (stats Day tab)
      for (int h = 0; h < 24; h++) {
        await prefs.remove('hourly_steps_$h');
      }
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
    // Uses effectiveSteps (max of all sources — prevents double-counting)
    if (effectiveSteps >= 1000 && !tablet && !water && !walk) {
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
    
    // Show celebration ONLY ONCE per day
    final alreadyShown = prefs.getBool('habit_celebration_shown_$today') ?? false;
    if (!alreadyShown) {
      await prefs.setBool('habit_celebration_shown_$today', true);
      HapticFeedback.heavyImpact();
      
      MilestoneCelebrationOverlay.show(
        context,
        icon: '✅',
        title: 'All Habits Done!',
        subtitle: '💊 Tablet · 💧 Water · 🚶 Walk\nGreat start to the day!',
        accentColor: const Color(0xFF30D158),
      );
    }
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
      
      // 3. Reset completed steps for the new day
      _lastCompletedSteps = 0;
      
      // 4. Clear hourly step data and stale completed steps
      final prefs = await SharedPreferences.getInstance();
      for (int h = 0; h < 24; h++) {
        await prefs.remove('hourly_steps_$h');
      }
      await prefs.remove('completed_steps_today');
      await prefs.remove('completed_steps_date');
      
      // 5. Refresh dashboard API data (will fetch new "today")
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
      // Session exists locally — validate with backend by calling startSession
      // Backend will either resume the same session (if still valid) or
      // abandon the stale one and return a new session ID
      try {
        final repo = ref.read(trackingRepositoryProvider);
        Map<String, dynamic> sessionResponse;
        try {
          sessionResponse = await repo.startSession(0);
        } on DioException catch (e) {
          if (e.response?.statusCode == 400) {
            // Force-close the orphan and retry
            try {
              await repo.stopSession(sessionId: 'force-close', finalSteps: 0, finalCalories: 0, finalDistance: 0.0);
            } catch (_) {}
            await Future.delayed(const Duration(milliseconds: 500));
            sessionResponse = await repo.startSession(0);
          } else {
            rethrow;
          }
        }
        
        final validSessionId = sessionResponse['sessionId'] ?? sessionResponse['id'] ?? '';
        final resumed = sessionResponse['resumed'] ?? false;
        
        if (validSessionId.toString().isNotEmpty) {
          // Update local session ID (might be the same or a new one)
          await prefs.setString('active_session_id', validSessionId.toString());
          
          if (!resumed) {
            // Backend gave us a NEW session (old one was stale) — reset local counters
            debugPrint('🔄 Stale session detected, got fresh session: $validSessionId');
            await prefs.setInt('session_accumulated_steps', 0);
            ref.read(pedometerProvider.notifier).startSession();
          } else {
            debugPrint('✅ Session resumed: $validSessionId');
            // DON'T call startSession() for resumed sessions — it resets _baseSteps
            // and _accumulatedSteps, causing the pedometer to freeze at 0.
            // Instead, just ensure tracking is on without resetting counters.
            ref.read(pedometerProvider.notifier).resumeSession();
          }
        }
      } catch (e) {
        debugPrint('⚠️ Session validation failed: $e — using local session');
        // Even if server is unreachable, resume pedometer tracking locally
        ref.read(pedometerProvider.notifier).resumeSession();
      }
      
      // Session valid — resume tracking UI
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
      
      // Start auto-refreshing stats
      ref.read(dashboardProvider.notifier).startAutoRefresh();
    } else {
      // No session — AUTO-START one silently
      debugPrint('🚀 No active session found, auto-starting...');
      await _autoStartSession();
    }
  }

  /// Silently start a new tracking session (no button press needed)
  Future<void> _autoStartSession() async {
    try {
      // Request notification permission so the background service can show its persistent notification
      await Permission.notification.request();
      // Request battery optimization bypass (critical for Samsung — prevents OS from killing background service)
      if (await Permission.ignoreBatteryOptimizations.isDenied) {
        await Permission.ignoreBatteryOptimizations.request();
      }
      // Note: activity recognition permission is handled by pedometer_provider

      final prefs = await SharedPreferences.getInstance();
      final repo = ref.read(trackingRepositoryProvider);
      final service = FlutterBackgroundService();
      
      // Stop any stale background service first
      service.invoke('stopService');
      await Future.delayed(const Duration(milliseconds: 300));
      
      // Clear stale local session data
      await prefs.remove('active_session_id');
      await prefs.remove('session_accumulated_steps');
      await prefs.setInt('synced_steps_offset', 0);
      
      // Reset pedometer & start counting fresh
      ref.read(pedometerProvider.notifier).startSession();
      
      // Start session on backend
      Map<String, dynamic> sessionResponse;
      try {
        sessionResponse = await repo.startSession(0);
      } on DioException catch (e) {
        if (e.response?.statusCode == 400) {
          // Orphan session exists — try to close it first
          debugPrint('⚠️ Active session exists on server, closing orphan...');
          try {
            await repo.stopSession(
              sessionId: 'force-close',
              finalSteps: 0,
              finalCalories: 0,
              finalDistance: 0.0,
            );
          } catch (_) {}
          await Future.delayed(const Duration(milliseconds: 500));
          sessionResponse = await repo.startSession(0);
        } else {
          rethrow;
        }
      }
      
      final sessionId = sessionResponse['sessionId'] ?? sessionResponse['id'] ?? '';
      if (sessionId.toString().isEmpty) {
        throw Exception('No sessionId returned from server');
      }
      
      debugPrint('🟢 Auto-started session: $sessionId');
      await prefs.setString('active_session_id', sessionId.toString());
      
      // Start background service
      await Future.delayed(const Duration(milliseconds: 100));
      service.startService();
      
      // Start auto-refreshing
      ref.read(dashboardProvider.notifier).startAutoRefresh();
      
      if (mounted) {
        setState(() {
          _isTracking = true;
          _ac.repeat(reverse: true);
          _glowAc.repeat(reverse: true);
        });
      }
    } catch (e) {
      debugPrint('❌ Auto-start failed: $e');
    }
  }

  /// Silent sync: stop current session → start new one → navigate
  /// This commits steps to stats/reports without the user pressing anything
  Future<void> _silentSyncAndNavigate(String route) async {
    // Show a brief loading indicator
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(children: [
            const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)),
            const SizedBox(width: 12),
            Text('Syncing data...', style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.w600)),
          ]),
          backgroundColor: _T.card2,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.all(16),
          duration: const Duration(seconds: 2),
        ),
      );
    }
    
    try {
      final prefs = await SharedPreferences.getInstance();
      final repo = ref.read(trackingRepositoryProvider);
      final sessionIdToStop = prefs.getString('active_session_id') ?? '';
      
      if (sessionIdToStop.isNotEmpty) {
        // IMPORTANT: Stop background service FIRST to prevent race conditions
        final service = FlutterBackgroundService();
        service.invoke('stopService');
        await Future.delayed(const Duration(milliseconds: 500));
        
        // Get the values
        final livePedometerSteps = ref.read(pedometerProvider).value ?? 0;
        final sessionSteps = ref.read(pedometerProvider.notifier).currentSessionSteps;
        final bgAccumulatedSteps = prefs.getInt('session_accumulated_steps') ?? 0;
        // The true session steps is the max of the foreground and the background
        final finalSteps = math.max(sessionSteps, bgAccumulatedSteps);
        final finalCalories = (finalSteps * 0.045).round();
        final finalDistance = double.parse((finalSteps * 0.000762).toStringAsFixed(3));
        
        debugPrint('📊 Silent sync: sessionSteps=$sessionSteps, liveDisplay=$livePedometerSteps, final=$finalSteps');
        
        // SYNC first — ensures backend has latest steps even if stopSession fails
        try {
          await repo.syncSteps(
            sessionId: sessionIdToStop,
            steps: finalSteps,
            calories: finalCalories,
            distance: finalDistance,
          );
          debugPrint('✅ Pre-stop sync sent: $finalSteps steps');
        } catch (e) {
          debugPrint('⚠️ Pre-stop sync failed: $e');
        }
        
        // STOP session → commits to backend stats/reports
        try {
          await repo.stopSession(
            sessionId: sessionIdToStop,
            finalSteps: finalSteps,
            finalCalories: finalCalories,
            finalDistance: finalDistance,
          );
        } catch (e) {
          debugPrint('⚠️ Stop session API failed: $e');
        }
        
        // Calculate the exact total steps the user sees on the screen right now
        final apiSteps = (ref.read(dashboardProvider).todayActivity?['steps'] ?? 0) as num;
        final totalDisplaySteps = [apiSteps.toInt(), sessionSteps, _lastCompletedSteps].reduce((a, b) => a > b ? a : b);
        
        // Save the total as _lastCompletedSteps so the UI doesn't drop to 0 while waiting for API refresh
        _lastCompletedSteps = math.max(_lastCompletedSteps, totalDisplaySteps);
        final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
        await prefs.setInt('completed_steps_today', _lastCompletedSteps);
        await prefs.setString('completed_steps_date', today);
        
        // Clear old session
        await prefs.remove('active_session_id');
        await prefs.remove('session_accumulated_steps');
        
        // START a new session immediately
        ref.read(pedometerProvider.notifier).startSession();
        
        Map<String, dynamic> sessionResponse;
        try {
          sessionResponse = await repo.startSession(0);
        } on DioException catch (e) {
          if (e.response?.statusCode == 400) {
            try {
              await repo.stopSession(sessionId: 'force-close', finalSteps: 0, finalCalories: 0, finalDistance: 0.0);
            } catch (_) {}
            await Future.delayed(const Duration(milliseconds: 500));
            sessionResponse = await repo.startSession(0);
          } else {
            rethrow;
          }
        }
        
        final newSessionId = sessionResponse['sessionId'] ?? sessionResponse['id'] ?? '';
        if (newSessionId.toString().isNotEmpty) {
          await prefs.setString('active_session_id', newSessionId.toString());
          debugPrint('🟢 Silent sync done. New session: $newSessionId');
        }
        
        // Restart background service with new session
        service.startService();
      }
      
      // Refresh dashboard data
      await ref.read(dashboardProvider.notifier).refresh();
      
    } catch (e) {
      debugPrint('❌ Silent sync failed: $e');
    }
    
    // Navigate to the target screen
    if (mounted) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      context.go(route);
    }
  }

  /// Silent sync without navigation (for in-page tabs like Reports)
  Future<void> _silentSyncForTab() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final repo = ref.read(trackingRepositoryProvider);
      final sessionIdToStop = prefs.getString('active_session_id') ?? '';
      
      if (sessionIdToStop.isNotEmpty) {
        // IMPORTANT: Stop background service FIRST to prevent race conditions
        final service = FlutterBackgroundService();
        service.invoke('stopService');
        await Future.delayed(const Duration(milliseconds: 500));
        
        // Get the values
        final livePedometerSteps = ref.read(pedometerProvider).value ?? 0;
        final sessionSteps = ref.read(pedometerProvider.notifier).currentSessionSteps;
        final bgAccumulatedSteps = prefs.getInt('session_accumulated_steps') ?? 0;
        final finalSteps = math.max(sessionSteps, bgAccumulatedSteps);
        final finalCalories = (finalSteps * 0.045).round();
        final finalDistance = double.parse((finalSteps * 0.000762).toStringAsFixed(3));
        
        // SYNC first — ensures backend has latest steps even if stopSession fails
        try {
          await repo.syncSteps(
            sessionId: sessionIdToStop,
            steps: finalSteps,
            calories: finalCalories,
            distance: finalDistance,
          );
          debugPrint('✅ Pre-stop tab sync sent: $finalSteps steps');
        } catch (e) {
          debugPrint('⚠️ Pre-stop tab sync failed: $e');
        }
        
        // STOP session
        try {
          await repo.stopSession(
            sessionId: sessionIdToStop,
            finalSteps: finalSteps,
            finalCalories: finalCalories,
            finalDistance: finalDistance,
          );
        } catch (e) {
          debugPrint('⚠️ Silent tab sync stop failed: $e');
        }
        
        // Calculate total display steps
        final apiSteps = (ref.read(dashboardProvider).todayActivity?['steps'] ?? 0) as num;
        final totalDisplaySteps = [apiSteps.toInt(), sessionSteps, _lastCompletedSteps].reduce((a, b) => a > b ? a : b);
        
        // Save
        _lastCompletedSteps = math.max(_lastCompletedSteps, totalDisplaySteps);
        final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
        await prefs.setInt('completed_steps_today', _lastCompletedSteps);
        await prefs.setString('completed_steps_date', today);
        
        // Clear old session
        await prefs.remove('active_session_id');
        await prefs.remove('session_accumulated_steps');
        
        // START new session
        ref.read(pedometerProvider.notifier).startSession();
        
        Map<String, dynamic> sessionResponse;
        try {
          sessionResponse = await repo.startSession(0);
        } on DioException catch (e) {
          if (e.response?.statusCode == 400) {
            try {
              await repo.stopSession(sessionId: 'force-close', finalSteps: 0, finalCalories: 0, finalDistance: 0.0);
            } catch (_) {}
            await Future.delayed(const Duration(milliseconds: 500));
            sessionResponse = await repo.startSession(0);
          } else {
            rethrow;
          }
        }
        
        final newSessionId = sessionResponse['sessionId'] ?? sessionResponse['id'] ?? '';
        if (newSessionId.toString().isNotEmpty) {
          await prefs.setString('active_session_id', newSessionId.toString());
        }
        
        // Restart background service with new session
        service.startService();
      }
      
      // Refresh dashboard data
      await ref.read(dashboardProvider.notifier).refresh();
    } catch (e) {
      debugPrint('❌ Silent tab sync failed: $e');
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
      // Use max (same as hero card) — prevents stale API data from triggering
      final totalDailySteps = [apiSteps.toInt(), sessionSteps, _lastCompletedSteps].reduce((a, b) => a > b ? a : b);
      // Extra guard: only auto-complete if we have real walking evidence today
      // (sessionSteps > 0 means the pedometer actually counted steps this session)
      if (totalDailySteps >= 1000 && sessionSteps > 50) {
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
      drawer: Drawer(
        backgroundColor: _T.bg,
        child: Column(
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(
                color: _T.card,
                border: Border(bottom: BorderSide(color: Colors.white10)),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: _T.accent.withOpacity(0.1),
                    child: Text(
                      ref.watch(dashboardProvider).todayActivity?['user_name']?[0] ?? 'S',
                      style: const TextStyle(color: _T.accent, fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          ref.watch(dashboardProvider).todayActivity?['user_name'] ?? 'User',
                          style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const Text(
                          'EasyFit Member',
                          style: TextStyle(color: Colors.white38, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.person_outline, color: Colors.white70),
              title: const Text('My Profile', style: TextStyle(color: Colors.white70)),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.settings_outlined, color: Colors.white70),
              title: const Text('Settings', style: TextStyle(color: Colors.white70)),
              onTap: () => Navigator.pop(context),
            ),
            const Spacer(),
            const Divider(color: Colors.white10),
            ListTile(
              leading: const Icon(Icons.logout_rounded, color: Colors.redAccent),
              title: const Text('Logout', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
              onTap: () async {
                // ✅ Close drawer first
                Navigator.pop(context);
                await provider.Provider.of<AuthProvider>(context, listen: false).logoutApi();
                if (mounted) {
                  context.go(RouteNames.login);
                }
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
      body: SafeArea(bottom: false, child: _body(state, sessionSteps)),
      bottomNavigationBar: _bottomPill(),
      // FAB only on Home tab
      floatingActionButton: null,
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

  // ── PHASE PERSISTENCE ────────────────────────────────────
  /// Load persisted phase level from SharedPreferences
  Future<void> _loadPhaseLevel() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getInt('current_phase_level') ?? 0;
    if (mounted) setState(() => _currentPhaseLevel = saved);
  }

  /// Save current phase level to SharedPreferences
  Future<void> _savePhaseLevel(int level) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('current_phase_level', level);
  }

  /// Check weekly data and promote phase if user has 3 consecutive days
  /// of completing the current phase goal.
  void _checkPhasePromotion(List<dynamic> daysList, int currentSteps) {
    if (_currentPhaseLevel >= 4) return; // already at Limit Zone
    final goal = _getPhaseGoalForLevel(_currentPhaseLevel);
    
    // Count consecutive days (most recent first) where user met the goal
    final todayStr = DateFormat('yyyy-MM-dd').format(DateTime.now());
    int consecutiveDays = 0;
    
    // Check today first
    if (currentSteps >= goal) {
      consecutiveDays = 1;
    } else {
      return; // today not met, can't have 3 consecutive ending today
    }
    
    // Sort days by date descending and walk backwards from yesterday
    final sortedDays = List<Map<String, dynamic>>.from(
      daysList.map((d) => d as Map<String, dynamic>)
    )..sort((a, b) => (b['date'] ?? '').compareTo(a['date'] ?? ''));
    
    for (final d in sortedDays) {
      final dateStr = d['date'] ?? '';
      if (dateStr == todayStr) continue; // already counted
      if (dateStr.compareTo(todayStr) > 0) continue; // skip future dates
      final daySteps = ((d['steps'] ?? 0) as num).toInt();
      if (daySteps >= goal) {
        consecutiveDays++;
      } else {
        break;
      }
    }
    
    // Promote if 3+ consecutive days
    if (consecutiveDays >= 3 && _currentPhaseLevel < 4) {
      final newLevel = _currentPhaseLevel + 1;
      setState(() => _currentPhaseLevel = newLevel);
      _savePhaseLevel(newLevel);
      debugPrint('🎯 Phase promoted! Level $newLevel after $consecutiveDays consecutive days');
    }
  }

  // ── STEP PHASE HELPER ──────────────────────────────────
  /// Phase names by level index
  static const _phaseNames = [
    'Activation Phase',     // level 0: goal 5000
    'Fat Loss Phase',       // level 1: goal 7000
    'Metabolic Phase',      // level 2: goal 10000
    'Transformation Phase', // level 3: goal 12000
    'Limit Zone',           // level 4: goal 15000 (max)
  ];
  static const _phaseGoals = [5000, 7000, 10000, 12000, 15000];
  static const _phaseIcons = [
    Icons.rocket_launch_rounded,    // level 0: Activation Phase
    Icons.local_fire_department_rounded, // level 1: Fat Loss Phase
    Icons.bolt_rounded,             // level 2: Metabolic Phase
    Icons.fitness_center_rounded,   // level 3: Transformation Phase
    Icons.emoji_events_rounded,     // level 4: Limit Zone
  ];

  /// Get icon for a phase level
  static IconData _getPhaseIconForLevel(int level) {
    return _phaseIcons[level.clamp(0, 4)];
  }

  /// Get phase name from the persisted level
  static String _getPhaseNameForLevel(int level) {
    return _phaseNames[level.clamp(0, 4)];
  }

  /// Get goal for a phase level
  static int _getPhaseGoalForLevel(int level) {
    return _phaseGoals[level.clamp(0, 4)];
  }

  /// Get next phase name (null if at max)
  static String? _getNextPhaseNameForLevel(int level) {
    if (level >= 4) return null;
    return _phaseNames[level + 1];
  }

  /// Steps remaining to complete the current phase goal
  static int _stepsToCompleteGoal(int steps, int level) {
    final goal = _getPhaseGoalForLevel(level);
    return (goal - steps).clamp(0, goal);
  }

  // ── LEGACY HELPERS (used by hero card) ─────────────────
  /// Returns the phase name based on current step count (for display only).
  static String _getPhaseName(int steps) {
    if (steps <= 5000) return 'Activation Phase';
    if (steps <= 7000) return 'Fat Loss Phase';
    if (steps <= 10000) return 'Metabolic Phase';
    if (steps <= 12000) return 'Transformation Phase';
    return 'Limit Zone';
  }

  static String? _getNextPhaseName(int steps) {
    if (steps <= 5000) return 'Fat Loss Phase';
    if (steps <= 7000) return 'Metabolic Phase';
    if (steps <= 10000) return 'Transformation Phase';
    if (steps <= 12000) return 'Limit Zone';
    return null;
  }

  static int _stepsToNextPhase(int steps) {
    if (steps <= 5000) return 5001 - steps;
    if (steps <= 7000) return 7001 - steps;
    if (steps <= 10000) return 10001 - steps;
    if (steps <= 12000) return 12001 - steps;
    return 0;
  }

  /// Goal for each phase — now uses persisted level
  int _getPhaseGoal(int steps) {
    return _getPhaseGoalForLevel(_currentPhaseLevel);
  }

  // ── HERO CARD ────────────────────────────────────────────
  Widget _heroCard(DashboardState state, int sessionSteps) {
    var rawCalories = state.todayActivity?['calories'] ?? 0.0;
    final apiSteps = (state.todayActivity?['steps'] ?? 0) as num;
    
    // Use the HIGHEST value from all sources — never drops, never double-counts:
    // - apiSteps: total steps synced to backend for today
    // - sessionSteps: live pedometer count for current session
    // - _lastCompletedSteps: cached fallback between session restarts
    final steps = [apiSteps.toInt(), sessionSteps, _lastCompletedSteps].reduce((a, b) => a > b ? a : b);
    
    // Fallback: If API gave us 0 calories, dynamically generate it based on total steps
    if (rawCalories == 0.0 || rawCalories == 0) {
      rawCalories = steps * 0.045; // Approx 45 calories per 1000 steps
    }
    final calories = rawCalories.toInt();
    
    final goal = _getPhaseGoal(steps);
    final progress = (steps / goal).clamp(0.0, 1.0);
    final phaseName = _getPhaseNameForLevel(_currentPhaseLevel);
    
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
    final apiSteps = ((state.todayActivity?['steps'] ?? 0) as num).toInt();
    final liveSteps = ref.watch(pedometerProvider).valueOrNull ?? 0;
    final currentSteps = [apiSteps, liveSteps, _lastCompletedSteps].reduce((a, b) => a > b ? a : b);
    
    // Use persisted phase level (advances only after 3 consecutive days)
    final currentPhase = _getPhaseNameForLevel(_currentPhaseLevel);
    final nextPhase = _getNextPhaseNameForLevel(_currentPhaseLevel);
    final phaseGoal = _getPhaseGoalForLevel(_currentPhaseLevel);
    final remaining = _stepsToCompleteGoal(currentSteps, _currentPhaseLevel);

    // Calculate streak: how many consecutive days (including today) the user
    // completed the current phase goal.
    final weeklyData = state.weeklyStats ?? {};
    final daysList = (weeklyData['days'] as List<dynamic>?) ?? [];

    int streakDays = 0;
    final todayStr = DateFormat('yyyy-MM-dd').format(DateTime.now());
    
    // Check if today's steps meet the goal
    if (currentSteps >= phaseGoal) {
      streakDays = 1;
    }
    
    if (daysList.isNotEmpty) {
      // Sort days by date descending so we walk backwards from most recent
      final sortedDays = List<Map<String, dynamic>>.from(
        daysList.map((d) => d as Map<String, dynamic>)
      )..sort((a, b) => (b['date'] ?? '').compareTo(a['date'] ?? ''));
      
      // Walk backwards from yesterday (skip today, skip future dates)
      for (final d in sortedDays) {
        final dateStr = d['date'] ?? '';
        if (dateStr == todayStr) continue; // skip today (already counted above)
        if (dateStr.compareTo(todayStr) > 0) continue; // skip future dates
        final daySteps = ((d['steps'] ?? 0) as num).toInt();
        if (daySteps >= phaseGoal) {
          streakDays++;
        } else {
          break; // streak broken
        }
      }
    }
    streakDays = streakDays.clamp(0, 7);
    debugPrint('🔥 Streak: $streakDays days (goal: $phaseGoal, today: $currentSteps)');

    // Check for phase promotion (3 consecutive days)
    if (daysList.isNotEmpty) {
      _checkPhasePromotion(daysList, currentSteps);
    }

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

    // Show how many days of consistency achieved out of 3 needed
    final daysNeeded = 3;
    final streakSubtitle = nextPhase != null
        ? (streakDays >= daysNeeded
            ? '🎯 $streakDays day streak! Advancing to $nextPhase'
            : '$streakDays/$daysNeeded days to unlock $nextPhase • ${remaining > 0 ? "$remaining steps left today" : "✅ Today\'s goal done!"}')
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
                      child: Icon(_getPhaseIconForLevel(_currentPhaseLevel), color: _T.accent, size: 24),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(currentPhase, style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w800, color: _T.hi)),
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
                          Icon(_getPhaseIconForLevel(_currentPhaseLevel), color: _T.accent, size: 20),
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
          _profileTile(Icons.workspace_premium_rounded, 'Subscription', badge: 'Free'),
          const SizedBox(height: 8),
          _profileTile(Icons.logout_rounded, 'Sign Out', danger: true, onTap: () async {
            Navigator.pop(context);
            final authProv = provider.Provider.of<AuthProvider>(context, listen: false);
            await authProv.logoutApi();
            FlutterBackgroundService().invoke('stopService');
            if (mounted) {
              context.go(RouteNames.login);
            }
          }),
          const SizedBox(height: 4),
          _profileTile(Icons.delete_forever_rounded, 'Delete Account', danger: true, onTap: () {
            Navigator.pop(context);
            _showDeleteAccountDialog();
          }),
        ]),
      ),
    );
  }

  void _showDeleteAccountDialog() {
    final passwordController = TextEditingController();
    bool isLoading = false;
    bool obscure = true;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          backgroundColor: const Color(0xFF1A1A1A),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(children: [
            const Icon(Icons.warning_amber_rounded, color: Colors.redAccent, size: 24),
            const SizedBox(width: 10),
            Text('Delete Account', style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.redAccent)),
          ]),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'This action is permanent and cannot be undone. All your data will be deleted.',
                style: GoogleFonts.inter(fontSize: 13, color: _T.mid, height: 1.5),
              ),
              const SizedBox(height: 20),
              Text('Enter your password to confirm:', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: _T.hi)),
              const SizedBox(height: 10),
              TextField(
                controller: passwordController,
                obscureText: obscure,
                style: GoogleFonts.inter(color: _T.hi, fontSize: 14),
                decoration: InputDecoration(
                  hintText: 'Password',
                  hintStyle: GoogleFonts.inter(color: _T.lo),
                  filled: true,
                  fillColor: const Color(0xFF0A0A0A),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: _T.divider)),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: _T.divider)),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.redAccent)),
                  suffixIcon: IconButton(
                    icon: Icon(obscure ? Icons.visibility_off_rounded : Icons.visibility_rounded, color: _T.lo, size: 20),
                    onPressed: () => setDialogState(() => obscure = !obscure),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: isLoading ? null : () => Navigator.pop(ctx),
              child: Text('Cancel', style: GoogleFonts.inter(color: _T.mid, fontWeight: FontWeight.w600)),
            ),
            TextButton(
              onPressed: isLoading ? null : () async {
                final password = passwordController.text.trim();
                if (password.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Please enter your password', style: GoogleFonts.inter(color: Colors.white)),
                      backgroundColor: Colors.redAccent,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      margin: const EdgeInsets.all(16),
                    ),
                  );
                  return;
                }

                setDialogState(() => isLoading = true);
                try {
                  final dio = ApiClient().dio;
                  await dio.delete(
                    ApiConstants.deleteAccount,
                    data: {'password': password},
                  );

                  // Success — clear everything and go to login
                  Navigator.pop(ctx);
                  FlutterBackgroundService().invoke('stopService');
                  final prefs = await SharedPreferences.getInstance();
                  await prefs.clear();
                  ApiClient().clearToken();

                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Account deleted successfully', style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.w600)),
                        backgroundColor: _T.green,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        margin: const EdgeInsets.all(16),
                      ),
                    );
                    context.go(RouteNames.login);
                  }
                } on DioException catch (e) {
                  setDialogState(() => isLoading = false);
                  String msg = 'Failed to delete account';
                  if (e.response?.statusCode == 401) msg = 'Incorrect password';
                  if (e.response?.statusCode == 404) msg = 'Account not found';
                  final responseData = e.response?.data;
                  if (responseData is Map && responseData['message'] != null) {
                    msg = responseData['message'];
                  }
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(msg, style: GoogleFonts.inter(color: Colors.white)),
                      backgroundColor: Colors.redAccent,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      margin: const EdgeInsets.all(16),
                    ),
                  );
                } catch (e) {
                  setDialogState(() => isLoading = false);
                  debugPrint('❌ Delete account error: $e');
                }
              },
              child: isLoading
                  ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.redAccent))
                  : Text('Delete', style: GoogleFonts.inter(color: Colors.redAccent, fontWeight: FontWeight.w700)),
            ),
          ],
        ),
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
        
        final prefs = await SharedPreferences.getInstance();
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
            // ── START SESSION ──────────────────────────────
            // CRITICAL: Android 13+ Notification Prompt
            await Permission.notification.request();
            // CRITICAL: Android 14 Health Foreground Rules
            await Permission.activityRecognition.request();
            
            // Stop any old stale background service first
            service.invoke('stopService');
            await Future.delayed(const Duration(milliseconds: 300));
            
            // Clear any stale local session data (handles reinstall scenario)
            await prefs.remove('active_session_id');
            await prefs.remove('session_accumulated_steps');
            
            // Reset pedometer & start counting fresh for this session
            // NOTE: _lastCompletedSteps is intentionally kept — previous session steps stay visible
            ref.read(pedometerProvider.notifier).startSession();
            
            // Try to start session on backend
            // If backend returns 400 "active session exists", try to stop orphan & retry
            Map<String, dynamic> sessionResponse;
            try {
              sessionResponse = await repo.startSession(0);
            } on DioException catch (e) {
              if (e.response?.statusCode == 400) {
                // Backend says there's an active session — try to force-stop it
                debugPrint('⚠️ Active session exists on server, attempting to close orphan...');
                
                // Try to stop with empty/dummy data so backend closes the orphan
                try {
                  // Some backends accept stop without a valid sessionId for the current user
                  await repo.stopSession(
                    sessionId: 'force-close',
                    finalSteps: 0,
                    finalCalories: 0,
                    finalDistance: 0.0,
                  );
                  debugPrint('🧹 Orphan session force-closed');
                } catch (stopErr) {
                  debugPrint('⚠️ Force-close failed: $stopErr (backend may auto-close on retry)');
                }
                
                // Wait a moment then retry start
                await Future.delayed(const Duration(milliseconds: 500));
                sessionResponse = await repo.startSession(0);
                debugPrint('🔄 Retry start succeeded!');
              } else {
                rethrow; // Not a 400, let outer catch handle it
              }
            }
            
            final sessionId = sessionResponse['sessionId'] ?? sessionResponse['id'] ?? '';
            final httpStatus = sessionResponse['_httpStatus'] ?? 201;
            
            if (sessionId.toString().isEmpty) {
              throw Exception('No sessionId returned from server');
            }
            
            debugPrint('🟢 Session ${httpStatus == 200 ? "RESUMED" : "CREATED"}: $sessionId');
            
            await prefs.setString('active_session_id', sessionId.toString());
            
            // NOW start service — session ID is guaranteed saved
            await Future.delayed(const Duration(milliseconds: 100));
            service.startService();
            
            // Start auto-refreshing stats every 30 seconds
            ref.read(dashboardProvider.notifier).startAutoRefresh();
            
            debugPrint('========= SESSION STARTED VERIFIED =========');
            if (mounted) {
              final msg = httpStatus == 200
                  ? '🔄 Session resumed!'
                  : '⚡ Tracking session started!';
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(msg, style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.w600)),
                  backgroundColor: _T.green,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  margin: const EdgeInsets.all(16),
                  duration: const Duration(seconds: 3),
                )
              );
            }
          } else {
            // ── STOP SESSION ──────────────────────────────
            service.invoke('stopService');
            
            // Stop auto-refreshing stats
            ref.read(dashboardProvider.notifier).stopAutoRefresh();
            
            // Capture final step counts BEFORE resetting pedometer
            final livePedometerSteps = ref.read(pedometerProvider).value ?? 0;
            final prevApiSteps = (ref.read(dashboardProvider).todayActivity?['steps'] ?? 0) as num;
            final totalSteps = prevApiSteps.toInt() + livePedometerSteps;
            
            // Save for hero card display (so it doesn't drop to 0)
            // NEVER decrease — steps only go up within a day
            _lastCompletedSteps = math.max(_lastCompletedSteps, totalSteps);
            SharedPreferences.getInstance().then((p) {
              final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
              p.setInt('completed_steps_today', _lastCompletedSteps);
              p.setString('completed_steps_date', today);
            });
            debugPrint('💾 Saved completed steps: $_lastCompletedSteps');
            
            // NOW freeze the step counter (after capturing the value)
            ref.read(pedometerProvider.notifier).stopSession();
            
            final sessionIdToStop = prefs.getString('active_session_id') ?? '';
            
            if (sessionIdToStop.isNotEmpty) {
              // Use session-specific steps only (NOT totalSteps which includes previous sessions)
              final bgAccumulatedSteps = prefs.getInt('session_accumulated_steps') ?? 0;
              // BG service tracks session steps most accurately; pedometer is fallback
              final finalSteps = math.max(bgAccumulatedSteps, livePedometerSteps);
              final finalCalories = (finalSteps * 0.045).round();
              final finalDistance = double.parse((finalSteps * 0.000762).toStringAsFixed(3));
              
              debugPrint('📊 Stop: live=$livePedometerSteps, api=${prevApiSteps.toInt()}, bg=$bgAccumulatedSteps, final=$finalSteps, display=$_lastCompletedSteps');
              
              try {
                await repo.stopSession(
                  sessionId: sessionIdToStop,
                  finalSteps: finalSteps,
                  finalCalories: finalCalories,
                  finalDistance: finalDistance,
                );
              } catch (e) {
                debugPrint('⚠️ Stop session API failed (session may have been auto-closed): $e');
                // Don't throw — session might have been auto-closed by backend
              }
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
          // On ANY error during start/stop, reset UI so user can retry
          debugPrint('❌ START/STOP FAILED: $e');
          if (e is DioException) {
            debugPrint('❌ Status: ${e.response?.statusCode}');
            debugPrint('❌ Response: ${e.response?.data}');
          }
          
          // Reset tracking state so user isn't stuck
          if (mounted) {
            setState(() {
              _isTracking = !shouldStart; // revert the toggle
              if (!_isTracking) {
                _ac.stop(); _glowAc.stop();
              }
            });
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  shouldStart ? 'Failed to start session. Please try again.' : 'Failed to stop session. Please try again.',
                  style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.w600),
                ),
                backgroundColor: Colors.redAccent,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                margin: const EdgeInsets.all(16),
                duration: const Duration(seconds: 3),
              )
            );
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
      onTap: () async {
        HapticFeedback.selectionClick();
        if (idx == 1) {
          // Reports tab — silent sync first, then switch tab
          await _silentSyncForTab();
          if (mounted) setState(() => _tab = idx);
        }
        else if (idx == 2) { _silentSyncAndNavigate(RouteNames.stats); }
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