import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ConfiguracionContribucionScreen extends StatefulWidget {
  @override
  _ConfiguracionContribucionScreenState createState() =>
      _ConfiguracionContribucionScreenState();
}

class _ConfiguracionContribucionScreenState
    extends State<ConfiguracionContribucionScreen> {
  int _currentStep = 0;
  List<String> _cultivosSeleccionados = [];
  Map<String, List<String>> _tiposSeleccionadosPorCultivo = {};
  Map<String, Map<String, dynamic>> _configuracionFinal = {};

  int _cultivoActualIndex = 0;
  int _tipoActualIndex = 0;
  String _estadoSeleccionado = '';
  List<String> _enfermedadesSeleccionadas = [];

  List<String> cultivosDisponibles = [];
  Map<String, List<String>> tiposPorCultivo = {};
  Map<String, List<String>> enfermedadesPorCultivo = {};
  List<String> estadosDisponibles = [];

  @override
  void initState() {
    super.initState();
    _cargarDatosDesdeFirestore();
  }

  Future<void> _cargarDatosDesdeFirestore() async {
    // Cargar cultivos
    QuerySnapshot cultivosSnapshot = await FirebaseFirestore.instance
        .collection('configuraciones')
        .doc('cultivos')
        .collection('cultivos')
        .get();

    setState(() {
      cultivosDisponibles = cultivosSnapshot.docs.map((doc) => doc.id).toList();
      for (var doc in cultivosSnapshot.docs) {
        tiposPorCultivo[doc.id] = List<String>.from(doc['tipos']);
        enfermedadesPorCultivo[doc.id] = List<String>.from(doc['enfermedades']);
      }
    });

    // Cargar estados
    DocumentSnapshot estadosSnapshot = await FirebaseFirestore.instance
        .collection('configuraciones')
        .doc('cultivos_estados')
        .get();

    if (estadosSnapshot.exists) {
      print("✅ Documento cultivo_estados encontrado.");

      Map<String, dynamic>? data =
          estadosSnapshot.data() as Map<String, dynamic>?;
      print("📌 Datos obtenidos: $data");

      if (data != null) {
        if (data.containsKey('estados')) {
          print("🔍 Tipo de 'estados': \${data['estados'].runtimeType}");

          if (data['estados'] is List) {
            setState(() {
              estadosDisponibles = List<String>.from(data['estados']);
            });
            print("✅ Estados cargados correctamente: $estadosDisponibles");
          } else {
            print("⚠️ El campo 'estados' no es un array.");
          }
        } else {
          print("⚠️ El campo 'estados' no existe en el documento.");
        }
      } else {
        print("⚠️ El documento está vacío.");
      }
    } else {
      print("❌ El documento cultivo_estados no existe en Firestore.");
    }
  }

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
      return _procesarSeleccionEnfermedades();
    } else if (_currentStep == 4) {
      return _buildResumenFinal();
    }
    return Container();
  }

  Widget _buildSeleccionTipos() {
    final String cultivoActual = _cultivosSeleccionados[_cultivoActualIndex];
    final List<String> tiposDisponibles = tiposPorCultivo[cultivoActual] ?? [];
    final List<String> tiposSeleccionados =
        _tiposSeleccionadosPorCultivo[cultivoActual] ?? [];

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
            final bool isSelected = tiposSeleccionados.contains(tipo);
            return ChoiceChip(
              label: Text(tipo),
              selected: isSelected,
              selectedColor: Colors.green[100],
              onSelected: (selected) {
                setState(() {
                  if (selected) {
                    _tiposSeleccionadosPorCultivo[cultivoActual]?.add(tipo);
                  } else {
                    _tiposSeleccionadosPorCultivo[cultivoActual]?.remove(tipo);
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
                  _cultivoActualIndex++; // Pasar al siguiente cultivo
                });
              } else {
                setState(() {
                  _currentStep++; // Pasar al siguiente paso si ya seleccionamos todos los cultivos
                  _cultivoActualIndex = 0;
                });
              }
            }
          },
          child: Text(
            _cultivoActualIndex < _cultivosSeleccionados.length - 1
                ? 'Siguiente Cultivo'
                : 'Siguiente Paso',
          ),
          style: ElevatedButton.styleFrom(backgroundColor: Color(0xFF0BA37F)),
        ),
      ],
    );
  }

  Widget _buildConfiguracionPorTipo() {
    final String cultivoActual = _cultivosSeleccionados[_cultivoActualIndex];
    final List<String> tiposSeleccionados =
        _tiposSeleccionadosPorCultivo[cultivoActual] ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Selecciona el estado de los tipos de $cultivoActual:',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 10),
        Expanded(
          child: ListView(
            children: tiposSeleccionados.map((tipo) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    tipo,
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 5),
                  Wrap(
                    spacing: 8,
                    children: estadosDisponibles.map((estado) {
                      final bool isSelected = _configuracionFinal[cultivoActual]
                              ?[tipo]?['estado'] ==
                          estado;
                      return ChoiceChip(
                        label: Text(estado),
                        selected: isSelected,
                        selectedColor: Colors.green[100],
                        onSelected: (selected) {
                          setState(() {
                            _configuracionFinal.putIfAbsent(
                                cultivoActual, () => {});
                            _configuracionFinal[cultivoActual]!
                                .putIfAbsent(tipo, () => {});
                            _configuracionFinal[cultivoActual]![tipo]
                                ['estado'] = estado;
                            if (estado == "Con enfermedad") {
                              _configuracionFinal[cultivoActual]![tipo]
                                  ['enfermedades'] = [];
                            } else {
                              _configuracionFinal[cultivoActual]![tipo]
                                  ['enfermedades'] = null;
                            }
                          });
                        },
                      );
                    }).toList(),
                  ),
                  SizedBox(height: 15),
                  Divider(color: Colors.grey[400]),
                ],
              );
            }).toList(),
          ),
        ),
        ElevatedButton(
          onPressed: () {
            if (_cultivoActualIndex < _cultivosSeleccionados.length - 1) {
              setState(() {
                _cultivoActualIndex++; // Pasar al siguiente cultivo
              });
            } else {
              setState(() {
                _currentStep++; // Pasar al siguiente paso si ya seleccionamos todos los cultivos
                _cultivoActualIndex = 0;
              });
            }
          },
          child: Text(
            _cultivoActualIndex < _cultivosSeleccionados.length - 1
                ? 'Siguiente Cultivo'
                : 'Siguiente Paso',
          ),
          style: ElevatedButton.styleFrom(backgroundColor: Color(0xFF0BA37F)),
        ),
      ],
    );
  }

  Widget _buildSeleccionEnfermedades(String cultivoActual, String tipoActual) {
    List<String> enfermedadesDisponibles =
        enfermedadesPorCultivo[cultivoActual] ?? [];

    // 🔹 Inicializar la estructura si no existe
    _configuracionFinal.putIfAbsent(cultivoActual, () => {});
    _configuracionFinal[cultivoActual]!.putIfAbsent(tipoActual, () => {});
    _configuracionFinal[cultivoActual]![tipoActual]!
        .putIfAbsent('enfermedades', () => <String>[]);

    // ✅ Acceder a la lista garantizando que no sea nula
    final List<String> enfermedades = List<String>.from(
        _configuracionFinal[cultivoActual]![tipoActual]!['enfermedades'] ??
            <String>[]);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Selecciona las enfermedades para $tipoActual ($cultivoActual):',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: enfermedadesDisponibles.map((enfermedad) {
            final bool isSelected = enfermedades.contains(enfermedad);

            return ChoiceChip(
              label: Text(enfermedad),
              selected: isSelected,
              selectedColor: Colors.orange[100],
              onSelected: (selected) {
                setState(() {
                  if (selected) {
                    _configuracionFinal[cultivoActual]![tipoActual]![
                        'enfermedades'] = [...enfermedades, enfermedad];
                  } else {
                    _configuracionFinal[cultivoActual]![tipoActual]![
                            'enfermedades'] =
                        enfermedades.where((e) => e != enfermedad).toList();
                  }
                });
              },
            );
          }).toList(),
        ),
        Spacer(),
        ElevatedButton(
          onPressed: () {
            _avanzarAlSiguienteTipoOCultivo();
            setState(() {}); // Refrescar la UI
          },
          child: Text('Siguiente'),
          style: ElevatedButton.styleFrom(backgroundColor: Color(0xFF0BA37F)),
        ),
      ],
    );
  }

  void _avanzarAlSiguienteTipoOCultivo() {
    String cultivoActual = _cultivosSeleccionados[_cultivoActualIndex];
    List<String> tiposCultivo =
        _tiposSeleccionadosPorCultivo[cultivoActual] ?? [];

    if (_tipoActualIndex < tiposCultivo.length - 1) {
      _tipoActualIndex++;
    } else {
      _tipoActualIndex = 0;
      _cultivoActualIndex++;
    }

    // Si ya terminamos todos los cultivos, avanzar al resumen
    if (_cultivoActualIndex >= _cultivosSeleccionados.length) {
      _currentStep++;
    }
  }

  Widget _procesarSeleccionEnfermedades() {
    // Verificar si hay más cultivos que procesar
    if (_cultivoActualIndex < _cultivosSeleccionados.length) {
      String cultivoActual = _cultivosSeleccionados[_cultivoActualIndex];
      List<String> tiposCultivo =
          _tiposSeleccionadosPorCultivo[cultivoActual] ?? [];

      // Verificar si hay más tipos de cultivo en este cultivo que procesar
      if (_tipoActualIndex < tiposCultivo.length) {
        String tipoActual = tiposCultivo[_tipoActualIndex];
        String estadoActual =
            _configuracionFinal[cultivoActual]?[tipoActual]?['estado'] ?? '';

        // Si el tipo de cultivo tiene "Con enfermedad", mostrar selección de enfermedades
        if (estadoActual == "Con_enfermedad") {
          return _buildSeleccionEnfermedades(cultivoActual, tipoActual);
        } else {
          // Si el tipo no tiene "Con enfermedad", pasar al siguiente
          _avanzarAlSiguienteTipoOCultivo();
          return _procesarSeleccionEnfermedades(); // Llamar recursivamente hasta encontrar uno con enfermedad o terminar
        }
      } else {
        // Si no hay más tipos en este cultivo, pasar al siguiente cultivo
        _cultivoActualIndex++;
        _tipoActualIndex = 0;
        return _procesarSeleccionEnfermedades(); // Volver a iterar
      }
    }

    // Si ya no hay más cultivos/tipos que procesar, ir al resumen
    return _buildResumenFinal();
  }

  void _guardarConfiguracion(String cultivoActual, String tipoActual) {
    if (_estadoSeleccionado.isNotEmpty) {
      _configuracionFinal.putIfAbsent(cultivoActual, () => {});
      _configuracionFinal[cultivoActual]!.putIfAbsent(tipoActual, () => {});

      _configuracionFinal[cultivoActual]![tipoActual]['estado'] =
          _estadoSeleccionado;

      // ✅ Si el estado es "Con enfermedad", asegurarse de inicializar la lista de enfermedades
      if (_estadoSeleccionado == "Con_enfermedad") {
        _configuracionFinal[cultivoActual]![tipoActual]
            .putIfAbsent('enfermedades', () => []);
      } else {
        _configuracionFinal[cultivoActual]![tipoActual]['enfermedades'] = [];
      }

      _avanzarAlSiguienteTipoOCultivo();
    }
  }

  Widget _buildResumenFinal() {
    return ListView(
      padding: EdgeInsets.all(16.0),
      children: [
        Text(
          '📋 Resumen de tu configuración',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 10),
        ..._configuracionFinal.entries.map((cultivoEntry) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '🌱 Cultivo: ${cultivoEntry.key}',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.green[800],
                ),
              ),
              Divider(color: Colors.grey),
              ...cultivoEntry.value.entries.map((tipoEntry) {
                final String tipo = tipoEntry.key;
                final String estado =
                    tipoEntry.value['estado'] ?? 'No especificado';
                final List<String> enfermedades =
                    (tipoEntry.value['enfermedades'] as List<String>? ?? []);

                return Padding(
                  padding: const EdgeInsets.only(left: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '🌿 Tipo: $tipo',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        '🩺 Estado: $estado',
                        style: TextStyle(fontSize: 14),
                      ),
                      if (enfermedades.isNotEmpty)
                        Text(
                          '⚠️ Enfermedades: ${enfermedades.join(', ')}',
                          style:
                              TextStyle(fontSize: 14, color: Colors.red[700]),
                        ),
                      SizedBox(height: 10),
                      Divider(color: Colors.grey[400]),
                    ],
                  ),
                );
              }).toList(),
            ],
          );
        }).toList(),
        SizedBox(height: 20),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context); // Volver al inicio o a donde corresponda
          },
          child: Text('Finalizar'),
          style: ElevatedButton.styleFrom(backgroundColor: Color(0xFF0BA37F)),
        ),
      ],
    );
  }

  Widget _buildSeleccionCultivos() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Selecciona los cultivos:',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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
}
