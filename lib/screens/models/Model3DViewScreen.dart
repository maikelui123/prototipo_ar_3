import 'package:flutter/material.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import '../../services/file_service.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../../services/LocalHttpServer.dart'; // Importa la clase del servidor local

class Model3DViewScreen extends StatefulWidget {
  final String modelUrl;

  Model3DViewScreen({required this.modelUrl});

  @override
  _Model3DViewScreenState createState() => _Model3DViewScreenState();
}

class _Model3DViewScreenState extends State<Model3DViewScreen> {
  String? localModelPath;
  bool isLoading = true;
  double downloadProgress = 0.0;

  @override
  void initState() {
    super.initState();
    _loadModel();
  }

  Future<void> _loadModel() async {
    try {
      final fileName = widget.modelUrl.split('/').last;
      final fileService = FileService();

      final directory = await getApplicationDocumentsDirectory();
      final filePath = '${directory.path}/$fileName';
      final file = File(filePath);

      if (await file.exists()) {
        setState(() {
          localModelPath = filePath;
          isLoading = false;
        });
      } else {
        var connectivityResult = await (Connectivity().checkConnectivity());
        if (connectivityResult == ConnectivityResult.none) {
          throw Exception('No hay conexión a Internet para descargar el modelo.');
        } else {
          final path = await fileService.downloadModel(
            widget.modelUrl,
            fileName,
                (progress) {
              setState(() {
                downloadProgress = progress;
              });
            },
          );

          setState(() {
            localModelPath = path;
            isLoading = false;
          });
        }
      }
    } catch (e) {
      print('Error al cargar modelo en Model3DViewScreen: $e');
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('No se pudo cargar el modelo. Verifica tu conexión.'))
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    String? localUrl;
    if (localModelPath != null) {
      final fileName = localModelPath!.split('/').last;
      localUrl = LocalHttpServer.getFileUrl(fileName); // Obtiene la URL local
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Vista 3D del Modelo'),
      ),
      body: isLoading
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(value: downloadProgress),
            SizedBox(height: 16),
            Text('Descargando modelo... ${(downloadProgress * 100).toStringAsFixed(0)}%'),
          ],
        ),
      )
          : localModelPath == null
          ? Center(child: Text('No se pudo cargar el modelo.'))
          : ModelViewer(
        src: localUrl!, // Usa la URL del servidor local interno
        ar: false,
        autoRotate: true,
        cameraControls: true,
      ),
    );
  }
}
