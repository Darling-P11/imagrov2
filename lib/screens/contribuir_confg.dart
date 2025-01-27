import 'package:flutter/material.dart';

class ConfiguracionContribucionScreen extends StatefulWidget {
  @override
  _ConfiguracionContribucionScreenState createState() =>
      _ConfiguracionContribucionScreenState();
}

class _ConfiguracionContribucionScreenState
    extends State<ConfiguracionContribucionScreen> {
  int _currentStep = 0; // Paso actual
  List<String> _cultivosSeleccionados = [];
  Map<String, List<String>> _tiposSeleccionadosPorCultivo =
      {}; // Tipos por cultivo
  Map<String, Map<String, dynamic>> _configuracionFinal =
      {}; // Configuración final

  int _cultivoActualIndex = 0; // Índice del cultivo actual
  int _tipoActualIndex = 0; // Índice del tipo actual
  String _estadoSeleccionado = '';
  List<String> _enfermedadesSeleccionadas = [];

  final List<String> cultivosDisponibles = ['Cacao', 'Yuca', 'Papaya', 'Verde'];
  final Map<String, List<String>> tiposPorCultivo = {
    'Cacao': ['Nacional', 'CCN-51', 'Cacao Ramilla'],
    'Yuca': ['Blanca', 'Amarilla'],
    'Papaya': ['Hawaiana', 'Maradol'],
    'Verde': ['Tipo 1', 'Tipo 2']
  };
  final List<String> enfermedadesDisponibles = [
    'Moniliasis',
    'Pudrición',
    'Mancha'
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Configurar Contribución'),
        backgroundColor: Color(0xFF0BA37F),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _buildStepContent(),
      ),
    );
  }

  Widget _buildStepContent() {
    if (_currentStep == 0) {
      return _buildSeleccionCultivos();
    } else if (_currentStep == 1) {
      return _buildSeleccionTipos();
    } else if (_currentStep == 2) {
      return _buildConfiguracionPorTipo();
    } else if (_currentStep == 3) {
      return _buildResumenFinal();
    }
    return Container();
  }

  // Paso 1: Selección de cultivos
  Widget _buildSeleccionCultivos() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Selecciona los cultivos:',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: cultivosDisponibles.map((cultivo) {
            final isSelected = _cultivosSeleccionados.contains(cultivo);
            return ChoiceChip(
              label: Text(cultivo),
              selected: isSelected,
              selectedColor: Colors.green[100],
              onSelected: (selected) {
                setState(() {
                  if (selected) {
                    _cultivosSeleccionados.add(cultivo);
                    _tiposSeleccionadosPorCultivo[cultivo] = [];
                  } else {
                    _cultivosSeleccionados.remove(cultivo);
                    _tiposSeleccionadosPorCultivo.remove(cultivo);
                  }
                });
              },
            );
          }).toList(),
        ),
        Spacer(),
        ElevatedButton(
          onPressed: () {
            if (_cultivosSeleccionados.isNotEmpty) {
              setState(() {
                _currentStep++;
              });
            }
          },
          child: Text('Siguiente'),
          style: ElevatedButton.styleFrom(backgroundColor: Color(0xFF0BA37F)),
        ),
      ],
    );
  }

  // Paso 2: Selección de tipos por cultivo
  Widget _buildSeleccionTipos() {
    final cultivoActual = _cultivosSeleccionados[_cultivoActualIndex];
    final tiposDisponibles = tiposPorCultivo[cultivoActual] ?? [];
    final tiposSeleccionados = _tiposSeleccionadosPorCultivo[cultivoActual]!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Selecciona los tipos de $cultivoActual:',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: tiposDisponibles.map((tipo) {
            final isSelected = tiposSeleccionados.contains(tipo);
            return ChoiceChip(
              label: Text(tipo),
              selected: isSelected,
              selectedColor: Colors.green[100],
              onSelected: (selected) {
                setState(() {
                  if (selected) {
                    _tiposSeleccionadosPorCultivo[cultivoActual]!.add(tipo);
                  } else {
                    _tiposSeleccionadosPorCultivo[cultivoActual]!.remove(tipo);
                  }
                });
              },
            );
          }).toList(),
        ),
        Spacer(),
        ElevatedButton(
          onPressed: () {
            if (tiposSeleccionados.isNotEmpty) {
              if (_cultivoActualIndex < _cultivosSeleccionados.length - 1) {
                setState(() {
                  _cultivoActualIndex++;
                });
              } else {
                setState(() {
                  _currentStep++;
                  _cultivoActualIndex = 0;
                  _tipoActualIndex = 0;
                });
              }
            }
          },
          child: Text('Siguiente'),
          style: ElevatedButton.styleFrom(backgroundColor: Color(0xFF0BA37F)),
        ),
      ],
    );
  }

  // Paso 3: Configuración de cada tipo
  Widget _buildConfiguracionPorTipo() {
    final cultivoActual = _cultivosSeleccionados[_cultivoActualIndex];
    final tiposSeleccionados = _tiposSeleccionadosPorCultivo[cultivoActual]!;
    final tipoActual = tiposSeleccionados[_tipoActualIndex];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Configurando $tipoActual (${_tipoActualIndex + 1}/${tiposSeleccionados.length}) - $cultivoActual',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 20),
        Text('Selecciona el estado del producto:'),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildEstadoButton('Natural', Icons.eco),
            _buildEstadoButton('Con enfermedad', Icons.warning),
            _buildEstadoButton('Generalizar', Icons.layers),
          ],
        ),
        if (_estadoSeleccionado == 'Con enfermedad') ...[
          SizedBox(height: 20),
          Text('Selecciona las enfermedades:'),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: enfermedadesDisponibles.map((enfermedad) {
              final isSelected =
                  _enfermedadesSeleccionadas.contains(enfermedad);
              return ChoiceChip(
                label: Text(enfermedad),
                selected: isSelected,
                selectedColor: Colors.orange[100],
                onSelected: (selected) {
                  setState(() {
                    if (selected) {
                      _enfermedadesSeleccionadas.add(enfermedad);
                    } else {
                      _enfermedadesSeleccionadas.remove(enfermedad);
                    }
                  });
                },
              );
            }).toList(),
          ),
        ],
        Spacer(),
        ElevatedButton(
          onPressed: () {
            _guardarConfiguracion(cultivoActual, tipoActual);
          },
          child: Text(
            _tipoActualIndex < tiposSeleccionados.length - 1
                ? 'Siguiente Tipo'
                : _cultivoActualIndex < _cultivosSeleccionados.length - 1
                    ? 'Siguiente Cultivo'
                    : 'Finalizar Configuración',
          ),
          style: ElevatedButton.styleFrom(backgroundColor: Color(0xFF0BA37F)),
        ),
      ],
    );
  }

  void _guardarConfiguracion(String cultivoActual, String tipoActual) {
    if (_estadoSeleccionado.isNotEmpty) {
      _configuracionFinal.putIfAbsent(cultivoActual, () => {});
      _configuracionFinal[cultivoActual]![tipoActual] = {
        'estado': _estadoSeleccionado,
        'enfermedades': _estadoSeleccionado == 'Con enfermedad'
            ? _enfermedadesSeleccionadas
            : [],
      };

      if (_tipoActualIndex <
          _tiposSeleccionadosPorCultivo[cultivoActual]!.length - 1) {
        setState(() {
          _tipoActualIndex++;
          _estadoSeleccionado = '';
          _enfermedadesSeleccionadas.clear();
        });
      } else if (_cultivoActualIndex < _cultivosSeleccionados.length - 1) {
        setState(() {
          _cultivoActualIndex++;
          _tipoActualIndex = 0;
          _estadoSeleccionado = '';
          _enfermedadesSeleccionadas.clear();
        });
      } else {
        setState(() {
          _currentStep++;
        });
      }
    }
  }

  Widget _buildEstadoButton(String label, IconData icon) {
    return ElevatedButton.icon(
      onPressed: () {
        setState(() {
          _estadoSeleccionado = label;
        });
      },
      icon: Icon(icon),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor:
            _estadoSeleccionado == label ? Colors.green[200] : Colors.white,
        foregroundColor: Colors.black,
      ),
    );
  }

  // Paso 4: Resumen Final
  Widget _buildResumenFinal() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Resumen Final',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        ..._configuracionFinal.entries.map((entry) {
          final cultivo = entry.key;
          final tipos = entry.value;
          return Card(
            child: ListTile(
              title: Text(cultivo),
              subtitle: Text(tipos.toString()),
            ),
          );
        }).toList(),
      ],
    );
  }
}
