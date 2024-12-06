import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../services/auth_service.dart';
import '../../services/music_service.dart';
import 'OCRScreen.dart';
import '../models/ModelInfoScreen.dart';
import '../models/ModelsGalleryScreen.dart';
import 'ForosScreen.dart';
import 'package:url_launcher/url_launcher.dart';
import '../students/StudentVideoScreen.dart';
import 'package:lottie/lottie.dart';
import '../students/StudentListScreen.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'EditProfileScreen.dart';
import '../Messaging/ChatListScreen.dart';
import '../modules/ModulesScreen.dart'; // Asegúrate de que esta ruta sea correcta

class HomeScreen extends StatefulWidget {
  final String welcomeMessage; // para recibir el mensaje de bienvenida

  HomeScreen({Key? key, required this.welcomeMessage}) : super(key: key); // Constructor

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final AuthService _authService = AuthService();
  final PageController _pageController = PageController(); // Controlador de PageView
  int _selectedIndex = 0;
  final FlutterTts flutterTts = FlutterTts();
  bool isSpeaking = false; // Controla si se está reproduciendo la voz

  final List<String> lottieAnimations = [
    'assets/entradaparaalumno.json',
    'assets/chicocompu.json',
    'assets/cubo.json',
  ];

  @override
  void initState() {
    super.initState();
    BackgroundMusicService.playMusic(); // Iniciar la música de fondo
    _initTts(); // otras inicializaciones
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

  void _logout() async {
    bool shouldLogOut = await _showLogoutConfirmation(context);
    if (shouldLogOut) {
      BackgroundMusicService.stopMusic(); // Detener la música al cerrar sesión
      await _authService.cerrarSesion();
      Navigator.of(context).pushNamedAndRemoveUntil('/login', (Route<dynamic> route) => false);
    }
  }

  void _onPageChanged(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _navigateToPage(int index) {
    _pageController.jumpToPage(index);
  }

  void _launchUniversityUrl() async {
    const url = 'https://portales.inacap.cl/';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'No se pudo abrir la URL $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    // Definir colores personalizados
    final Color customAppBarColor = Color(0xFF42F5EC);
    Color lightBlue = Colors.lightBlue.shade100;
    Color darkBlue = Colors.blue.shade400;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.welcomeMessage,
          style: TextStyle(
            color: Colors.lightBlue,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        backgroundColor: customAppBarColor,
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.forum, color: lightBlue),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ForosScreen()),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.edit, color: lightBlue),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => EditProfileScreen()),
              );
            },
          ),
          // Eliminamos el botón de 'Mensajes' del AppBar
          IconButton(
            icon: Icon(Icons.logout, color: lightBlue),
            onPressed: _logout,
          ),
        ],
        elevation: 10,
      ),
      body: PageView(
        controller: _pageController,
        onPageChanged: _onPageChanged,
        children: [
          _buildMainHomeScreen(context), // Pantalla principal del HomeScreen
          ModulesScreen(), // Pantalla de Módulos (Inacap)
          ChatListScreen(), // Pantalla de Mensajes
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _toggleSpeech(
              "Bienvenido a la pantalla principal. Aquí puedes acceder a distintas funciones como OCR, galería de modelos 3D, videos educativos y una lista de compañeros. Explora las diferentes opciones para enriquecer tu experiencia de aprendizaje."
          );
        },
        child: Icon(Icons.volume_up),
        backgroundColor: customAppBarColor,
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed, // Para más de tres items
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Inicio',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.apartment),
            label: 'Módulos',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.message),
            label: 'Mensajes',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.amber[800],
        onTap: (index) {
          _navigateToPage(index);
        },
      ),
    );
  }

  Widget _buildMainHomeScreen(BuildContext context) {
    Color lightBlue = Colors.lightBlue.shade100;
    Color darkBlue = Colors.blue.shade400;

    return SingleChildScrollView( // Permitir desplazamiento
      child: Column(
        children: [
          CarouselSlider(
            options: CarouselOptions(
              height: 200.0,
              autoPlay: true,
              autoPlayInterval: Duration(seconds: 3),
              enlargeCenterPage: true,
            ),
            items: lottieAnimations.map((i) {
              return Builder(
                builder: (BuildContext context) {
                  return Container(
                    width: MediaQuery.of(context).size.width,
                    margin: EdgeInsets.symmetric(horizontal: 5.0),
                    child: Lottie.asset(i), // Usa la animación Lottie
                  );
                },
              );
            }).toList(),
          ),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [lightBlue, darkBlue],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: Column(
              children: [
                GridView.count(
                  physics: NeverScrollableScrollPhysics(), // Desactivar el desplazamiento interno
                  shrinkWrap: true, // Ajustar tamaño del GridView al contenido
                  padding: const EdgeInsets.all(8),
                  crossAxisCount: 2,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  children: <Widget>[
                    _featureCard(context, Icons.info, 'Información Modelos', ModelInfoScreen()),
                    _featureCard(context, Icons.collections, 'Galería', ModelsGalleryScreen()),
                    _featureCard(context, Icons.text_snippet, 'OCR', OCRScreen()),
                    _featureCard(context, Icons.video_library, 'Videos', StudentVideoScreen()),
                  ],
                ),
                // Agregar un botón para redirigir a la página de Inacap
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 24.0),
                  child: ElevatedButton.icon(
                    onPressed: _launchUniversityUrl,
                    icon: Icon(Icons.public),
                    label: Text('Ir a Inacap'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      minimumSize: Size(double.infinity, 50), // Botón de ancho completo
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _featureCard(BuildContext context, IconData icon, String label, Widget destination) {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: InkWell(
        onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => destination));
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(icon, size: 50, color: Colors.blue.shade600),
            SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    BackgroundMusicService.stopMusic(); // Detener la música al salir de HomeScreen
    flutterTts.stop();
    _pageController.dispose(); // Dispose del PageController
    super.dispose();
  }

  Future<bool> _showLogoutConfirmation(BuildContext context) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text('Cerrar sesión'),
        content: Text('¿Estás seguro de que quieres cerrar sesión?'),
        actions: <Widget>[
          TextButton(
            child: Text('Cancelar'),
            onPressed: () => Navigator.of(context).pop(false),
          ),
          TextButton(
            child: Text('Cerrar sesión'),
            onPressed: () => Navigator.of(context).pop(true),
          ),
        ],
      ),
    ).then((value) => value ?? false);
  }
}
