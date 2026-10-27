class VisitorDetailModel {
  VisitorDetailModel({
    required this.createdAt,
    required this.name,
    required this.mobileNumber,
    required this.email,
    required this.visitorType,
    required this.project,
    required this.purpose,
    required this.status,
    required this.checkInTime,
    required this.checkOutTime,
    required this.id,
  });

  final String createdAt;
  static const String createdAtKey = "createdAt";

  final String name;
  static const String nameKey = "name";

  final num mobileNumber;
  static const String mobileNumberKey = "mobile_number";

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

  final String checkInTime;
  static const String checkInTimeKey = "check_in_time";

  final String checkOutTime;
  static const String checkOutTimeKey = "check_out_time";

  final String id;
  static const String idKey = "id";

  factory VisitorDetailModel.fromJson(Map<String, dynamic> json) {
    return VisitorDetailModel(
      createdAt: json["createdAt"]?.toString() ?? "",
      name: json["name"]?.toString() ?? "",
      mobileNumber: json["mobile_number"] is num
          ? json["mobile_number"] as num
          : num.tryParse(json["mobile_number"]?.toString() ?? "0") ?? 0,
      email: json["email"]?.toString() ?? "",
      visitorType: json["visitor_type"]?.toString() ?? "",
      project: json["project"]?.toString() ?? "",
      purpose: json["purpose"]?.toString() ?? "",
      status: json["status"]?.toString() ?? "",
      checkInTime: json["check_in_time"]?.toString() ?? "",
      checkOutTime: json["check_out_time"]?.toString() ?? "",
      id: json["id"]?.toString() ?? "",
    );
  }

  Map<String, dynamic> toJson() => {
    "createdAt": createdAt,
    "name": name,
    "mobile_number": mobileNumber,
    "email": email,
    "visitor_type": visitorType,
    "project": project,
    "purpose": purpose,
    "status": status,
    "check_in_time": checkInTime,
    "check_out_time": checkOutTime,
    "id": id,
  };

  @override
  String toString() {
    return "$createdAt, $name, $mobileNumber, $email, $visitorType, $project, $purpose, $status, $checkInTime, $checkOutTime, $id, ";
  }
}

/*
{
	"createdAt": "createdAt 1",
	"name": "name 1",
	"mobile_number": 1,
	"email": "email 1",
	"visitor_type": "visitor_type 1",
	"project": "project 1",
	"purpose": "purpose 1",
	"status": "status 1",
	"check_in_time": "check_in_time 1",
	"check_out_time": "check_out_time 1",
	"id": "1"
}*/
