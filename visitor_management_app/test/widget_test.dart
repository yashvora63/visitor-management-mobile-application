import 'package:flutter_test/flutter_test.dart';
import 'package:visitor_management_app/models/visitors_list/visitors_model.dart';

void main() {
  test('Visitor model initialization smoke test', () {
    final visitor = VisitorListModel(
      id: 'VIS001',
      name: 'Smoke Test Visitor',
      mobile: '9876543210',
      email: 'smoke@example.com',
      visitorType: 'Customer',
      project: 'Project A',
      purpose: 'Site Visit',
      status: 'Registered',
      createdAt: DateTime.now(),
      checkInTime: null,
      checkOutTime: null,
    );

    expect(visitor.id, 'VIS001');
    expect(visitor.checkInTime, isNull);
    expect(visitor.checkOutTime, isNull);
  });
}
