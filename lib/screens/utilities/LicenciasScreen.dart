import 'package:flutter/material.dart';

class LicenciasScreen extends StatefulWidget {
  @override
  _LicenciasScreenState createState() => _LicenciasScreenState();
}

class _LicenciasScreenState extends State<LicenciasScreen> {
  // Paso 1: Lista de licencias
  final List<Map<String, String>> licencias = [
    {
      "nombre": "GPL",
      "descripcion":
      "La Licencia Pública General (GPL) es una licencia de software libre que garantiza que los usuarios finales puedan ejecutar, estudiar, compartir y modificar el software.",
    },
    {
      "nombre": "MIT",
      "descripcion":
      "La licencia MIT es una licencia permisiva que permite un amplio uso del software con pocas restricciones.",
    },
    {
      "nombre": "Apache 2.0",
      "descripcion":
      "La licencia Apache permite el uso, modificación y distribución del software con condiciones como la atribución y no usar marcas comerciales.",
    },
    {
      "nombre": "BSD",
      "descripcion":
      "La licencia BSD es una licencia permisiva que otorga libertad para usar, modificar y distribuir software con mínimas restricciones.",
    },
    // Puedes agregar más licencias aquí si lo deseas
  ];

  String? licenciaSeleccionada;

  // Paso 2: Método para mostrar detalles de la licencia en un diálogo
  void _mostrarDetalleLicencia(BuildContext context, Map<String, String> licencia) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(licencia['nombre']!),
          content: SingleChildScrollView(
            child: Text(licencia['descripcion']!),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("Cerrar"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Definir colores personalizados (opcional)
    final Color customAppBarColor = Color(0xFF42F5EC);
    Color lightBlue = Colors.lightBlue.shade100;
    Color darkBlue = Colors.blue.shade400;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Licencias de Software",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        backgroundColor: customAppBarColor,
        elevation: 4,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Selecciona una licencia para ver los detalles:",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            SizedBox(height: 16),
            DropdownButton<String>(
              value: licenciaSeleccionada,
              hint: Text("Selecciona una licencia"),
              isExpanded: true,
              items: licencias.map((licencia) {
                return DropdownMenuItem<String>(
                  value: licencia['nombre'],
                  child: Text(licencia['nombre']!),
                );
              }).toList(),
              onChanged: (String? nuevaLicencia) {
                setState(() {
                  licenciaSeleccionada = nuevaLicencia;
                });
                final licencia = licencias.firstWhere(
                        (lic) => lic['nombre'] == nuevaLicencia,
                    orElse: () => licencias[0]); // Fallback en caso de no encontrar
                _mostrarDetalleLicencia(context, licencia);
              },
            ),
            SizedBox(height: 24),
            // Opcional: Lista de todas las licencias con botones para ver detalles
            Expanded(
              child: ListView.builder(
                itemCount: licencias.length,
                itemBuilder: (context, index) {
                  final licencia = licencias[index];
                  return Card(
                    elevation: 3,
                    margin: EdgeInsets.symmetric(vertical: 8.0),
                    child: ListTile(
                      title: Text(
                        licencia['nombre']!,
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        licencia['descripcion']!,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      trailing: Icon(Icons.info_outline, color: customAppBarColor),
                      onTap: () => _mostrarDetalleLicencia(context, licencia),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
