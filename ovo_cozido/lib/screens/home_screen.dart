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

  void _iniciarPreparo() {
    setState(() {
      _estado = EstadoOvo.cru;
      _segundos = 0;
    });

    // Chamada síncrona: a tela fica travada durante os 9 segundos e só
    // redesenha com o último valor informado pelo callback.
    _service.cozinhar(
      onProgresso: (segundo, estado) {
        setState(() {
          _segundos = segundo;
          _estado = estado;
        });
      },
    );
  }

  void _cancelar() {
    _service.cancelar();
    setState(() {
      _estado = EstadoOvo.cancelado;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Temporizador de Ovo Cozido')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
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
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _iniciarPreparo,
                child: const Text('Iniciar Preparo'),
              ),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: _cancelar,
                child: const Text('Cancelar / Apagar Fogo'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
