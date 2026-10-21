import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ovo_cozido/app.dart';

Future<void> avancar(WidgetTester tester, int segundos) async {
  for (int i = 0; i < segundos; i++) {
    await tester.pump(const Duration(seconds: 1));
  }
}

VoidCallback? acaoDoBotao(WidgetTester tester, String texto) {
  return tester
      .widget<ButtonStyleButton>(
        find.ancestor(
          of: find.text(texto),
          matching: find.bySubtype<ButtonStyleButton>(),
        ),
      )
      .onPressed;
}

void main() {
  testWidgets('atualiza estado e tempo a cada segundo até Gema Dura', (
    tester,
  ) async {
    await tester.pumpWidget(const App());
    expect(find.text('Ovo Cru 🥚'), findsOneWidget);
    expect(find.text('Tempo: 0 s / 9 s'), findsOneWidget);

    await tester.tap(find.text('Iniciar Preparo'));
    await avancar(tester, 1);
    expect(find.text('Tempo: 1 s / 9 s'), findsOneWidget);
    expect(find.text('Ovo Cru 🥚'), findsOneWidget);

    await avancar(tester, 2);
    expect(find.text('Tempo: 3 s / 9 s'), findsOneWidget);
    expect(find.text('Gema Mole 🍳'), findsOneWidget);

    await avancar(tester, 3);
    expect(find.text('Tempo: 6 s / 9 s'), findsOneWidget);
    expect(find.text('No Ponto 🥚'), findsOneWidget);

    await avancar(tester, 3);
    expect(find.text('Tempo: 9 s / 9 s'), findsOneWidget);
    expect(find.text('Gema Dura 🥚'), findsOneWidget);
    expect(acaoDoBotao(tester, 'Iniciar Preparo'), isNotNull);
    expect(acaoDoBotao(tester, 'Cancelar / Apagar Fogo'), isNull);
  });

  testWidgets('desabilita Iniciar enquanto o preparo está ativo', (
    tester,
  ) async {
    await tester.pumpWidget(const App());
    await tester.tap(find.text('Iniciar Preparo'));
    await tester.pump();

    expect(acaoDoBotao(tester, 'Iniciar Preparo'), isNull);
    expect(acaoDoBotao(tester, 'Cancelar / Apagar Fogo'), isNotNull);

    await avancar(tester, 9);
  });

  testWidgets('cancelar mantém o tempo do cancelamento', (tester) async {
    await tester.pumpWidget(const App());
    await tester.tap(find.text('Iniciar Preparo'));
    await avancar(tester, 4);

    await tester.tap(find.text('Cancelar / Apagar Fogo'));
    await tester.pump();
    expect(find.text('Preparo Cancelado! 🔥❌'), findsOneWidget);
    expect(find.text('Tempo: 4 s / 9 s'), findsOneWidget);
    expect(acaoDoBotao(tester, 'Iniciar Preparo'), isNotNull);

    await avancar(tester, 9);
    expect(find.text('Preparo Cancelado! 🔥❌'), findsOneWidget);
    expect(find.text('Tempo: 4 s / 9 s'), findsOneWidget);
  });

  testWidgets('remover a tela durante o preparo não gera erros', (
    tester,
  ) async {
    await tester.pumpWidget(const App());
    await tester.tap(find.text('Iniciar Preparo'));
    await avancar(tester, 2);

    await tester.pumpWidget(const SizedBox());
    await avancar(tester, 9);
    expect(tester.takeException(), isNull);
  });

  testWidgets('não estoura o layout em tela pequena', (tester) async {
    tester.view.physicalSize = const Size(240, 280);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const App());
    await tester.ensureVisible(find.text('Iniciar Preparo'));
    await tester.tap(find.text('Iniciar Preparo'));
    await avancar(tester, 9);

    expect(tester.takeException(), isNull);
    expect(find.text('Gema Dura 🥚'), findsOneWidget);
  });
}
