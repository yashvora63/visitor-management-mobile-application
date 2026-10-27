class VisitorListModel {
  VisitorListModel({
    required this.id,
    required this.name,
    required this.mobile,
    required this.email,
    required this.visitorType,
    required this.project,
    required this.purpose,
    required this.status,
    required this.createdAt,
    required this.checkInTime,
    required this.checkOutTime,
  });

  final String id;
  static const String idKey = "id";

  final String name;
  static const String nameKey = "name";

  final String mobile;
  static const String mobileKey = "mobile";

  final String email;
  static const String emailKey = "email";

  final String visitorType;
  static const String visitorTypeKey = "visitor_type";

  final String project;
  static const String projectKey = "project";

  final String purpose;
  static const String purposeKey = "purpose";

  final String status;
  static const String statusKey = "status";

  final DateTime? createdAt;
  static const String createdAtKey = "created_at";

  final DateTime? checkInTime;
  static const String checkInTimeKey = "check_in_time";

  final DateTime? checkOutTime;
  static const String checkOutTimeKey = "check_out_time";

  factory VisitorListModel.fromJson(Map<String, dynamic> json) {
    return VisitorListModel(
      id: json["id"] ?? "",
      name: json["name"] ?? "",
      mobile: json["mobile"] ?? "",
      email: json["email"] ?? "",
      visitorType: json["visitor_type"] ?? "",
      project: json["project"] ?? "",
      purpose: json["purpose"] ?? "",
      status: json["status"] ?? "",
      createdAt: DateTime.tryParse(json["created_at"] ?? ""),
      checkInTime: DateTime.tryParse(json["check_in_time"] ?? ""),
      checkOutTime: DateTime.tryParse(json["check_out_time"] ?? ""),
    );
  }

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "mobile": mobile,
    "email": email,
    "visitor_type": visitorType,
    "project": project,
    "purpose": purpose,
    "status": status,
    "created_at": createdAt?.toIso8601String(),
    "check_in_time": checkInTime?.toIso8601String(),
    "check_out_time": checkOutTime?.toIso8601String(),
  };

  @override
  String toString() {
    return "$id, $name, $mobile, $email, $visitorType, $project, $purpose, $status, $createdAt, $checkInTime, $checkOutTime, ";
  }
}

/*
[
	{
		"id": "VIS001",
		"name": "Rahul Sharma",
		"mobile": "9876543210",
		"email": "rahul@example.com",
		"visitor_type": "Customer",
		"project": "Project A",
		"purpose": "Site Visit",
		"status": "Registered",
		"created_at": "2026-10-26T10:00:00+05:30",
		"check_in_time": null,
		"check_out_time": null
	},
	{
		"id": "VIS002",
		"name": "Yash Vora",
		"mobile": "0123456789",
		"email": "Yash@example.com",
		"visitor_type": "Customer",
		"project": "Project B",
		"purpose": "Site Visit",
		"status": "Registered",
		"created_at": "2026-10-15T10:00:00+05:30",
		"check_in_time": "2026-10-27T10:00:00+05:30",
		"check_out_time": null
	},
	{
		"id": "VIS003",
		"name": "Jash Shah",
		"mobile": "0127891235",
		"email": "Jash@example.com",
		"visitor_type": "Customer",
		"project": "Project C",
		"purpose": "Stay",
		"status": "Registered",
		"created_at": "2026-10-10T10:00:00+05:30",
		"check_in_time": "2026-10-27T10:00:00+05:30",
		"check_out_time": "2026-10-28T10:00:00+05:30"
	},
	{
		"id": "VIS004",
		"name": "Raj Metha",
		"mobile": "0123456789",
		"email": "Raj@example.com",
		"visitor_type": "Customer",
		"project": "Project D",
		"purpose": "Business",
		"status": "Registered",
		"created_at": "2026-10-01T10:00:00+05:30",
		"check_in_time": "2026-10-01T10:00:00+06:30",
		"check_out_time": null
	}
]*/
