import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Import necesario
import '../utilities/ARViewScreen.dart';
import 'package:flutter_tts/flutter_tts.dart';

// Función para registrar la actividad (igual que en OCRScreen y ModelDetailScreen)
void logActivity(String userId, String screenName) async {
  try {
    // Obtener datos del usuario desde la colección 'users'
    DocumentSnapshot userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .get();

    if (userDoc.exists) {
      Map<String, dynamic>? userData = userDoc.data() as Map<String, dynamic>?;

      // Registrar la actividad con datos adicionales
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

class ModelsGalleryScreen extends StatefulWidget {
  @override
  _ModelsGalleryScreenState createState() => _ModelsGalleryScreenState();
}

class _ModelsGalleryScreenState extends State<ModelsGalleryScreen> {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final FlutterTts flutterTts = FlutterTts();
  bool isSpeaking = false; // Controla si se está reproduciendo la voz

  @override
  void initState() {
    super.initState();
    _initTts();

    // Obtiene el usuario actual y registra su actividad
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      logActivity(user.uid, 'Galeria De Modelo'); // Registrar la visita
    }
  }

  void _initTts() {
    flutterTts.setLanguage("es-ES");
    flutterTts.setSpeechRate(0.6);
    flutterTts.setVolume(1.0);
    flutterTts.setPitch(1.0);

    flutterTts.setCompletionHandler(() {
      setState(() {
        isSpeaking = false;
      });
    });
  }

  Future<void> _toggleSpeech(String text) async {
    if (isSpeaking) {
      await flutterTts.stop();
      setState(() {
        isSpeaking = false;
      });
    } else {
      setState(() {
        isSpeaking = true;
      });
      await flutterTts.speak(text);
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color customAppBarColor = Color(0xFF42F5EC);
    Color lightBlue = Colors.lightBlue.shade100;
    Color darkBlue = Colors.blue.shade400;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Galería de Modelos 3D',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        backgroundColor: customAppBarColor,
        elevation: 10,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [lightBlue, darkBlue],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: StreamBuilder(
          stream: firestore.collection('componentesPC').snapshots(),
          builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.hasError) {
              return Center(child: Text('Error al cargar los modelos'));
            }
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }
            var models = snapshot.data!.docs;

            return GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, // Número de columnas
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemCount: models.length,
              itemBuilder: (context, index) {
                var model = models[index].data() as Map<String, dynamic>;

                return Card(
                  elevation: 5,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  child: InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ARViewScreen(modelUrl: model['modelo3D_url']),
                        ),
                      );
                    },
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(
                          child: Image.network(model['imagen_url'], fit: BoxFit.cover),
                        ),
                        Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text(
                            model['nombre'],
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: darkBlue,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _toggleSpeech(
            "En esta pantalla puedes explorar una variedad de modelos 3D. Cada tarjeta muestra la imagen y el nombre de un modelo 3D diferente. Toca una tarjeta para ver el modelo en detalle y explorarlo en realidad aumentada.",
          );
        },
        child: Icon(Icons.volume_up),
        backgroundColor: customAppBarColor,
      ),
    );
  }

  @override
  void dispose() {
    flutterTts.stop();
    super.dispose();
  }
}
