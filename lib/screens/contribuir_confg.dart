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
      body: Column(
        children: [
          // ✅ Sección del encabezado con espacio para la barra de estado
          Container(
            width: double.infinity,
            padding: EdgeInsets.only(
              top:
                  MediaQuery.of(context).padding.top + 15, // Espaciado dinámico
              bottom: 20, // Espaciado inferior del encabezado
            ),
            decoration: BoxDecoration(
              color: Color(0xFF0BA37F), // Color verde del encabezado
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(40),
                bottomRight: Radius.circular(40),
              ),
            ),
            child: Center(
              child: Text(
                'Configura tu contribución',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),

          // ✅ Contenido del proceso
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: _buildStepContent(),
            ),
          ),
        ],
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

    // Genera un color basado en el cultivo actual
    final List<Color> colores = [
      const Color.fromARGB(255, 2, 96, 173)!,
      const Color.fromARGB(255, 156, 2, 79)!,
      const Color.fromARGB(255, 212, 127, 0)!,
      const Color.fromARGB(255, 139, 0, 163)!,
      const Color.fromARGB(255, 129, 0, 0)!
    ];
    final Color colorCultivo =
        colores[_cultivoActualIndex % colores.length]; // Alterna colores

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ✅ Encabezado con "Selecciona las variedades de:" y el nombre del cultivo
        Row(
          children: [
            // Texto fijo "Selecciona las variedades de:"
            Container(
              padding: EdgeInsets.symmetric(horizontal: 15, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.grey[300], // Color neutro fijo
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'Selecciona las variedades de:',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ),

            SizedBox(width: 8),

            // ✅ Container dinámico para el nombre del cultivo
            Container(
              padding: EdgeInsets.symmetric(horizontal: 15, vertical: 8),
              decoration: BoxDecoration(
                color: colorCultivo, // Color dinámico para cada cultivo
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                cultivoActual,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),

        SizedBox(height: 5),

        // ✅ Línea divisoria
        Divider(color: Colors.grey[400]),

        SizedBox(height: 10),

        Padding(
          padding: EdgeInsets.only(bottom: 20), // Agrega espacio abajo
          child: Align(
            alignment: Alignment.center,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 40, vertical: 5),
              decoration: BoxDecoration(
                color: Color.fromARGB(255, 16, 184, 144), // Color fijo verde
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'Variedades',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),

        SizedBox(height: 10),

        // ✅ Lista de variedades con alineación izquierda
        Align(
          alignment: Alignment.centerLeft,
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: tiposDisponibles.map((tipo) {
              final bool isSelected = tiposSeleccionados.contains(tipo);
              return GestureDetector(
                onTap: () {
                  setState(() {
                    if (isSelected) {
                      _tiposSeleccionadosPorCultivo[cultivoActual]
                          ?.remove(tipo);
                    } else {
                      _tiposSeleccionadosPorCultivo[cultivoActual]?.add(tipo);
                    }
                  });
                },
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: isSelected ? Colors.green : Colors.grey,
                      width: isSelected ? 2 : 1,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    color: isSelected ? Colors.green[100] : Colors.white,
                  ),
                  child: Text(
                    tipo,
                    style: TextStyle(
                      fontSize: 16,
                      color: isSelected ? Colors.green[900] : Colors.black,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),

        Spacer(),

        // ✅ Botones de navegación alineados al pie de la pantalla con texto en blanco
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    setState(() {
                      _currentStep--;
                    });
                  },
                  icon: Icon(Icons.arrow_back, size: 18, color: Colors.white),
                  label: Text(
                    'Atrás',
                    style: TextStyle(color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF0BA37F),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
                SizedBox(height: 5),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context); // Cancelar y volver al inicio
                  },
                  child: Text(
                    'Cancelar',
                    style: TextStyle(color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red[300],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
              ],
            ),
            ElevatedButton.icon(
              onPressed: tiposSeleccionados.isNotEmpty
                  ? () {
                      if (_cultivoActualIndex <
                          _cultivosSeleccionados.length - 1) {
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
                  : null, // Deshabilita si no hay selección
              icon: Icon(Icons.arrow_forward, size: 18, color: Colors.white),
              label: Text(
                'Siguiente',
                style: TextStyle(color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF0BA37F),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  bool _todosTiposConEstadoSeleccionado(String cultivoActual) {
    final tiposSeleccionados =
        _tiposSeleccionadosPorCultivo[cultivoActual] ?? [];
    for (var tipo in tiposSeleccionados) {
      if (_configuracionFinal[cultivoActual]?[tipo]?['estado'] == null) {
        return false; // Si al menos un tipo no tiene estado, retorna false
      }
    }
    return true; // Si todos tienen estado, retorna true
  }

  Widget _buildConfiguracionPorTipo() {
    final String cultivoActual = _cultivosSeleccionados[_cultivoActualIndex];
    final List<String> tiposSeleccionados =
        _tiposSeleccionadosPorCultivo[cultivoActual] ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10.0),
          child: Row(
            children: [
              Expanded(
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Selecciona el estado de las variedades de:',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              SizedBox(width: 10),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.grey[600], // Color fijo para el cultivo actual
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  cultivoActual,
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
              ),
            ],
          ),
        ),
        Divider(thickness: 1, color: Colors.grey[400]),
        SizedBox(height: 5),
        Align(
          alignment: Alignment.center,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 40, vertical: 5),
            decoration: BoxDecoration(
              color: Color(0xFF0BA37F), // Color verde fijo
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'Estados',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
        SizedBox(height: 1),
        Expanded(
          child: ListView(
            children: tiposSeleccionados.map((tipo) {
              return Column(
                children: [
                  Container(
                    width: double.infinity, // Asegurar misma anchura
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      color: Colors.grey[500], // Color del encabezado
                    ),
                    child: Column(
                      children: [
                        // ✅ Container con el nombre del tipo de cultivo
                        Container(
                          width: double.infinity,
                          padding: EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.grey[500], // Color del encabezado
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(15),
                              topRight: Radius.circular(15),
                            ),
                          ),
                          child: Center(
                            child: Text(
                              tipo,
                              style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white),
                            ),
                          ),
                        ),
                        // ✅ Container con los estados
                        Container(
                          width: double.infinity,
                          padding: EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.grey[200], // Fondo gris claro
                            borderRadius: BorderRadius.only(
                              bottomLeft: Radius.circular(15),
                              bottomRight: Radius.circular(15),
                            ),
                          ),
                          child: Wrap(
                            alignment: WrapAlignment.center,
                            spacing: 8,
                            runSpacing: 8,
                            children: estadosDisponibles.map((estado) {
                              final bool isSelected =
                                  _configuracionFinal[cultivoActual]?[tipo]
                                          ?['estado'] ==
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
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 10),
                ],
              );
            }).toList(),
          ),
        ),

        // ✅ Botones con validación en "Siguiente"
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ElevatedButton.icon(
                onPressed: () {
                  setState(() {
                    _currentStep--;
                  });
                },
                icon: Icon(Icons.arrow_back, color: Colors.white),
                label: Text('Atrás', style: TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF0BA37F),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _currentStep = 0; // Reiniciar todo
                    _cultivosSeleccionados.clear();
                    _tiposSeleccionadosPorCultivo.clear();
                    _configuracionFinal.clear();
                  });
                },
                child: Text('Cancelar', style: TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
              ElevatedButton.icon(
                onPressed: _todosTiposConEstadoSeleccionado(cultivoActual)
                    ? () {
                        if (_cultivoActualIndex <
                            _cultivosSeleccionados.length - 1) {
                          setState(() {
                            _cultivoActualIndex++;
                          });
                        } else {
                          setState(() {
                            _currentStep++;
                            _cultivoActualIndex = 0;
                          });
                        }
                      }
                    : null, // Deshabilitar si no están todos los estados
                icon: Icon(Icons.arrow_forward, color: Colors.white),
                label: Text('Siguiente', style: TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      _todosTiposConEstadoSeleccionado(cultivoActual)
                          ? Color(0xFF0BA37F)
                          : Colors.grey, // Cambiar color si está deshabilitado
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSeleccionEnfermedades(
      String cultivoActual, List<String> tiposEnfermos) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10.0),
          child: Row(
            children: [
              Expanded(
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Selecciona las enfermedades de las variedades de:',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              SizedBox(width: 10),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.grey[600],
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  cultivoActual,
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
              ),
            ],
          ),
        ),
        Divider(thickness: 1, color: Colors.grey[400]),
        SizedBox(height: 5),
        Align(
          alignment: Alignment.center,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 40, vertical: 5),
            decoration: BoxDecoration(
              color: Color(0xFF0BA37F), // Color verde fijo
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'Enfermedades',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
        SizedBox(height: 5),
        Expanded(
          child: ListView(
            children: tiposEnfermos.map((tipo) {
              _configuracionFinal.putIfAbsent(cultivoActual, () => {});
              _configuracionFinal[cultivoActual]!.putIfAbsent(tipo, () => {});
              _configuracionFinal[cultivoActual]![tipo]!
                  .putIfAbsent('enfermedades', () => <String>[]);

              final List<String> enfermedades =
                  (_configuracionFinal[cultivoActual]?[tipo]?['enfermedades']
                          as List<String>?) ??
                      [];

              return Column(
                children: [
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.grey[500],
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(15),
                        topRight: Radius.circular(15),
                      ),
                    ),
                    child: Center(
                      child: Text(
                        tipo,
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white),
                      ),
                    ),
                  ),
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(15),
                        bottomRight: Radius.circular(15),
                      ),
                    ),
                    child: Wrap(
                      alignment: WrapAlignment.center,
                      spacing: 8,
                      runSpacing: 8,
                      children: (enfermedadesPorCultivo[cultivoActual] ?? [])
                          .map((enfermedad) {
                        final bool isSelected =
                            enfermedades.contains(enfermedad);
                        return ChoiceChip(
                          label: Text(enfermedad),
                          selected: isSelected,
                          selectedColor: Colors.orange[100],
                          onSelected: (selected) {
                            setState(() {
                              if (selected) {
                                _configuracionFinal[cultivoActual]![tipo]![
                                    'enfermedades'] = [
                                  ...enfermedades,
                                  enfermedad
                                ];
                              } else {
                                _configuracionFinal[cultivoActual]![tipo]![
                                        'enfermedades'] =
                                    enfermedades
                                        .where((e) => e != enfermedad)
                                        .toList();
                              }
                            });
                          },
                        );
                      }).toList(),
                    ),
                  ),
                  SizedBox(height: 10),
                ],
              );
            }).toList(),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ElevatedButton.icon(
                onPressed: () {
                  setState(() {
                    _currentStep--;
                  });
                },
                icon: Icon(Icons.arrow_back, color: Colors.white),
                label: Text('Atrás', style: TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF0BA37F),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _currentStep = 0; // Reiniciar todo
                    _cultivosSeleccionados.clear();
                    _tiposSeleccionadosPorCultivo.clear();
                    _configuracionFinal.clear();
                  });
                },
                child: Text('Cancelar', style: TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
              ElevatedButton.icon(
                onPressed: () {
                  // ✅ Obtener la lista de cultivos seleccionados
                  String cultivoActual =
                      _cultivosSeleccionados[_cultivoActualIndex];

                  // ✅ Obtener los tipos con estado "Enfermo" dentro del cultivo actual
                  List<String> tiposEnfermos =
                      _tiposSeleccionadosPorCultivo[cultivoActual]!
                          .where((tipo) =>
                              _configuracionFinal[cultivoActual]?[tipo]
                                  ?['estado'] ==
                              'Enfermo')
                          .toList();

                  // ✅ Verificar si se puede avanzar (todas las variantes enfermas tienen enfermedades seleccionadas)
                  if (_sePuedeAvanzar(cultivoActual, tiposEnfermos)) {
                    if (_cultivoActualIndex <
                        _cultivosSeleccionados.length - 1) {
                      // ✅ Si hay más cultivos por procesar, avanzar al siguiente cultivo
                      setState(() {
                        _cultivoActualIndex++;
                      });
                    } else {
                      // ✅ Si ya se procesaron todos los cultivos, avanzar al informe final
                      setState(() {
                        _currentStep++;
                        _cultivoActualIndex = 0; // Reiniciar índice
                      });
                    }
                  }
                },
                icon: Icon(Icons.arrow_forward, color: Colors.white),
                label: Text('Siguiente', style: TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _sePuedeAvanzar(
                          _cultivosSeleccionados[_cultivoActualIndex],
                          _tiposSeleccionadosPorCultivo[
                                  _cultivosSeleccionados[_cultivoActualIndex]]!
                              .where((tipo) =>
                                  _configuracionFinal[_cultivosSeleccionados[
                                      _cultivoActualIndex]]?[tipo]?['estado'] ==
                                  'Enfermo')
                              .toList())
                      ? Color(0xFF0BA37F) // Activo
                      : Colors
                          .grey, // Inactivo si falta seleccionar enfermedades
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              )
            ],
          ),
        ),
      ],
    );
  }

  /// 🔹 Función para verificar si se puede avanzar
  bool _sePuedeAvanzar(String cultivoActual, List<String> tiposEnfermos) {
    for (String tipo in tiposEnfermos) {
      final List<String> enfermedadesSeleccionadas =
          (_configuracionFinal[cultivoActual]?[tipo]?['enfermedades']
                  as List<String>?) ??
              [];
      if (enfermedadesSeleccionadas.isEmpty) {
        return false; // Si hay un tipo sin enfermedades, no se puede avanzar
      }
    }
    return true;
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
    if (_cultivoActualIndex < _cultivosSeleccionados.length) {
      String cultivoActual = _cultivosSeleccionados[_cultivoActualIndex];
      List<String> tiposCultivo =
          _tiposSeleccionadosPorCultivo[cultivoActual] ?? [];

      // 🔹 Filtrar solo los tipos de cultivo con estado "Enfermo"
      List<String> tiposEnfermos = tiposCultivo.where((tipo) {
        String estado =
            _configuracionFinal[cultivoActual]?[tipo]?['estado'] ?? '';
        return estado == "Enfermo"; // "Mixto" ya no se incluye aquí
      }).toList();

      if (tiposEnfermos.isNotEmpty) {
        return _buildSeleccionEnfermedades(cultivoActual, tiposEnfermos);
      } else {
        // Si no hay más tipos con enfermedad en este cultivo, avanzar al siguiente cultivo
        _cultivoActualIndex++;
        return _procesarSeleccionEnfermedades();
      }
    }

    // Si ya no hay más cultivos con tipos enfermos, ir al resumen
    return _buildResumenFinal();
  }

  void _guardarConfiguracion(String cultivoActual, String tipoActual) {
    if (_estadoSeleccionado.isNotEmpty) {
      _configuracionFinal.putIfAbsent(cultivoActual, () => {});
      _configuracionFinal[cultivoActual]!.putIfAbsent(tipoActual, () => {});

      _configuracionFinal[cultivoActual]![tipoActual]['estado'] =
          _estadoSeleccionado;

      // ✅ Si el estado es "Con enfermedad", asegurarse de inicializar la lista de enfermedades
      if (_estadoSeleccionado == "Enfermo") {
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
        // ✅ Texto de instrucción dentro de un botón decorativo
        Container(
          alignment: Alignment.center,
          margin: EdgeInsets.symmetric(vertical: 10),
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.grey[300], // Fondo gris claro como en la imagen
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            'Selecciona los cultivos',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
        ),

        // ✅ Lista de cultivos alineados a la izquierda
        Align(
          alignment:
              Alignment.centerLeft, // Cambio aquí para alinear a la izquierda
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: cultivosDisponibles.map((cultivo) {
              final isSelected = _cultivosSeleccionados.contains(cultivo);
              return GestureDetector(
                onTap: () {
                  setState(() {
                    if (isSelected) {
                      _cultivosSeleccionados.remove(cultivo);
                      _tiposSeleccionadosPorCultivo.remove(cultivo);
                    } else if (_cultivosSeleccionados.length < 5) {
                      _cultivosSeleccionados.add(cultivo);
                      _tiposSeleccionadosPorCultivo[cultivo] = [];
                    }
                  });
                },
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: isSelected ? Colors.green : Colors.grey,
                      width: isSelected ? 2 : 1,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    color: isSelected ? Colors.green[100] : Colors.white,
                  ),
                  child: Text(
                    cultivo,
                    style: TextStyle(
                      fontSize: 16,
                      color: isSelected ? Colors.green[900] : Colors.black,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),

        Spacer(),

        // ✅ Botones de navegación alineados al pie de la pantalla con texto en blanco
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: Icon(Icons.arrow_back, size: 18, color: Colors.white),
              label: Text(
                'Atrás',
                style: TextStyle(color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color.fromARGB(255, 170, 126, 4),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
            ElevatedButton.icon(
              onPressed: _cultivosSeleccionados.isNotEmpty
                  ? () {
                      setState(() {
                        _currentStep++;
                      });
                    }
                  : null, // Deshabilita si no hay selección
              icon: Icon(Icons.arrow_forward, size: 18, color: Colors.white),
              label: Text(
                'Siguiente',
                style: TextStyle(color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF0BA37F),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
