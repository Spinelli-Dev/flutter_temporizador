import '../models/estado_ovo.dart';

typedef ProgressoCallback = void Function(int segundo, EstadoOvo estado);

/// Controle de uma execução de [CozinhadorService.cozinhar].
class _Preparo {
  bool cancelado = false;
}

/// Temporizador assíncrono: cada etapa aguarda com Future.delayed, liberando
/// a thread principal para a interface continuar respondendo.
class CozinhadorService {
  static const int tempoTotal = 9;

  _Preparo? _atual;

  bool get emAndamento => _atual != null;

  static EstadoOvo estadoPara(int segundo) {
    if (segundo <= 2) return EstadoOvo.cru;
    if (segundo <= 5) return EstadoOvo.gemaMole;
    if (segundo <= 8) return EstadoOvo.noPonto;
    return EstadoOvo.gemaDura;
  }

  /// Sinaliza o cancelamento do preparo atual. A execução cancelada não chama
  /// mais o callback e termina retornando [EstadoOvo.cancelado].
  void cancelar() {
    _atual?.cancelado = true;
    _atual = null;
  }

  Future<EstadoOvo> cozinhar({required ProgressoCallback onProgresso}) async {
    if (_atual != null) {
      throw StateError('Já existe um preparo em andamento.');
    }

    final preparo = _Preparo();
    _atual = preparo;

    for (int segundo = 1; segundo <= tempoTotal; segundo++) {
      await Future.delayed(const Duration(seconds: 1));

      if (preparo.cancelado) return EstadoOvo.cancelado;

      onProgresso(segundo, estadoPara(segundo));
    }

    _atual = null;
    return EstadoOvo.gemaDura;
  }
}
