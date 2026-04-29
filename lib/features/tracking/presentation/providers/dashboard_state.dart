class DashboardState {
  final Map<String, dynamic>? todayActivity;
  final Map<String, dynamic>? weeklyStats;
  final Map<String, dynamic>? monthlyStats;
  final List<dynamic>? history;
  final bool isLoading;
  final String? error;

  DashboardState({
    this.todayActivity,
    this.weeklyStats,
    this.monthlyStats,
    this.history,
    this.isLoading = false,
    this.error,
  });

  DashboardState copyWith({
    Map<String, dynamic>? todayActivity,
    Map<String, dynamic>? weeklyStats,
    Map<String, dynamic>? monthlyStats,
    List<dynamic>? history,
    bool? isLoading,
    String? error,
  }) {
    return DashboardState(
      todayActivity: todayActivity ?? this.todayActivity,
      weeklyStats: weeklyStats ?? this.weeklyStats,
      monthlyStats: monthlyStats ?? this.monthlyStats,
      history: history ?? this.history,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}
