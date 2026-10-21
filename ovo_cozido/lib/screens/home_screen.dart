import 'package:flutter/material.dart';

import '../models/estado_ovo.dart';
import '../services/cozinhador_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final CozinhadorService _service = CozinhadorService();

  EstadoOvo _estado = EstadoOvo.cru;
  int _segundos = 0;

  Future<void> _iniciarPreparo() async {
    if (_service.emAndamento) return;

    setState(() {
      _estado = EstadoOvo.cru;
      _segundos = 0;
    });

    await _service.cozinhar(
      onProgresso: (segundo, estado) {
        if (!mounted) return;
        setState(() {
          _segundos = segundo;
          _estado = estado;
        });
      },
    );

    // Atualiza os botões depois que o serviço encerra o preparo.
    if (mounted) setState(() {});
  }

  void _cancelar() {
    _service.cancelar();
    setState(() {
      _estado = EstadoOvo.cancelado;
    });
  }

  @override
  void dispose() {
    _service.cancelar();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final emAndamento = _service.emAndamento;

    return Scaffold(
      appBar: AppBar(title: const Text('Temporizador de Ovo Cozido')),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            // Centraliza em telas grandes e permite rolagem em telas pequenas.
            return SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: (constraints.maxHeight - 48).clamp(
                    0,
                    double.infinity,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      _estado.descricao,
                      style: Theme.of(context).textTheme.headlineMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Tempo: $_segundos s / ${CozinhadorService.tempoTotal} s',
                      style: Theme.of(context).textTheme.titleLarge,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),
                    ElevatedButton(
                      onPressed: emAndamento ? null : _iniciarPreparo,
                      child: const Text('Iniciar Preparo'),
                    ),
                    const SizedBox(height: 12),
                    OutlinedButton(
                      onPressed: emAndamento ? _cancelar : null,
                      child: const Text('Cancelar / Apagar Fogo'),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
