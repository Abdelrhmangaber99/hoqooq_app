import 'package:flutter_test/flutter_test.dart';
import 'package:hqooq/features/cases/data/models/create_case_request.dart';

void main() {
  test('serializes Case-owned Client and Opponent snapshots per backend CreateCaseDto', () {
    final request = CreateCaseRequest(
      caseNumber: 'CASE-2026-1',
      defaultCourtId: 'court-1',
      circuitId: 'circuit-1',
      courtName: 'Cairo Court of Appeal',
      openingDate: DateTime(2026, 8, 14, 15, 30),
      agreedFee: 12500.50,
      client: const CaseClientInput(
        clientType: 'COMPANY',
        name: 'Example Company',
        registrationNo: 'REG-1',
        email: 'legal@example.com',
      ),
      opponents: const [
        CaseOpponentInput(
          opponentType: 'INDIVIDUAL',
          name: 'Opponent One',
          representative: 'Counsel Name',
        ),
      ],
    );

    final json = request.toJson();

    expect(json.containsKey('clientId'), isFalse);
    expect(json.containsKey('tenantId'), isFalse);
    expect(json.containsKey('caseNumber'), isFalse);
    expect(json.containsKey('courtName'), isFalse);
    expect(json.containsKey('priority'), isFalse);
    expect(json.containsKey('client'), isFalse);
    expect(json['defaultCourtId'], 'court-1');
    expect(json['circuitId'], 'circuit-1');
    expect(json['agreedFee'], 12500.50);
    expect(json['openingDate'], '2026-08-14');
    final clients = json['clients'] as List<dynamic>;
    expect(clients, hasLength(1));
    expect((clients.single as Map)['name'], 'Example Company');
    expect((clients.single as Map)['registrationNo'], 'REG-1');
    final opponents = json['opponents'] as List<dynamic>;
    expect(opponents, hasLength(1));
    expect((opponents.single as Map)['name'], 'Opponent One');
    expect(json.containsValue(null), isFalse);
  });

  test('omits optional null snapshot fields and an empty opponent list', () {
    const request = CreateCaseRequest(
      client: CaseClientInput(clientType: 'INDIVIDUAL', name: 'Client'),
    );

    final json = request.toJson();
    final clients = json['clients'] as List<dynamic>;
    final client = clients.single as Map<String, dynamic>;

    expect(client.keys, containsAll(['clientType', 'name']));
    expect(client.containsKey('nationalId'), isFalse);
    expect(json.containsKey('opponents'), isFalse);
    expect(json.containsValue(null), isFalse);
  });
}
