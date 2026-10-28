import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:visitor_management_app/data/repository.dart';
import 'package:visitor_management_app/models/visitors_list/visitors_model.dart';
import 'package:visitor_management_app/stores/visitor_registration/visitor_registration_store.dart';

class MockRepository extends Mock implements Repository {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late MockRepository mockRepository;
  late VisitorRegistrationStore registrationStore;

  setUp(() {
    mockRepository = MockRepository();
    registrationStore = VisitorRegistrationStore(mockRepository);
  });

  group('VisitorRegistrationStore Tests', () {
    final samplePayload = {
      "id": "VIS999",
      "name": "Yash Vora",
      "mobile": "9876543210",
      "email": "yash@example.com",
      "visitor_type": "Customer",
      "project": "Project A",
      "purpose": "Site Visit",
      "status": "Registered",
      "created_at": "2026-10-28T10:00:00.000Z",
      "check_in_time": null,
      "check_out_time": null,
    };

    final createdModel = VisitorListModel.fromJson(samplePayload);

    test('Initial store state is clean', () {
      expect(registrationStore.isLoading, false);
      expect(registrationStore.isSuccess, false);
      expect(registrationStore.createdVisitor, isNull);
      expect(registrationStore.errorStore.errorMessage, isEmpty);
    });

    test('Successfully registers a new visitor', () async {
      when(() => mockRepository.registerVisitor(samplePayload))
          .thenAnswer((_) async => createdModel);

      final result = await registrationStore.registerVisitor(samplePayload);

      expect(result, isNotNull);
      expect(result!.id, 'VIS999');
      expect(result.name, 'Yash Vora');
      expect(result.checkInTime, isNull);
      expect(result.checkOutTime, isNull);
      expect(registrationStore.isSuccess, true);
      expect(registrationStore.isLoading, false);
      expect(registrationStore.createdVisitor, equals(createdModel));
    });

    test('Successfully updates an existing visitor', () async {
      when(() => mockRepository.updateVisitor('VIS999', samplePayload))
          .thenAnswer((_) async => createdModel);

      final result = await registrationStore.updateVisitor('VIS999', samplePayload);

      expect(result, isNotNull);
      expect(result!.id, 'VIS999');
      expect(registrationStore.isSuccess, true);
    });

    test('Handles registration failure and sets error message', () async {
      when(() => mockRepository.registerVisitor(samplePayload))
          .thenThrow(Exception('Network error'));

      try {
        await registrationStore.registerVisitor(samplePayload);
        fail('Should throw exception');
      } catch (e) {
        expect(e, isA<Exception>());
      }

      expect(registrationStore.isSuccess, false);
      expect(registrationStore.isLoading, false);
      expect(registrationStore.errorStore.errorMessage, contains('Network error'));
    });

    test('Reset action cleans all state', () async {
      when(() => mockRepository.registerVisitor(samplePayload))
          .thenAnswer((_) async => createdModel);

      await registrationStore.registerVisitor(samplePayload);
      expect(registrationStore.createdVisitor, isNotNull);

      registrationStore.reset();

      expect(registrationStore.isLoading, false);
      expect(registrationStore.isSuccess, false);
      expect(registrationStore.createdVisitor, isNull);
      expect(registrationStore.errorStore.errorMessage, isEmpty);
    });
  });
}
