class Task {
  final int id;
  final String siteName;
  final String taskableType;
  final int taskableId;
  final String status;
  final String city;
  final String street;
  final DateTime startDate;
  final DateTime endDate;
  final double? proposedPrice;
  final String? workProgress;
  final Map<String, dynamic> contractor;

  Task({
    required this.id,
    required this.siteName,
    required this.taskableType,
    required this.taskableId,
    required this.status,
    required this.city,
    required this.street,
    required this.startDate,
    required this.endDate,
    this.proposedPrice,
    this.workProgress,
    required this.contractor,
  });

  String get contractorName => contractor['company_name'] ?? '';
  String? get contractorLogo => contractor['logo_url'];

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'],
      siteName: json['site_name'],
      taskableType: json['taskable_type'],
      taskableId: json['taskable_id'],
      status: json['status'],
      city: json['city'],
      street: json['street'],
      startDate: DateTime.parse(json['start_date']),
      endDate: DateTime.parse(json['end_date']),
      proposedPrice: json['proposed_price'] != null ? 
          double.parse(json['proposed_price'].toString()) : null,
      workProgress: json['work_progress'],
      contractor: json['contractor'] ?? {},
    );
  }
}
