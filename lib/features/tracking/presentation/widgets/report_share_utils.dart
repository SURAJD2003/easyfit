import 'dart:io';

import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';

// ══════════════════════════════════════════════════════════
//  REPORT SHARE UTILITIES
// ══════════════════════════════════════════════════════════

// ── PDF COLORS (DARK THEME) ──
final _bg       = PdfColor.fromHex('#0A0A0A');
final _card     = PdfColor.fromHex('#1A1A1A');
final _card2    = PdfColor.fromHex('#222222');
final _border   = PdfColor.fromHex('#2A2A2A');
final _accent   = PdfColor.fromHex('#FF6B2B');
final _accentLt = PdfColor.fromHex('#FF9A3C');
final _green    = PdfColor.fromHex('#30D158');
final _blue     = PdfColor.fromHex('#0A84FF');
final _purple   = PdfColor.fromHex('#BF5AF2');
final _white    = PdfColor.fromHex('#FFFFFF');
final _hi       = PdfColor.fromHex('#F5F5F5');
final _mid      = PdfColor.fromHex('#999999');
final _lo       = PdfColor.fromHex('#555555');

class ReportShareUtils {

  static Future<File> generatePdf({
    required String reportType,
    required String dateLabel,
    required Map<String, dynamic> data,
    required int segment,
  }) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageTheme: pw.PageTheme(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(0),
          buildBackground: (context) => pw.FullPage(
            ignoreMargins: true,
            child: pw.Container(color: _bg),
          ),
        ),
        header: (context) => _header(reportType, dateLabel),
        footer: (context) => _footer(),
        build: (context) {
          return [
            pw.Padding(
              padding: const pw.EdgeInsets.fromLTRB(28, 24, 28, 0),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  if (segment == 0) ..._dailyPdf(data),
                  if (segment == 1) ..._weeklyPdf(data),
                  if (segment == 2) ..._monthlyPdf(data),
                ],
              ),
            ),
            pw.SizedBox(height: 20),
          ];
        },
      ),
    );

    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/easyfit_${reportType.toLowerCase()}_report.pdf');
    await file.writeAsBytes(await pdf.save());
    return file;
  }

  // ════════════════════════════════
  //  HEADER
  // ════════════════════════════════
  static pw.Widget _header(String type, String date) {
    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.fromLTRB(28, 36, 28, 28),
      decoration: pw.BoxDecoration(
        gradient: pw.LinearGradient(colors: [_accent, _accentLt]),
        borderRadius: const pw.BorderRadius.only(
          bottomLeft: pw.Radius.circular(28),
          bottomRight: pw.Radius.circular(28),
        ),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text('EasyFit',
                style: pw.TextStyle(fontSize: 30, fontWeight: pw.FontWeight.bold, color: _white)),
              pw.Container(
                padding: const pw.EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: pw.BoxDecoration(
                  color: PdfColors.white.shade(0.2),
                  borderRadius: pw.BorderRadius.circular(20),
                ),
                child: pw.Text('$type Report',
                  style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold, color: _white)),
              ),
            ],
          ),
          pw.SizedBox(height: 12),
          pw.Container(width: double.infinity, height: 0.5, color: PdfColors.white.shade(0.3)),
          pw.SizedBox(height: 10),
          pw.Text(date,
            style: pw.TextStyle(fontSize: 14, color: PdfColors.white.shade(0.15))),
          pw.SizedBox(height: 3),
          pw.Text('Generated ${DateFormat('d MMM yyyy, h:mm a').format(DateTime.now())}',
            style: pw.TextStyle(fontSize: 9, color: PdfColors.white.shade(0.35))),
        ],
      ),
    );
  }

  // ════════════════════════════════
  //  FOOTER
  // ════════════════════════════════
  static pw.Widget _footer() {
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(horizontal: 28, vertical: 16),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Row(children: [
            pw.Container(width: 6, height: 6, decoration: pw.BoxDecoration(color: _accent, shape: pw.BoxShape.circle)),
            pw.SizedBox(width: 6),
            pw.Text('EasyFit Clinic', style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold, color: _mid)),
          ]),
          pw.Text('Powered by EasyFit', style: pw.TextStyle(fontSize: 8, color: _lo)),
        ],
      ),
    );
  }

  // ════════════════════════════════
  //  SECTION TITLE
  // ════════════════════════════════
  static pw.Widget _title(String t) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 12),
      child: pw.Row(children: [
        pw.Container(width: 3, height: 16, decoration: pw.BoxDecoration(color: _accent, borderRadius: pw.BorderRadius.circular(2))),
        pw.SizedBox(width: 8),
        pw.Text(t, style: pw.TextStyle(fontSize: 15, fontWeight: pw.FontWeight.bold, color: _hi)),
      ]),
    );
  }

  // ════════════════════════════════
  //  STAT CARD
  // ════════════════════════════════
  static pw.Widget _stat(String label, String value, PdfColor color, {String? unit}) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        color: _card,
        borderRadius: pw.BorderRadius.circular(14),
        border: pw.Border.all(color: _border, width: 0.5),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Row(children: [
            pw.Container(width: 8, height: 8, decoration: pw.BoxDecoration(color: color, shape: pw.BoxShape.circle)),
            pw.SizedBox(width: 6),
            pw.Text(label, style: pw.TextStyle(fontSize: 10, color: _mid)),
          ]),
          pw.SizedBox(height: 8),
          pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.end,
            children: [
              pw.Text(value, style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold, color: color)),
              if (unit != null) ...[
                pw.SizedBox(width: 4),
                pw.Padding(
                  padding: const pw.EdgeInsets.only(bottom: 3),
                  child: pw.Text(unit, style: pw.TextStyle(fontSize: 10, color: _mid)),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  // ════════════════════════════════
  //  PROGRESS BAR (manual)
  // ════════════════════════════════
  static pw.Widget _progressBar(double pct, {double width = 50, double height = 5}) {
    return pw.Stack(children: [
      pw.Container(
        width: width, height: height,
        decoration: pw.BoxDecoration(color: _border, borderRadius: pw.BorderRadius.circular(3)),
      ),
      pw.Container(
        width: width * pct.clamp(0.0, 1.0), height: height,
        decoration: pw.BoxDecoration(color: _accent, borderRadius: pw.BorderRadius.circular(3)),
      ),
    ]);
  }

  // ══════════════════════════════════════════════
  //  DAILY
  // ══════════════════════════════════════════════
  static List<pw.Widget> _dailyPdf(Map<String, dynamic> d) {
    final steps = d['steps'] ?? 0;
    final calories = d['calories'] ?? 0;
    final distance = d['distance'] ?? 0;
    final activeMin = d['activeMinutes'] ?? 0;
    final goal = d['goalAchieved'] ?? false;

    return [
      // Goal banner
      pw.Container(
        width: double.infinity,
        padding: const pw.EdgeInsets.all(16),
        decoration: pw.BoxDecoration(
          color: _card,
          borderRadius: pw.BorderRadius.circular(14),
          border: pw.Border.all(color: goal ? _green : _accent, width: 1),
        ),
        child: pw.Row(children: [
          pw.Container(
            width: 32, height: 32,
            decoration: pw.BoxDecoration(color: goal ? _green : _accent, borderRadius: pw.BorderRadius.circular(8)),
            child: pw.Center(child: pw.Text(goal ? 'OK' : 'GO', style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold, color: _white))),
          ),
          pw.SizedBox(width: 12),
          pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
            pw.Text(goal ? 'Daily Goal Achieved!' : 'Keep Going!',
              style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold, color: goal ? _green : _accent)),
            pw.SizedBox(height: 2),
            pw.Text(goal ? 'You crushed it today!' : 'Stay active, keep moving',
              style: pw.TextStyle(fontSize: 9, color: _mid)),
          ]),
        ]),
      ),
      pw.SizedBox(height: 20),

      _title('Activity Summary'),
      pw.Row(children: [
        pw.Expanded(child: _stat('Steps', _fmt(steps), _green)),
        pw.SizedBox(width: 12),
        pw.Expanded(child: _stat('Calories', '$calories', _accent, unit: 'kcal')),
      ]),
      pw.SizedBox(height: 12),
      pw.Row(children: [
        pw.Expanded(child: _stat('Distance', '$distance', _purple, unit: 'km')),
        pw.SizedBox(width: 12),
        pw.Expanded(child: _stat('Active Time', '$activeMin', _blue, unit: 'min')),
      ]),
    ];
  }

  // ══════════════════════════════════════════════
  //  WEEKLY
  // ══════════════════════════════════════════════
  static List<pw.Widget> _weeklyPdf(Map<String, dynamic> d) {
    final totalSteps = d['totalSteps'] ?? 0;
    final totalCals = d['totalCalories'] ?? 0;
    final daily = (d['dailyData'] as List<dynamic>?) ?? [];
    final dayCount = daily.isNotEmpty ? daily.length : 7;
    final avgSteps = dayCount > 0 ? (totalSteps / dayCount).round() : 0;
    final avgCals = dayCount > 0 ? (totalCals / dayCount).round() : 0;
    final activeDays = daily.where((d) => ((d as Map)['steps'] ?? 0) > 0).length;

    return [
      _title('Last 7 Days Summary'),
      pw.Row(children: [
        pw.Expanded(child: _stat('Avg Steps', _fmt(avgSteps), _green)),
        pw.SizedBox(width: 10),
        pw.Expanded(child: _stat('Avg Calories', '$avgCals', _accent, unit: 'kcal')),
        pw.SizedBox(width: 10),
        pw.Expanded(child: _stat('Avg Tablets', '$activeDays / $dayCount', _blue)),
      ]),
      pw.SizedBox(height: 20),

      if (daily.isNotEmpty) ...[
        _title('Daily Breakdown'),
        // Header row
        pw.Container(
          padding: const pw.EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: pw.BoxDecoration(color: _card2, borderRadius: const pw.BorderRadius.vertical(top: pw.Radius.circular(10))),
          child: pw.Row(children: [
            pw.Expanded(flex: 3, child: pw.Text('Day', style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold, color: _mid))),
            pw.Expanded(flex: 2, child: pw.Text('Steps', style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold, color: _mid), textAlign: pw.TextAlign.right)),
            pw.Expanded(flex: 2, child: pw.Text('Cal', style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold, color: _mid), textAlign: pw.TextAlign.right)),
            pw.SizedBox(width: 60),
          ]),
        ),
        // Data rows
        ...daily.asMap().entries.map((e) {
          final i = e.key;
          final dd = e.value as Map<String, dynamic>;
          final date = dd['date'] ?? '';
          final steps = dd['steps'] ?? 0;
          final cals = dd['calories'] ?? 0;
          String lbl = date;
          try { lbl = DateFormat('EEE, d MMM').format(DateTime.parse(date)); } catch (_) {}
          final mx = daily.fold<int>(0, (p, x) { final s = (x as Map)['steps'] ?? 0; return (s as int) > p ? s : p; });
          final pct = mx > 0 ? (steps as int) / mx : 0.0;
          final last = i == daily.length - 1;

          return pw.Container(
            padding: const pw.EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: pw.BoxDecoration(
              color: i % 2 == 0 ? _card : _bg,
              borderRadius: last ? const pw.BorderRadius.vertical(bottom: pw.Radius.circular(10)) : null,
            ),
            child: pw.Row(children: [
              pw.Expanded(flex: 3, child: pw.Text(lbl, style: pw.TextStyle(fontSize: 10, color: _hi))),
              pw.Expanded(flex: 2, child: pw.Text(_fmt(steps), style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold, color: _hi), textAlign: pw.TextAlign.right)),
              pw.Expanded(flex: 2, child: pw.Text('$cals', style: pw.TextStyle(fontSize: 10, color: _mid), textAlign: pw.TextAlign.right)),
              pw.SizedBox(width: 8),
              _progressBar(pct.toDouble()),
            ]),
          );
        }),
      ],
    ];
  }

  // ══════════════════════════════════════════════
  //  MONTHLY
  // ══════════════════════════════════════════════
  static List<pw.Widget> _monthlyPdf(Map<String, dynamic> d) {
    final totalSteps = d['totalSteps'] ?? 0;
    final totalCals = d['totalCalories'] ?? 0;
    final avgDaily = d['avgDailySteps'] ?? 0;
    final weeks = (d['weeklyData'] as List<dynamic>?) ?? [];

    return [
      _title('Monthly Summary'),
      pw.Row(children: [
        pw.Expanded(child: _stat('Total Steps', _fmt(totalSteps), _green)),
        pw.SizedBox(width: 10),
        pw.Expanded(child: _stat('Calories', '$totalCals', _accent, unit: 'kcal')),
        pw.SizedBox(width: 10),
        pw.Expanded(child: _stat('Avg/Day', _fmt(avgDaily), _blue)),
      ]),
      pw.SizedBox(height: 20),

      if (weeks.isNotEmpty) ...[
        _title('Weekly Breakdown'),
        ...weeks.asMap().entries.map((e) {
          final i = e.key;
          final w = e.value as Map<String, dynamic>;
          final ws = w['weekStart'] ?? '';
          final we = w['weekEnd'] ?? '';
          final st = w['steps'] ?? 0;
          final ca = w['calories'] ?? 0;
          String lbl = 'Week ${i + 1}';
          try { lbl = '${DateFormat('d MMM').format(DateTime.parse(ws))} - ${DateFormat('d MMM').format(DateTime.parse(we))}'; } catch (_) {}
          final mx = weeks.fold<int>(0, (p, x) { final s = (x as Map)['steps'] ?? 0; return (s as int) > p ? s : p; });
          final pct = mx > 0 ? (st as int) / mx : 0.0;

          return pw.Container(
            margin: const pw.EdgeInsets.only(bottom: 8),
            padding: const pw.EdgeInsets.all(14),
            decoration: pw.BoxDecoration(color: _card, borderRadius: pw.BorderRadius.circular(12), border: pw.Border.all(color: _border, width: 0.5)),
            child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
              pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, children: [
                pw.Text(lbl, style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold, color: _hi)),
                pw.Text('${_fmt(st)} steps', style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold, color: _accent)),
              ]),
              pw.SizedBox(height: 8),
              pw.ClipRRect(
                horizontalRadius: 3, verticalRadius: 3,
                child: pw.LinearProgressIndicator(value: pct.toDouble().clamp(0.0, 1.0), backgroundColor: _border, valueColor: _accent),
              ),
              pw.SizedBox(height: 4),
              pw.Text('$ca kcal burned', style: pw.TextStyle(fontSize: 9, color: _mid)),
            ]),
          );
        }),
      ],
    ];
  }

  static String _fmt(dynamic n) {
    if (n is int) return NumberFormat('#,###').format(n);
    if (n is double) return NumberFormat('#,###').format(n.toInt());
    return n.toString();
  }

  // ── SHARE PDF ──
  static Future<void> sharePdf({
    required String reportType,
    required String dateLabel,
    required Map<String, dynamic> data,
    required int segment,
  }) async {
    final file = await generatePdf(reportType: reportType, dateLabel: dateLabel, data: data, segment: segment);
    await SharePlus.instance.share(
      ShareParams(
        files: [XFile(file.path, mimeType: 'application/pdf')],
        text: 'My EasyFit $reportType Report - $dateLabel',
      ),
    );
  }

  // ── CAPTURE SCREENSHOT & SHARE ──
  static Future<void> captureAndShare(GlobalKey repaintKey) async {
    try {
      final boundary = repaintKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) return;
      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) return;
      final bytes = byteData.buffer.asUint8List();

      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/easyfit_report_${DateTime.now().millisecondsSinceEpoch}.png');
      await file.writeAsBytes(bytes);

      await SharePlus.instance.share(
        ShareParams(
          files: [XFile(file.path, mimeType: 'image/png')],
          text: 'Check out my fitness report from EasyFit!',
        ),
      );
    } catch (e) {
      debugPrint('Screenshot share error: $e');
    }
  }
}

// ══════════════════════════════════════════════════════════
//  SHAREABLE REPORT CARD (for screenshot capture)
// ══════════════════════════════════════════════════════════

class ShareableReportCard extends StatelessWidget {
  final String reportType;
  final String dateLabel;
  final Map<String, dynamic> data;
  final int segment;
  final String userName;

  const ShareableReportCard({
    super.key,
    required this.reportType,
    required this.dateLabel,
    required this.data,
    required this.segment,
    this.userName = 'User',
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 380,
      decoration: BoxDecoration(
        color: const Color(0xFF0A0A0A),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFF252525)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
            decoration: const BoxDecoration(
              gradient: LinearGradient(colors: [Color(0xFFFF6B2B), Color(0xFFFF9A3C)]),
              borderRadius: BorderRadius.vertical(top: Radius.circular(23)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('EasyFit', style: GoogleFonts.inter(fontSize: 22, fontWeight: FontWeight.w900, color: Colors.white)),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(20)),
                      child: Text('$reportType Report', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.white)),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(dateLabel, style: GoogleFonts.inter(fontSize: 13, color: Colors.white70)),
              ],
            ),
          ),
          // Content
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: _content(),
          ),
          // Footer
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(width: 24, height: 2, decoration: BoxDecoration(color: const Color(0xFFFF6B2B), borderRadius: BorderRadius.circular(1))),
                const SizedBox(width: 8),
                Text('Powered by EasyFit Clinic', style: GoogleFonts.inter(fontSize: 10, color: const Color(0xFF5A5A5A))),
                const SizedBox(width: 8),
                Container(width: 24, height: 2, decoration: BoxDecoration(color: const Color(0xFFFF6B2B), borderRadius: BorderRadius.circular(1))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _content() {
    if (segment == 0) return _daily();
    if (segment == 1) return _weekly();
    return _monthly();
  }

  Widget _daily() {
    final steps = data['steps'] ?? 0;
    final cal = data['calories'] ?? 0;
    final dist = data['distance'] ?? 0;
    final mins = data['activeMinutes'] ?? 0;
    final goal = data['goalAchieved'] ?? false;
    return Column(children: [
      Container(
        width: double.infinity, padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: goal ? const Color(0xFF30D158).withAlpha(25) : const Color(0xFFFF6B2B).withAlpha(20),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: goal ? const Color(0xFF30D158).withAlpha(75) : const Color(0xFFFF6B2B).withAlpha(50)),
        ),
        child: Row(children: [
          Icon(goal ? Icons.emoji_events_rounded : Icons.flag_rounded, color: goal ? const Color(0xFF30D158) : const Color(0xFFFF6B2B), size: 22),
          const SizedBox(width: 10),
          Text(goal ? 'Goal Achieved!' : 'Keep Going!', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700, color: goal ? const Color(0xFF30D158) : const Color(0xFFFF6B2B))),
        ]),
      ),
      const SizedBox(height: 12),
      Row(children: [
        Expanded(child: _miniCard(Icons.directions_walk_rounded, '$steps', 'Steps', const Color(0xFF30D158))),
        const SizedBox(width: 8),
        Expanded(child: _miniCard(Icons.local_fire_department_rounded, '$cal', 'Calories', const Color(0xFFFF6B2B))),
      ]),
      const SizedBox(height: 8),
      Row(children: [
        Expanded(child: _miniCard(Icons.straighten_rounded, '$dist km', 'Distance', const Color(0xFFBF5AF2))),
        const SizedBox(width: 8),
        Expanded(child: _miniCard(Icons.timer_outlined, '${mins}m', 'Active', const Color(0xFF0A84FF))),
      ]),
    ]);
  }

  Widget _weekly() {
    final ts = data['totalSteps'] ?? 0;
    final tc = data['totalCalories'] ?? 0;
    final daily = (data['dailyData'] as List<dynamic>?) ?? [];
    final dayCount = daily.isNotEmpty ? daily.length : 7;
    final avgSteps = dayCount > 0 ? (ts / dayCount).round() : 0;
    final avgCals = dayCount > 0 ? (tc / dayCount).round() : 0;
    final activeDays = daily.where((d) => ((d as Map)['steps'] ?? 0) > 0).length;
    return Column(children: [
      Row(children: [
        Expanded(child: _miniCard(Icons.directions_walk_rounded, _n(avgSteps), 'Avg Steps', const Color(0xFF30D158))),
        const SizedBox(width: 8),
        Expanded(child: _miniCard(Icons.local_fire_department_rounded, '$avgCals', 'Avg Calories', const Color(0xFFFF6B2B))),
        const SizedBox(width: 8),
        Expanded(child: _miniCard(Icons.medication_rounded, '$activeDays / $dayCount', 'Avg Tablets', const Color(0xFF0A84FF))),
      ]),
      if (daily.isNotEmpty) ...[
        const SizedBox(height: 16),
        Align(alignment: Alignment.centerLeft, child: Text('Daily Breakdown', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700, color: const Color(0xFFF5F5F5)))),
        const SizedBox(height: 8),
        ...daily.map((day) {
          final dd = day as Map<String, dynamic>;
          final dateStr = dd['date'] ?? '';
          final steps = dd['steps'] ?? 0;
          final cals = dd['calories'] ?? 0;
          String label = dateStr;
          try { label = DateFormat('EEE, d MMM').format(DateTime.parse(dateStr)); } catch (_) {}
          final maxS = daily.fold<int>(0, (p, d2) { final s = (d2 as Map)['steps'] ?? 0; return (s as int) > p ? s : p; });
          final pct = maxS > 0 ? (steps / maxS).clamp(0.0, 1.0) : 0.0;
          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: const Color(0xFF141414), borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFF252525))),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Text(label, style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: const Color(0xFFF5F5F5))),
                Text('${_n(steps)} steps', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700, color: const Color(0xFF30D158))),
              ]),
              const SizedBox(height: 6),
              ClipRRect(borderRadius: BorderRadius.circular(3), child: LinearProgressIndicator(value: pct.toDouble(), backgroundColor: const Color(0xFF252525), valueColor: const AlwaysStoppedAnimation(Color(0xFF30D158)))),
              const SizedBox(height: 4),
              Text('$cals kcal burned', style: GoogleFonts.inter(fontSize: 10, color: const Color(0xFF8A8A8A))),
            ]),
          );
        }),
      ]
    ]);
  }

  Widget _monthly() {
    final ts = data['totalSteps'] ?? 0;
    final tc = data['totalCalories'] ?? 0;
    final avg = data['avgDailySteps'] ?? 0;
    final weeks = (data['weeklyData'] as List<dynamic>?) ?? [];
    return Column(children: [
      Row(children: [
        Expanded(child: _miniCard(Icons.directions_walk_rounded, _n(ts), 'Steps', const Color(0xFF30D158))),
        const SizedBox(width: 8),
        Expanded(child: _miniCard(Icons.local_fire_department_rounded, '$tc', 'Cal', const Color(0xFFFF6B2B))),
        const SizedBox(width: 8),
        Expanded(child: _miniCard(Icons.speed_rounded, _n(avg), 'Avg/Day', const Color(0xFF0A84FF))),
      ]),
      if (weeks.isNotEmpty) ...[
        const SizedBox(height: 16),
        Align(alignment: Alignment.centerLeft, child: Text('Weekly Breakdown', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700, color: const Color(0xFFF5F5F5)))),
        const SizedBox(height: 8),
        ...weeks.asMap().entries.map((e) {
          final i = e.key;
          final w = e.value as Map<String, dynamic>;
          final ws = w['weekStart'] ?? '';
          final we = w['weekEnd'] ?? '';
          final st = w['steps'] ?? 0;
          final ca = w['calories'] ?? 0;
          String lbl = 'Week ${i + 1}';
          try { lbl = '${DateFormat('d MMM').format(DateTime.parse(ws))} - ${DateFormat('d MMM').format(DateTime.parse(we))}'; } catch (_) {}
          final mx = weeks.fold<int>(0, (p, x) { final s = (x as Map)['steps'] ?? 0; return (s as int) > p ? s : p; });
          final pct = mx > 0 ? (st / mx).clamp(0.0, 1.0) : 0.0;
          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: const Color(0xFF141414), borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFF252525))),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Text(lbl, style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: const Color(0xFFF5F5F5))),
                Text('${_n(st)} steps', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700, color: const Color(0xFFFF6B2B))),
              ]),
              const SizedBox(height: 6),
              ClipRRect(borderRadius: BorderRadius.circular(3), child: LinearProgressIndicator(value: pct.toDouble(), backgroundColor: const Color(0xFF252525), valueColor: const AlwaysStoppedAnimation(Color(0xFFFF6B2B)))),
              const SizedBox(height: 4),
              Text('$ca kcal burned', style: GoogleFonts.inter(fontSize: 10, color: const Color(0xFF8A8A8A))),
            ]),
          );
        }),
      ]
    ]);
  }

  Widget _miniCard(IconData icon, String value, String label, Color c) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: const Color(0xFF141414), borderRadius: BorderRadius.circular(14), border: Border.all(color: const Color(0xFF252525))),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Icon(icon, color: c, size: 20),
        const SizedBox(height: 6),
        Text(value, style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w800, color: c)),
        const SizedBox(height: 2),
        Text(label, style: GoogleFonts.inter(fontSize: 10, color: const Color(0xFF8A8A8A))),
      ]),
    );
  }

  String _n(dynamic n) {
    if (n is int) return NumberFormat('#,###').format(n);
    if (n is double) return NumberFormat('#,###').format(n.toInt());
    return n.toString();
  }
}
