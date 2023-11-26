import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'OCRScreen.dart'; // Import OCRScreen
import 'ModelInfoScreen.dart'; // Import ModelInfoScreen
import 'ModelsGalleryScreen.dart'; // Import ModelsGalleryScreen

class HomeScreen extends StatefulWidget {
  final String welcomeMessage; // Añadido para recibir el mensaje de bienvenida

  HomeScreen({Key? key, required this.welcomeMessage}) : super(key: key); // Constructor modificado

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final AuthService _authService = AuthService();
  int _selectedIndex = 0;

  void _logout() async {
    bool shouldLogOut = await _showLogoutConfirmation(context);
    if (shouldLogOut) {
      await _authService.cerrarSesion();
      Navigator.of(context).pushNamedAndRemoveUntil('/login', (Route<dynamic> route) => false);
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      // Aquí puedes actualizar la lógica de navegación si es necesario
    });
  }

  @override
  Widget build(BuildContext context) {
    // Definir colores personalizados
    Color lightBlue = Colors.lightBlue.shade100;
    Color darkBlue = Colors.blue.shade400;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.welcomeMessage, style: TextStyle(color: lightBlue)),
        backgroundColor: darkBlue,
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.logout, color: lightBlue),
            onPressed: _logout,
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [lightBlue, darkBlue],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: GridView.count(
          padding: const EdgeInsets.all(8),
          crossAxisCount: 2,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          children: <Widget>[
            _featureCard(context, Icons.info, 'Model Info', ModelInfoScreen()),
            _featureCard(context, Icons.collections, 'Gallery', ModelsGalleryScreen()),
            _featureCard(context, Icons.text_snippet, 'OCR', OCRScreen()),
            // Añade más tarjetas según sea necesario
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Inicio',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: 'Docente',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.apartment),
            label: 'Universidad',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.amber[800],
        onTap: _onItemTapped,
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
            Text(label),
          ],
        ),
      ),
    );
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
