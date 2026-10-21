import 'package:flutter_test/flutter_test.dart';
import 'package:ovo_cozido/models/estado_ovo.dart';
import 'package:ovo_cozido/services/cozinhador_service.dart';

// Os testes de tempo usam testWidgets para aproveitar o relógio simulado:
// tester.pump(duração) avança os Future.delayed sem esperar de verdade.
Future<void> avancar(WidgetTester tester, int segundos) async {
  for (int i = 0; i < segundos; i++) {
    await tester.pump(const Duration(seconds: 1));
  }
}

void main() {
  test('estadoPara segue a tabela de tempos', () {
    final esperado = {
      0: EstadoOvo.cru,
      1: EstadoOvo.cru,
      2: EstadoOvo.cru,
      3: EstadoOvo.gemaMole,
      5: EstadoOvo.gemaMole,
      6: EstadoOvo.noPonto,
      8: EstadoOvo.noPonto,
      9: EstadoOvo.gemaDura,
    };

    esperado.forEach((segundo, estado) {
      expect(
        CozinhadorService.estadoPara(segundo),
        estado,
        reason: '$segundo s',
      );
    });
  });

  testWidgets('notifica cada segundo e termina em Gema Dura aos 9 s', (
    tester,
  ) async {
    final service = CozinhadorService();
    final progresso = <(int, EstadoOvo)>[];
    EstadoOvo? resultado;

    service
        .cozinhar(onProgresso: (s, e) => progresso.add((s, e)))
        .then((r) => resultado = r);
    expect(service.emAndamento, isTrue);

    await avancar(tester, 8);
    expect(progresso.length, 8);
    expect(resultado, isNull);

    await avancar(tester, 1);
    expect(progresso, [
      for (int s = 1; s <= 9; s++) (s, CozinhadorService.estadoPara(s)),
    ]);
    expect(resultado, EstadoOvo.gemaDura);
    expect(service.emAndamento, isFalse);
  });

  testWidgets('cancelar interrompe o preparo sem novas notificações', (
    tester,
  ) async {
    final service = CozinhadorService();
    final progresso = <int>[];
    EstadoOvo? resultado;

    service
        .cozinhar(onProgresso: (s, _) => progresso.add(s))
        .then((r) => resultado = r);

    await avancar(tester, 4);
    service.cancelar();
    expect(service.emAndamento, isFalse);

    await avancar(tester, 9);
    expect(progresso, [1, 2, 3, 4]);
    expect(resultado, EstadoOvo.cancelado);
  });

  testWidgets('impede dois preparos simultâneos', (tester) async {
    final service = CozinhadorService();
    service.cozinhar(onProgresso: (_, _) {});

    await expectLater(
      service.cozinhar(onProgresso: (_, _) {}),
      throwsStateError,
    );

    service.cancelar();
    await avancar(tester, 1);
  });

  testWidgets('novo preparo após cancelar não recebe eventos do anterior', (
    tester,
  ) async {
    final service = CozinhadorService();
    final antigo = <int>[];
    final novo = <int>[];

    service.cozinhar(onProgresso: (s, _) => antigo.add(s));
    await avancar(tester, 2);
    service.cancelar();

    service.cozinhar(onProgresso: (s, _) => novo.add(s));
    await avancar(tester, 9);

    expect(antigo, [1, 2]);
    expect(novo, [1, 2, 3, 4, 5, 6, 7, 8, 9]);
  });
}
