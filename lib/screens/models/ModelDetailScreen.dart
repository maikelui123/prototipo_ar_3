import 'package:flutter/material.dart';
import 'package:babylonjs_viewer/babylonjs_viewer.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import '../../services/file_service.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../../services/LocalHttpServer.dart'; // Importa el servidor local

void logActivity(String userId, String screenName) async {
  try {
    DocumentSnapshot userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .get();

    if (userDoc.exists) {
      Map<String, dynamic>? userData = userDoc.data() as Map<String, dynamic>?;

      await FirebaseFirestore.instance.collection('activity_logs').add({
        'userId': userId,
        'screenName': screenName,
        'timestamp': FieldValue.serverTimestamp(),
        'userName': userData?['firstName'] ?? 'Usuario desconocido',
        'role': userData?['role'] ?? 'Sin rol',
      });
    } else {
      print('El usuario no existe en la colección "users".');
    }
  } catch (e) {
    print('Error registrando la actividad: $e');
  }
}

class ModelDetailScreen extends StatefulWidget {
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
  _ModelDetailScreenState createState() => _ModelDetailScreenState();
}

class _ModelDetailScreenState extends State<ModelDetailScreen> {
  String? localModelPath;
  bool isLoading = true;
  double downloadProgress = 0.0; // Progreso de la descarga

  @override
  void initState() {
    super.initState();
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      logActivity(user.uid, 'Detalles de Modelo');
    }
    _loadModel();
  }

  Future<void> _loadModel() async {
    try {
      final fileName = widget.model3DUrl.split('/').last;
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
            widget.model3DUrl,
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
      print('Error al cargar el modelo: $e');
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudo cargar el modelo. Verifica tu conexión.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    Color lightBlue = Colors.lightBlue.shade100;
    Color darkBlue = Colors.blue.shade400;

    String? localUrl;
    if (localModelPath != null) {
      final fileName = localModelPath!.split('/').last;
      localUrl = LocalHttpServer.getFileUrl(fileName);
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Detalles del Modelo', style: TextStyle(color: lightBlue)),
        backgroundColor: darkBlue,
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
          : SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AspectRatio(
              aspectRatio: 16 / 9,
              child: localModelPath == null
                  ? Center(child: Text('No se pudo cargar el modelo.'))
                  : BabylonJSViewer(
                src: localUrl!, // Aquí usamos la URL del servidor local
              ),
            ),
            SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                widget.nombre,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: darkBlue,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
              child: Text(
                widget.informacionModelo,
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
