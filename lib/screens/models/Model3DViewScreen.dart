import 'package:flutter/material.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';

class Model3DViewScreen extends StatelessWidget {
  final String modelUrl;

  Model3DViewScreen({required this.modelUrl});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Vista 3D del Modelo'),
      ),
      body: ModelViewer(
        src: modelUrl, // La URL del modelo 3D
        ar: false,
        autoRotate: true,
        cameraControls: true,
      ),
    );
  }
}