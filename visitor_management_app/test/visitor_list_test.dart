import 'package:flutter_test/flutter_test.dart';
import 'package:visitor_management_app/models/visitors_list/visitors_model.dart';

void main() {
  group('VisitorListModel Tests', () {
    test('Parses JSON list response correctly', () {
      final jsonList = [
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
        }
      ];

      final visitors = VisitorListModel.fromJsonList(jsonList);
      expect(visitors.length, 2);
      expect(visitors.first.id, '1');
      expect(visitors.first.name, 'name 1');
      expect(visitors.first.mobileNumber, 1);
      expect(visitors[1].id, '2');
      expect(visitors[1].name, 'name 2');
      expect(visitors[1].mobileNumber, 39);
    });
  });
}
