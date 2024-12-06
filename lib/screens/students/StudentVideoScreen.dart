// screens/students/StudentVideoScreen.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_tts/flutter_tts.dart';

class StudentVideoScreen extends StatefulWidget {
  @override
  _StudentVideoScreenState createState() => _StudentVideoScreenState();
}

class _StudentVideoScreenState extends State<StudentVideoScreen> {
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

    flutterTts.setErrorHandler((msg) {
      setState(() {
        isSpeaking = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error en TTS: $msg')),
      );
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
  void dispose() {
    flutterTts.stop();
    super.dispose();
  }

  void _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudo abrir la URL')),
      );
    }
  }

  String? extractYoutubeId(String url) {
    RegExp regExp = RegExp(
      r"^(?:https?:\/\/)?(?:www\.)?(?:youtube\.com\/watch\?v=|youtu\.be\/)([^\s&]+)",
      caseSensitive: false,
      multiLine: false,
    );
    Match? match = regExp.firstMatch(url);
    return match != null ? match.group(1) : null;
  }

  Widget _buildVideoCard(DocumentSnapshot doc) {
    Map<String, dynamic> videoData = doc.data() as Map<String, dynamic>;
    String title = videoData['title'] ?? 'Sin título';
    String url = videoData['url'] ?? '';
    String? videoId = extractYoutubeId(url);

    String thumbnailUrl = videoId != null
        ? 'https://img.youtube.com/vi/$videoId/0.jpg'
        : 'https://via.placeholder.com/150';

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Thumbnail del video
          GestureDetector(
            onTap: () => _launchURL(url),
            child: ClipRRect(
              borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
              child: Image.network(
                thumbnailUrl,
                height: 150,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  height: 150,
                  color: Colors.grey[200],
                  child: Icon(Icons.broken_image, size: 50, color: Colors.grey),
                ),
              ),
            ),
          ),
          // Información del video
          Padding(
            padding: EdgeInsets.all(12.0),
            child: Column(
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade700,
                  ),
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis, // Agrega puntos suspensivos para texto largo
                  maxLines: 2, // Limita a 2 líneas
                ),
                SizedBox(height: 4),
                Text(
                  url,
                  style: TextStyle(
                    color: Colors.blue.shade600,
                  ),
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
                SizedBox(height: 12),
                ElevatedButton.icon(
                  onPressed: () => _launchURL(url),
                  icon: Icon(Icons.play_circle_fill, color: Colors.white),
                  label: Text('Reproducir Video'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue, // Color del botón
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVideoList() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('youtubeVideos').orderBy('title').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Error al cargar los videos'));
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator(color: Colors.blue));
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(
            child: Text(
              'No hay videos disponibles',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          );
        }

        return ListView.builder(
          padding: EdgeInsets.only(bottom: 80), // Espacio para el FloatingActionButton
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            return _buildVideoCard(snapshot.data!.docs[index]);
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final Color customAppBarColor = Color(0xFF42F5EC);
    final Color backgroundColor = Colors.white;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Videos Educativos',
          style: TextStyle(
            color: Colors.white, // Mejor contraste
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        backgroundColor: customAppBarColor,
        elevation: 10,
        centerTitle: true,
      ),
      body: SafeArea( // Evita superposiciones con la barra de estado y otras áreas
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.lightBlue.shade100, Colors.blue.shade400],
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
            ),
          ),
          child: _buildVideoList(),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          _toggleSpeech(
            "En esta pantalla puedes encontrar una variedad de videos educativos centrados en los fundamentos de hardware y software. Explora los diferentes videos disponibles y selecciona cualquiera para obtener más información y ampliar tus conocimientos en el área.",
          );
        },
        label: Text(isSpeaking ? 'Detener Narración' : 'Escuchar Descripción'),
        icon: Icon(isSpeaking ? Icons.stop : Icons.volume_up),
        backgroundColor: customAppBarColor,
        tooltip: 'Descripción de la Pantalla',
      ),
    );
  }
}
