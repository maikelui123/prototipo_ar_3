import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '/services/ocr_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/Model3DViewScreen.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:lottie/lottie.dart';
import 'package:url_launcher/url_launcher.dart';

class OCRScreen extends StatefulWidget {
  @override
  _OCRScreenState createState() => _OCRScreenState();
}

class _OCRScreenState extends State<OCRScreen> {
  final OCRService ocrService = OCRService();
  String _text = "";
  bool _isLoading = false;
  final FlutterTts flutterTts = FlutterTts();
  bool isSpeaking = false; // Controla si se está reproduciendo la voz

  @override
  void initState() {
    super.initState();
    _initTts();
  }

  void _initTts() {
    flutterTts.setLanguage("es-ES");
    flutterTts.setSpeechRate(0.6);
    flutterTts.setVolume(1.0);
    flutterTts.setPitch(1.0);

    flutterTts.setCompletionHandler(() {
      setState(() {
        isSpeaking = false; // Restablece el estado cuando la voz termina de reproducirse
      });
    });
  }

  Future<void> _toggleSpeech(String text) async {
    if (isSpeaking) {
      // Si ya se está reproduciendo, detener la voz
      await flutterTts.stop();
      setState(() {
        isSpeaking = false;
      });
    } else {
      // Si no se está reproduciendo, iniciar la voz
      setState(() {
        isSpeaking = true;
      });
      await flutterTts.speak(text);
    }
  }

  Future<void> _getImageAndDetectText() async {
    setState(() {
      _isLoading = true;
    });

    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      final File imageFile = File(pickedFile.path);
      String text = await ocrService.detectText(imageFile);
      _processText(text);
    } else {
      print('No image selected.');
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _processText(String text) {
    setState(() {
      _text = text;
    });

    _fetchDynamicData(text);
  }

  void _fetchDynamicData(String text) async {
    try {
      // Extraer palabras clave
      List<String> keywords = text
          .split(RegExp(r'\s+'))
          .where((word) => word.trim().isNotEmpty)
          .map((e) => e.toLowerCase())
          .toList();

      // Buscar en Firestore las recomendaciones basadas en palabras clave
      var result = await FirebaseFirestore.instance
          .collection('componentesPC')
          .where('palabrasClave', arrayContainsAny: keywords)
          .get();

      if (result.docs.isNotEmpty) {
        // Manejar los datos obtenidos y mostrar recomendaciones
        _showResultsDialog(result.docs);
      } else {
        _showNoResultsDialog();
      }
    } catch (e) {
      _showErrorDialog(e.toString());
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showResultsDialog(List<QueryDocumentSnapshot> docs) {
    List<Widget> recommendations = [];

    // Procesar los resultados de Firestore
    docs.forEach((doc) {
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

      // Agregar recomendaciones dinámicas
      recommendations.add(
        Card(
          margin: EdgeInsets.symmetric(vertical: 8),
          elevation: 5,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          child: ListTile(
            leading: data['imagen_url'] != null
                ? Image.network(data['imagen_url'], width: 50, height: 50, fit: BoxFit.cover)
                : null,
            title: Text(
              data['nombre'] ?? '',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(data['descripcion'] ?? ''),
            trailing: IconButton(
              icon: Icon(Icons.threed_rotation, color: Colors.blue),
              onPressed: () {
                Navigator.of(context).pop(); // Cierra el diálogo actual
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => Model3DViewScreen(modelUrl: data['modelo3D_url']),
                ));
              },
            ),
          ),
        ),
      );
    });

    // Mostrar los resultados en un diálogo
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Resultados de OCR'),
          content: Container(
            width: double.maxFinite,
            child: ListView(
              shrinkWrap: true,
              children: recommendations,
            ),
          ),
          actions: [
            TextButton(
              child: Text('Cerrar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _showNoResultsDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Sin resultados'),
          content: Text('No se encontró información relacionada con el texto detectado.'),
          actions: [
            TextButton(
              child: Text('Cerrar'),
              onPressed: () {
                Navigator.of(context).pop();
                setState(() {
                  _isLoading = false;
                });
              },
            ),
          ],
        );
      },
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Error'),
          content: Text(message),
          actions: [
            TextButton(
              child: Text('Cerrar'),
              onPressed: () {
                Navigator.of(context).pop();
                setState(() {
                  _isLoading = false;
                });
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final Color customAppBarColor = Color(0xFF42F5EC);
    Color lightBlue = Colors.lightBlue.shade100;
    Color darkBlue = Colors.blue.shade400;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Reconocimiento de Texto (OCR)',
          style: TextStyle(
            color: Colors.white, // Cambia el color del texto para mejor contraste
            fontWeight: FontWeight.bold, // Hace el texto más grueso
            fontSize: 20, // Aumenta el tamaño de la letra
          ),
        ),
        backgroundColor: customAppBarColor, // Usar el color personalizado
        elevation: 10, // Añade sombra a la AppBar para un efecto 3D
      ),
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [lightBlue, darkBlue],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: _isLoading
            ? Center(child: CircularProgressIndicator())
            : Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Lottie.asset('assets/OCR.json', width: 200, height: 200),
                    SizedBox(height: 20),
                    Text(
                      'Texto detectado:',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      _text.isNotEmpty ? _text : 'No se ha detectado texto aún.',
                      style: TextStyle(fontSize: 18, color: Colors.black),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(vertical: 16.0),
              child: ElevatedButton.icon(
                onPressed: _getImageAndDetectText,
                icon: Icon(Icons.camera_alt),
                label: Text('Tomar Foto'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: darkBlue,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                  textStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _toggleSpeech(
            "Esta pantalla te permite escanear texto de una imagen y buscar palabras clave relevantes en la base de datos. Toca el botón de 'Tomar Foto' para comenzar.",
          );
        },
        tooltip: 'Información de Voz',
        backgroundColor: customAppBarColor,
        child: Icon(Icons.volume_up),
      ),
    );
  }

  @override
  void dispose() {
    flutterTts.stop();
    super.dispose();
  }
}
