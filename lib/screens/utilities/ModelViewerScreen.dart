import 'package:flutter/material.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';

class ModelViewerScreen extends StatelessWidget {
  final String modelPath;
  final String title;

  ModelViewerScreen({required this.modelPath, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          title,
          style: TextStyle(
            color: Colors.lightBlue,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        backgroundColor: Color(0xFF42F5EC),
      ),
      body: Stack(
        children: [
          // Modelo 3D Interactivo
          Positioned.fill(
            child: ModelViewer(
              src: modelPath, // Ruta del modelo 3D
              alt: "Modelo 3D de $title",
              ar: false,
              autoRotate: true,
              cameraControls: true,
              backgroundColor: Colors.white,
            ),
          ),
          // Marcadores personalizados
          ..._generateMarkers(context),
        ],
      ),
    );
  }

  // Método para generar marcadores personalizados
  List<Widget> _generateMarkers(BuildContext context) {
    // Ejemplo de ubicaciones específicas para cada modelo
    List<Map<String, dynamic>> markers = [];

    if (title == "RAM") {
      markers = [
        {"top": 200.0, "left": 150.0, "message": "Conecta con cuidado para no dañar los pines."},
        {"top": 300.0, "left": 250.0, "message": "No manipules sin una pulsera antiestática."},
        {"top": 250.0, "left": 100.0, "message": "Evita tocar la parte metálica con las manos."},
        {"top": 350.0, "left": 300.0, "message": "Asegúrate de que esté bien alineada antes de instalar."},
      ];
    } else if (title == "CPU") {
      markers = [
        {"top": 150.0, "left": 180.0, "message": "Asegúrate de limpiar la pasta térmica antes de instalar."},
        {"top": 350.0, "left": 220.0, "message": "No toques los pines dorados directamente."},
        {"top": 300.0, "left": 150.0, "message": "Instala el disipador de calor correctamente."},
        {"top": 400.0, "left": 250.0, "message": "Verifica que el socket esté desbloqueado antes de insertar."},
      ];
    } else if (title == "Motherboard") {
      markers = [
        {"top": 250.0, "left": 200.0, "message": "Evita tocar los circuitos con las manos desnudas."},
        {"top": 400.0, "left": 300.0, "message": "Asegúrate de conectar todos los cables correctamente."},
        {"top": 200.0, "left": 100.0, "message": "Verifica la posición de los puertos antes de ensamblar."},
        {"top": 300.0, "left": 250.0, "message": "Revisa las conexiones del panel frontal."},
        {"top": 350.0, "left": 150.0, "message": "Comprueba que los módulos RAM estén firmemente instalados."},
      ];
    }

    return markers.map((marker) {
      return Positioned(
        top: marker["top"],
        left: marker["left"],
        child: GestureDetector(
          onTap: () {
            _showAlert(context, marker["message"]);
          },
          child: Icon(
            Icons.warning,
            color: Colors.red,
            size: 40,
          ),
        ),
      );
    }).toList();
  }

  // Método para mostrar Alertas
  void _showAlert(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Medida de Seguridad'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: Text('Aceptar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
