import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../utilities/ARViewScreen.dart';
import 'package:flutter_tts/flutter_tts.dart';

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
            color: Colors.white, // Cambia el color del texto para mejor contraste
            fontWeight: FontWeight.bold, // Hace el texto más grueso
            fontSize: 20, // Aumenta el tamaño de la letra
          ),
        ),
        backgroundColor: customAppBarColor, // Usar el color personalizado
        elevation: 10, // Añade sombra a la AppBar para un efecto 3D
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
                crossAxisSpacing: 10, // Espaciado horizontal
                mainAxisSpacing: 10, // Espaciado vertical
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
