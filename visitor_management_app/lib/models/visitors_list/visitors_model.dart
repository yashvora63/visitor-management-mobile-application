class VisitorListModel {
  VisitorListModel({
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

  factory VisitorListModel.fromJson(Map<String, dynamic> json) {
    return VisitorListModel(
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

  static List<VisitorListModel> fromJsonList(dynamic jsonList) {
    if (jsonList is List) {
      return jsonList
          .whereType<Map<String, dynamic>>()
          .map((e) => VisitorListModel.fromJson(e))
          .toList();
    }
    return [];
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
}

/*
[
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
	},
	{
		"createdAt": "createdAt 2",
		"name": "name 2",
		"mobile_number": 39,
		"email": "email 2",
		"visitor_type": "visitor_type 2",
		"project": "project 2",
		"purpose": "purpose 2",
		"status": "status 2",
		"check_in_time": "check_in_time 2",
		"check_out_time": "check_out_time 2",
		"id": "2"
	},
	{
		"createdAt": "createdAt 3",
		"name": "name 3",
		"mobile_number": 3,
		"email": "email 3",
		"visitor_type": "visitor_type 3",
		"project": "project 3",
		"purpose": "purpose 3",
		"status": "status 3",
		"check_in_time": "check_in_time 3",
		"check_out_time": "check_out_time 3",
		"id": "3"
	},
	{
		"createdAt": "createdAt 4",
		"name": "name 4",
		"mobile_number": 86,
		"email": "email 4",
		"visitor_type": "visitor_type 4",
		"project": "project 4",
		"purpose": "purpose 4",
		"status": "status 4",
		"check_in_time": "check_in_time 4",
		"check_out_time": "check_out_time 4",
		"id": "4"
	},
	{
		"createdAt": "createdAt 5",
		"name": "name 5",
		"mobile_number": 56,
		"email": "email 5",
		"visitor_type": "visitor_type 5",
		"project": "project 5",
		"purpose": "purpose 5",
		"status": "status 5",
		"check_in_time": "check_in_time 5",
		"check_out_time": "check_out_time 5",
		"id": "5"
	},
	{
		"createdAt": "createdAt 6",
		"name": "name 6",
		"mobile_number": 63,
		"email": "email 6",
		"visitor_type": "visitor_type 6",
		"project": "project 6",
		"purpose": "purpose 6",
		"status": "status 6",
		"check_in_time": "check_in_time 6",
		"check_out_time": "check_out_time 6",
		"id": "6"
	},
	{
		"createdAt": "createdAt 7",
		"name": "name 7",
		"mobile_number": 27,
		"email": "email 7",
		"visitor_type": "visitor_type 7",
		"project": "project 7",
		"purpose": "purpose 7",
		"status": "status 7",
		"check_in_time": "check_in_time 7",
		"check_out_time": "check_out_time 7",
		"id": "7"
	}
]*/
