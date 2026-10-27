import 'package:flutter_test/flutter_test.dart';
import 'package:visitor_management_app/models/visitors_list/visitors_model.dart';

void main() {
  group('VisitorListModel Tests', () {
    test('Parses single JSON object into VisitorListModel correctly', () {
      final json = {
        "id": "VIS001",
        "name": "Rahul Sharma",
        "mobile": "9876543210",
        "email": "rahul@example.com",
        "visitor_type": "Customer",
        "project": "Project A",
        "purpose": "Site Visit",
        "status": "Registered",
        "created_at": "2026-10-26T10:00:00+05:30",
        "check_in_time": "2026-10-26T10:30:00+05:30",
        "check_out_time": "2026-10-26T11:30:00+05:30",
      };

      final visitor = VisitorListModel.fromJson(json);

      expect(visitor.id, 'VIS001');
      expect(visitor.name, 'Rahul Sharma');
      expect(visitor.mobile, '9876543210');
      expect(visitor.email, 'rahul@example.com');
      expect(visitor.visitorType, 'Customer');
      expect(visitor.project, 'Project A');
      expect(visitor.purpose, 'Site Visit');
      expect(visitor.status, 'Registered');
      expect(visitor.createdAt, DateTime.parse("2026-10-26T10:00:00+05:30"));
      expect(visitor.checkInTime, DateTime.parse("2026-10-26T10:30:00+05:30"));
      expect(visitor.checkOutTime, DateTime.parse("2026-10-26T11:30:00+05:30"));
    });

    test('Parses API response list with snake_case and null timestamps', () {
      final jsonList = [
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
          "check_out_time": null,
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
          "check_out_time": null,
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
          "check_out_time": "2026-10-28T10:00:00+05:30",
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
          "check_out_time": null,
        },
      ];

      final visitors = jsonList
          .map((e) => VisitorListModel.fromJson(e as Map<String, dynamic>))
          .toList();

      expect(visitors.length, 4);

      // VIS001
      expect(visitors[0].id, 'VIS001');
      expect(visitors[0].name, 'Rahul Sharma');
      expect(visitors[0].mobile, '9876543210');
      expect(
        visitors[0].createdAt,
        DateTime.parse("2026-10-26T10:00:00+05:30"),
      );
      expect(visitors[0].checkInTime, isNull);
      expect(visitors[0].checkOutTime, isNull);

      // VIS002
      expect(visitors[1].id, 'VIS002');
      expect(visitors[1].name, 'Yash Vora');
      expect(visitors[1].mobile, '0123456789');
      expect(
        visitors[1].createdAt,
        DateTime.parse("2026-10-15T10:00:00+05:30"),
      );
      expect(
        visitors[1].checkInTime,
        DateTime.parse("2026-10-27T10:00:00+05:30"),
      );
      expect(visitors[1].checkOutTime, isNull);

      // VIS003
      expect(visitors[2].id, 'VIS003');
      expect(visitors[2].name, 'Jash Shah');
      expect(visitors[2].mobile, '0127891235');
      expect(
        visitors[2].createdAt,
        DateTime.parse("2026-10-10T10:00:00+05:30"),
      );
      expect(
        visitors[2].checkInTime,
        DateTime.parse("2026-10-27T10:00:00+05:30"),
      );
      expect(
        visitors[2].checkOutTime,
        DateTime.parse("2026-10-28T10:00:00+05:30"),
      );

      // VIS004
      expect(visitors[3].id, 'VIS004');
      expect(visitors[3].name, 'Raj Metha');
      expect(visitors[3].mobile, '0123456789');
      expect(
        visitors[3].createdAt,
        DateTime.parse("2026-10-01T10:00:00+05:30"),
      );
      expect(
        visitors[3].checkInTime,
        DateTime.parse("2026-10-01T10:00:00+06:30"),
      );
      expect(visitors[3].checkOutTime, isNull);
    });

    test('Handles missing, null, or invalid fields with safe defaults', () {
      final visitor = VisitorListModel.fromJson({});

      expect(visitor.id, '');
      expect(visitor.name, '');
      expect(visitor.mobile, '');
      expect(visitor.email, '');
      expect(visitor.visitorType, '');
      expect(visitor.project, '');
      expect(visitor.purpose, '');
      expect(visitor.status, '');
      expect(visitor.createdAt, isNull);
      expect(visitor.checkInTime, isNull);
      expect(visitor.checkOutTime, isNull);
    });

    test('Serializes VisitorListModel to JSON map correctly (toJson)', () {
      final visitor = VisitorListModel(
        id: 'VIS001',
        name: 'Rahul Sharma',
        mobile: '9876543210',
        email: 'rahul@example.com',
        visitorType: 'Customer',
        project: 'Project A',
        purpose: 'Site Visit',
        status: 'Registered',
        createdAt: DateTime.parse("2026-10-26T10:00:00.000Z"),
        checkInTime: DateTime.parse("2026-10-26T10:30:00.000Z"),
        checkOutTime: null,
      );

      final json = visitor.toJson();

      expect(json['id'], 'VIS001');
      expect(json['name'], 'Rahul Sharma');
      expect(json['mobile'], '9876543210');
      expect(json['email'], 'rahul@example.com');
      expect(json['visitor_type'], 'Customer');
      expect(json['project'], 'Project A');
      expect(json['purpose'], 'Site Visit');
      expect(json['status'], 'Registered');
      expect(json['created_at'], '2026-10-26T10:00:00.000Z');
      expect(json['check_in_time'], '2026-10-26T10:30:00.000Z');
      expect(json['check_out_time'], isNull);
    });

    test('Verifies static constant key strings', () {
      expect(VisitorListModel.idKey, 'id');
      expect(VisitorListModel.nameKey, 'name');
      expect(VisitorListModel.mobileKey, 'mobile');
      expect(VisitorListModel.emailKey, 'email');
      expect(VisitorListModel.visitorTypeKey, 'visitor_type');
      expect(VisitorListModel.projectKey, 'project');
      expect(VisitorListModel.purposeKey, 'purpose');
      expect(VisitorListModel.statusKey, 'status');
      expect(VisitorListModel.createdAtKey, 'created_at');
      expect(VisitorListModel.checkInTimeKey, 'check_in_time');
      expect(VisitorListModel.checkOutTimeKey, 'check_out_time');
    });

    test('Verifies toString() contains field details', () {
      final visitor = VisitorListModel(
        id: 'VIS001',
        name: 'Rahul Sharma',
        mobile: '9876543210',
        email: 'rahul@example.com',
        visitorType: 'Customer',
        project: 'Project A',
        purpose: 'Site Visit',
        status: 'Registered',
        createdAt: null,
        checkInTime: null,
        checkOutTime: null,
      );

      final stringValue = visitor.toString();
      expect(stringValue, contains('VIS001'));
      expect(stringValue, contains('Rahul Sharma'));
      expect(stringValue, contains('9876543210'));
      expect(stringValue, contains('rahul@example.com'));
      expect(stringValue, contains('Customer'));
      expect(stringValue, contains('Project A'));
      expect(stringValue, contains('Site Visit'));
      expect(stringValue, contains('Registered'));
    });
  });
}
