import sys

path = r'c:\Users\dubey\AndroidStudioProjects\The_Easyfit_clinic\lib\features\tracking\presentation\screens\dashboard_screen.dart'
with open(path, 'r', encoding='utf-8') as f:
    content = f.read()

idx = content.find("import 'dart:math' as math;")
if idx != -1:
    content = content[idx:]

content = content.replace(
    "import '../../../../core/router/route_names.dart';",
    "import '../../../../core/router/route_names.dart';\nimport 'package:flutter_riverpod/flutter_riverpod.dart';\nimport '../providers/dashboard_provider.dart';\nimport '../providers/dashboard_state.dart';"
)

content = content.replace(
    "class DashboardScreen extends StatefulWidget",
    "class DashboardScreen extends ConsumerStatefulWidget"
)
content = content.replace(
    "State<DashboardScreen> createState() => _DashboardScreenState();",
    "ConsumerState<DashboardScreen> createState() => _DashboardScreenState();"
)
content = content.replace(
    "class _DashboardScreenState extends State<DashboardScreen>",
    "class _DashboardScreenState extends ConsumerState<DashboardScreen>"
)

build_old = """  @override
  Widget build(BuildContext context) {
    return Scaffold("""
build_new = """  @override
  Widget build(BuildContext context) {
    final state = ref.watch(dashboardProvider);
    return Scaffold("""
content = content.replace(build_old, build_new)


content = content.replace(
    "default: return _homeTab();",
    "default: return _homeTab(state);"
)

home_tab_old = """  Widget _homeTab() {
    return SingleChildScrollView("""
home_tab_new = """  Widget _homeTab(DashboardState state) {
    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator(color: Color(0xFFFF6B2B)));
    }
    return SingleChildScrollView("""
content = content.replace(home_tab_old, home_tab_new)

content = content.replace("_heroCard(),", "_heroCard(state),")
hero_old = """  // ── HERO CARD ────────────────────────────────────────────
  Widget _heroCard() {"""
hero_new = """  // ── HERO CARD ────────────────────────────────────────────
  Widget _heroCard(DashboardState state) {
    final calories = state.todayActivity?['calories'] ?? 432;
    final steps = state.todayActivity?['steps'] ?? 6240;
    final goal = state.todayActivity?['goal'] ?? 7000;
    final progress = (steps / goal).clamp(0.0, 1.0);"""
content = content.replace(hero_old, hero_new)


content = content.replace("'432'", "calories.toString()")
content = content.replace("Text('6,240'", "Text(steps.toString()")
content = content.replace("'Goal: 7,000'", "'Goal: ${goal}'")
content = content.replace("_HeroArcPainter(progress: _ring.value * 0.89)", "_HeroArcPainter(progress: _ring.value * progress)")

content = content.replace("_weekChart(),", "_weekChart(state),")

week_old = """  // ── WEEKLY CHART ─────────────────────────────────────────
  Widget _weekChart() {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    const values = [320, 180, 540, 120, 410, 280, 0];"""
week_new = """  // ── WEEKLY CHART ─────────────────────────────────────────
  Widget _weekChart(DashboardState state) {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final apiValues = state.weeklyStats?['values'] as List<dynamic>?;
    final List<int> values = apiValues != null 
        ? apiValues.map((e) => (e as num).toInt()).toList()
        : [320, 180, 540, 120, 410, 280, 0];"""
content = content.replace(week_old, week_new)

with open(path, 'w', encoding='utf-8') as f:
    f.write(content)
print("done")
