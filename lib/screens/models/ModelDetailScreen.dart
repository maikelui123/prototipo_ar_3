import 'package:flutter/material.dart';
import 'package:babylonjs_viewer/babylonjs_viewer.dart';

class ModelDetailScreen extends StatelessWidget {
  final String nombre;
  final String informacionModelo;
  final String model3DUrl;

  ModelDetailScreen({
    Key? key,
    required this.nombre,
    required this.informacionModelo,
    required this.model3DUrl,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Colores personalizados
    Color lightBlue = Colors.lightBlue.shade100;
    Color darkBlue = Colors.blue.shade400;

    return Scaffold(
      appBar: AppBar(
        title: Text('Detalles del Modelo', style: TextStyle(color: lightBlue)),
        backgroundColor: darkBlue,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Vista previa del modelo 3D
            AspectRatio(
              aspectRatio: 16 / 9,
              child: BabylonJSViewer(
                src: model3DUrl, // Asegúrate de que la URL es accesible y correcta
              ),
            ),
            // Espaciado
            SizedBox(height: 16),
            // Nombre del Modelo
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                nombre,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: darkBlue,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            // Descripción del Modelo
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
              child: Text(
                informacionModelo,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.justify,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
