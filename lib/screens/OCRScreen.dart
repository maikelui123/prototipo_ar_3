import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '/services/ocr_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class OCRScreen extends StatefulWidget {
  @override
  _OCRScreenState createState() => _OCRScreenState();
}

class _OCRScreenState extends State<OCRScreen> {
  final OCRService ocrService = OCRService();
  String _text = "";
  List<String> _words = [];
  String _selectedKeyword = "";
  final picker = ImagePicker();
  bool _isLoading = false;

  Future<void> _getImageAndDetectText() async {
    setState(() {
      _isLoading = true;
    });

    final pickedFile = await picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      final File imageFile = File(pickedFile.path);
      String text = await ocrService.detectText(imageFile);
      _processText(text);
    } else {
      print('No image selected.');
    }

    setState(() {
      _isLoading = false;
    });
  }

  void _processText(String text) {
    setState(() {
      _text = text;
      _words = text.split(RegExp(r'\s+')).where((word) => word.trim().isNotEmpty).toList();
    });
  }

  void _searchInFirestore(String keyword) async {
    try {
      // Realizar la búsqueda en Firestore en la colección deseada.
      var result = await FirebaseFirestore.instance
          .collection('componentesPC') // Reemplaza con el nombre de tu colección
          .where('palabrasClave', arrayContains: keyword.toLowerCase()) // Suponiendo que las palabras clave están en minúsculas
          .get();

      if (result.docs.isNotEmpty) {
        // Encontramos documentos, podemos pasarlos a otra pantalla o mostrar un diálogo
        var data = result.docs.first.data();
        _showDialogWithFirestoreData(data);
      } else {
        // No se encontraron documentos
        _showNoResultsDialog();
      }
    } catch (e) {
      // Manejar errores, por ejemplo, mostrando un diálogo con el mensaje de error
      _showErrorDialog(e.toString());
    }
  }

  void _showDialogWithFirestoreData(Map<String, dynamic> data) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(data['nombre'] ?? 'Sin título'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(data['descripcion'] ?? 'Sin descripción'),
                Image.network(data['imagen_url'] ?? 'https://via.placeholder.com/150'),
                // Aquí podrías incluir un enlace o botón para abrir la URL del modelo 3D.
              ],
            ),
          ),
          actions: <Widget>[
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
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('No se encontraron resultados'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('No se encontró ningún documento con esa palabra clave.'),
              ],
            ),
          ),
          actions: <Widget>[
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

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Error'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(message),
              ],
            ),
          ),
          actions: <Widget>[
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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('OCR y Selección de Palabra Clave'),
        backgroundColor: Colors.deepPurple,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.deepPurple.shade400, Colors.deepPurple.shade600],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              if (_isLoading)
                LinearProgressIndicator(
                  backgroundColor: Colors.deepPurple.shade300,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              SizedBox(height: 20),
              Text(
                'Selecciona la palabra clave detectada:',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 20),
              Wrap(
                spacing: 8.0,
                runSpacing: 4.0,
                children: _words.map((word) => ChoiceChip(
                  label: Text(word),
                  labelStyle: TextStyle(color: Colors.white),
                  selected: _selectedKeyword == word,
                  selectedColor: Colors.deepPurple.shade700,
                  onSelected: (selected) {
                    setState(() {
                      _selectedKeyword = word;
                    });
                  },
                )).toList(),
              ),
              SizedBox(height: 20),
              _selectedKeyword.isNotEmpty
                  ? ElevatedButton(
                onPressed: () => _searchInFirestore(_selectedKeyword),
                child: Text('Buscar "$_selectedKeyword" en Firestore'),
                style: ElevatedButton.styleFrom(
                  primary: Colors.deepPurple.shade800,
                ),
              )
                  : Container(),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _getImageAndDetectText,
        tooltip: 'Tomar Imagen',
        backgroundColor: Colors.deepPurple.shade700,
        child: Icon(Icons.camera_alt),
      ),
    );
  }
}
