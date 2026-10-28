import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:visitor_management_app/data/repository.dart';
import 'package:visitor_management_app/models/visitors_list/visitors_model.dart';
import 'package:visitor_management_app/stores/visitor_list/visitor_list_store.dart';

class MockRepository extends Mock implements Repository {}

String? extractVisitorId(String raw) {
  final trimmed = raw.trim();
  if (trimmed.isEmpty) return null;

  if (trimmed.toUpperCase().startsWith('SUMADHURA-PASS:')) {
    final payload = trimmed.substring('SUMADHURA-PASS:'.length);
    final parts = payload.split('|');
    if (parts.isNotEmpty && parts[0].trim().isNotEmpty) {
      return parts[0].trim();
    }
  }

  if (trimmed.startsWith('{') && trimmed.endsWith('}')) {
    try {
      final decoded = jsonDecode(trimmed);
      if (decoded is Map && decoded['id'] != null) {
        final idStr = decoded['id'].toString().trim();
        if (idStr.isNotEmpty) return idStr;
      }
    } catch (_) {}
  }

  if (trimmed.contains('/visitors/')) {
    final segs = trimmed.split('/visitors/');
    if (segs.length > 1) {
      final possibleId = segs[1].split('?').first.split('/').first.trim();
      if (possibleId.isNotEmpty) return possibleId;
    }
  }

  if (trimmed.contains(':')) {
    final parts = trimmed.split(':');
    final last = parts.last.split('|').first.trim();
    if (last.isNotEmpty && !last.contains(' ') && last.length <= 40) {
      return last;
    }
  }

  if (trimmed.contains('|')) {
    final first = trimmed.split('|').first.trim();
    if (first.isNotEmpty && !first.contains(' ') && first.length <= 40) {
      return first;
    }
  }

  if (!trimmed.contains(' ') && !trimmed.contains('\n') && trimmed.length <= 40) {
    return trimmed;
  }

  return null;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late MockRepository mockRepository;
  late VisitorListStore visitorListStore;

  setUp(() {
    mockRepository = MockRepository();
    visitorListStore = VisitorListStore(mockRepository);
  });

  group('QR Code Scanner Parser & Validation Tests', () {
    test('Extracts plain visitor ID', () {
      expect(extractVisitorId('VIS001'), 'VIS001');
      expect(extractVisitorId('1'), '1');
      expect(extractVisitorId('  42  '), '42');
    });

    test('Extracts ID from Sumadhura gate pass format', () {
      final pass = 'SUMADHURA-PASS:VIS002|Rahul Sharma|Project A|Registered';
      expect(extractVisitorId(pass), 'VIS002');
    });

    test('Extracts ID from JSON QR payload', () {
      final jsonCode = jsonEncode({'id': 'VIS003', 'name': 'Jash Shah'});
      expect(extractVisitorId(jsonCode), 'VIS003');
    });

    test('Extracts ID from REST API URL format', () {
      final url = 'https://mockapi.io/api/v1/visitors/VIS004';
      expect(extractVisitorId(url), 'VIS004');
    });

    test('Rejects empty or invalid QR code contents', () {
      expect(extractVisitorId(''), isNull);
      expect(extractVisitorId('   '), isNull);
      expect(extractVisitorId('Random sentence with many words that is not an id'), isNull);
    });
  });

  group('Check-In / Check-Out Business Logic & State Sync Tests', () {
    final registeredVisitor = VisitorListModel(
      id: 'VIS101',
      name: 'Yash Vora',
      mobile: '9876543210',
      email: 'yash@example.com',
      visitorType: 'Customer',
      project: 'Project A',
      purpose: 'Site Visit',
      status: 'Registered',
      createdAt: DateTime.now(),
      checkInTime: null,
      checkOutTime: null,
    );

    final checkedInVisitor = VisitorListModel(
      id: 'VIS101',
      name: 'Yash Vora',
      mobile: '9876543210',
      email: 'yash@example.com',
      visitorType: 'Customer',
      project: 'Project A',
      purpose: 'Site Visit',
      status: 'Checked In',
      createdAt: DateTime.now(),
      checkInTime: DateTime.now(),
      checkOutTime: null,
    );

    final checkedOutVisitor = VisitorListModel(
      id: 'VIS101',
      name: 'Yash Vora',
      mobile: '9876543210',
      email: 'yash@example.com',
      visitorType: 'Customer',
      project: 'Project A',
      purpose: 'Site Visit',
      status: 'Checked Out',
      createdAt: DateTime.now(),
      checkInTime: DateTime.now().subtract(const Duration(hours: 1)),
      checkOutTime: DateTime.now(),
    );

    test('Allows Check-In only when status is Registered and updates API', () async {
      visitorListStore.setVisitors([registeredVisitor]);

      when(() => mockRepository.patchVisitor(any(), any()))
          .thenAnswer((_) async => checkedInVisitor);

      final result = await visitorListStore.checkInVisitor('VIS101');

      expect(result.status, 'Checked In');
      expect(visitorListStore.allVisitors.first.status, 'Checked In');
      expect(visitorListStore.currentlyCheckedIn, 1);
    });

    test('Prevents duplicate check-in when visitor is already Checked In', () async {
      visitorListStore.setVisitors([checkedInVisitor]);

      expect(
        () => visitorListStore.checkInVisitor('VIS101'),
        throwsA(contains('Visitor is already checked in')),
      );
    });

    test('Prevents check-in when visit is already Checked Out', () async {
      visitorListStore.setVisitors([checkedOutVisitor]);

      expect(
        () => visitorListStore.checkInVisitor('VIS101'),
        throwsA(contains('already completed')),
      );
    });

    test('Prevents Check-Out before Check-In', () async {
      visitorListStore.setVisitors([registeredVisitor]);

      expect(
        () => visitorListStore.checkOutVisitor('VIS101'),
        throwsA(contains('cannot check out before checking in')),
      );
    });

    test('Allows Check-Out when status is Checked In and updates API', () async {
      visitorListStore.setVisitors([checkedInVisitor]);

      when(() => mockRepository.patchVisitor(any(), any()))
          .thenAnswer((_) async => checkedOutVisitor);

      final result = await visitorListStore.checkOutVisitor('VIS101');

      expect(result.status, 'Checked Out');
      expect(visitorListStore.allVisitors.first.status, 'Checked Out');
      expect(visitorListStore.checkedOutVisitors, 1);
    });

    test('Prevents duplicate check-out when visitor is already Checked Out', () async {
      visitorListStore.setVisitors([checkedOutVisitor]);

      expect(
        () => visitorListStore.checkOutVisitor('VIS101'),
        throwsA(contains('already checked out')),
      );
    });
  });
}

