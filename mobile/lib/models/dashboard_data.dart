class DashboardData {
  final String status; // 'DRAFT', 'SUBMITTED', etc.
  final double progress; // 0.0 to 1.0
  final String lastEdited;
  final List<DashboardAction> nextSteps;

  const DashboardData({
    required this.status,
    required this.progress,
    required this.lastEdited,
    required this.nextSteps,
  });
}

class DashboardAction {
  final String title;
  final String subtitle;
  final String iconCode; // 'upload_file', etc.

  const DashboardAction({
    required this.title,
    required this.subtitle,
    required this.iconCode,
  });
}
