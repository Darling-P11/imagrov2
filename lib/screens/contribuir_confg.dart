import 'package:flutter/material.dart';

class ConfiguracionContribucionScreen extends StatefulWidget {
  @override
  _ConfiguracionContribucionScreenState createState() =>
      _ConfiguracionContribucionScreenState();
}

class _ConfiguracionContribucionScreenState
    extends State<ConfiguracionContribucionScreen> {
  int _cantidadCultivos = 1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Configurar Contribución'),
        backgroundColor: Color(0xFF0BA37F),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Cantidad de Cultivos
              Text(
                '¿Cuántos cultivos deseas clasificar?',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Slider(
                value: _cantidadCultivos.toDouble(),
                min: 1,
                max: 5,
                divisions: 4,
                label: '$_cantidadCultivos',
                onChanged: (value) {
                  setState(() {
                    _cantidadCultivos = value.toInt();
                  });
                },
              ),
              SizedBox(height: 20),

              // Selección de Cultivos
              Text(
                'Selecciona los cultivos:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _buildCultivoChip('Cacao'),
                  _buildCultivoChip('Yuca'),
                  _buildCultivoChip('Papaya'),
                  _buildCultivoChip('Verde'),
                  ElevatedButton.icon(
                    onPressed: () {},
                    icon: Icon(Icons.add),
                    label: Text('Añadir cultivo'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                      side: BorderSide(color: Colors.black),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),

              // Tipo de Cultivo
              Text(
                'Selecciona el tipo de cultivo:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _buildTipoChip('Nacional'),
                  _buildTipoChip('CCN-51'),
                  _buildTipoChip('Cacao Ramilla'),
                  _buildTipoChip('Generalizar'),
                ],
              ),
              SizedBox(height: 20),

              // Estado del Producto
              Text(
                'Selecciona el estado del producto:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildEstadoButton('Natural', Icons.eco),
                  _buildEstadoButton('Con enfermedad', Icons.warning),
                  _buildEstadoButton('Generalizar', Icons.layers),
                ],
              ),
              SizedBox(height: 20),

              // Selección de Enfermedades
              Text(
                'Selecciona las enfermedades:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _buildEnfermedadChip('Moniliasis'),
                  _buildEnfermedadChip('Pudrición'),
                  _buildEnfermedadChip('Mancha'),
                  _buildEnfermedadChip('Generalizar'),
                  ElevatedButton.icon(
                    onPressed: () {},
                    icon: Icon(Icons.add),
                    label: Text('Añadir enfermedad'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                      side: BorderSide(color: Colors.black),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 30),

              // Botones de acción
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text('Cancelar'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      // Acción para guardar configuraciones
                    },
                    child: Text('Guardar y continuar'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF0BA37F),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCultivoChip(String label) {
    return Chip(
      label: Text(label),
      backgroundColor: Colors.green[100],
    );
  }

  Widget _buildTipoChip(String label) {
    return Chip(
      label: Text(label),
      backgroundColor: Colors.blue[100],
    );
  }

  Widget _buildEstadoButton(String label, IconData icon) {
    return ElevatedButton.icon(
      onPressed: () {},
      icon: Icon(icon),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.green[100],
        foregroundColor: Colors.black,
      ),
    );
  }

  Widget _buildEnfermedadChip(String label) {
    return Chip(
      label: Text(label),
      backgroundColor: Colors.orange[100],
    );
  }
}
