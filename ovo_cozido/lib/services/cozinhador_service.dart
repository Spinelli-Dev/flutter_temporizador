import 'dart:io';

import '../models/estado_ovo.dart';

typedef ProgressoCallback = void Function(int segundo, EstadoOvo estado);

/// Versão inicial SÍNCRONA (demonstrativa): usa sleep(), que bloqueia a
/// thread principal. A interface congela até o preparo terminar.
class CozinhadorService {
  static const int tempoTotal = 9;

  bool _cancelado = false;

  void cancelar() {
    _cancelado = true;
  }

  EstadoOvo estadoPara(int segundo) {
    if (segundo <= 2) return EstadoOvo.cru;
    if (segundo <= 5) return EstadoOvo.gemaMole;
    if (segundo <= 8) return EstadoOvo.noPonto;
    return EstadoOvo.gemaDura;
  }

  EstadoOvo cozinhar({required ProgressoCallback onProgresso}) {
    _cancelado = false;

    for (int segundo = 1; segundo <= tempoTotal; segundo++) {
      sleep(const Duration(seconds: 1));

      if (_cancelado) {
        onProgresso(segundo, EstadoOvo.cancelado);
        return EstadoOvo.cancelado;
      }

      onProgresso(segundo, estadoPara(segundo));
    }

    return EstadoOvo.gemaDura;
  }
}
