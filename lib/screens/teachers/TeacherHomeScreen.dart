import 'package:flutter/material.dart';

class TeacherHomeScreen extends StatelessWidget {
  final String welcomeMessage; // Campo para el mensaje de bienvenida

  TeacherHomeScreen({Key? key, required this.welcomeMessage}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Definir colores personalizados
    Color lightBlue = Colors.lightBlue.shade100;
    Color darkBlue = Colors.blue.shade400;

    return Scaffold(
      appBar: AppBar(
        title: Text(welcomeMessage, style: TextStyle(color: lightBlue)),
        backgroundColor: darkBlue,
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.logout, color: lightBlue),
            onPressed: () => _logout(context),
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
        child: ListView(
          padding: EdgeInsets.all(8.0),
          children: ListTile.divideTiles(
            context: context,
            tiles: [
              _serviceTile(context, 'Gestión de Contenidos', Icons.folder, '/contentList'),
              _serviceTile(context, 'Crear Examen/Tarea', Icons.assignment, '/createExam'),
              _serviceTile(context, 'Gestión de Alumnos', Icons.person, '/studentList'),
              // Agrega más tiles según sea necesario
            ],
          ).toList(),
        ),
      ),
    );
  }

  Widget _serviceTile(BuildContext context, String title, IconData icon, String route) {
    return Card(
      elevation: 5, // Sombra para dar sensación de elevación
      margin: EdgeInsets.all(10.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
      child: ListTile(
        leading: Icon(icon, size: 30.0, color: Colors.blue.shade600),
        title: Text(title, style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)),
        trailing: Icon(Icons.chevron_right, color: Colors.grey),
        onTap: () {
          if (title == 'Gestión de Contenidos') {
            Navigator.of(context).pushNamed('/contentList');
          } else {
            Navigator.of(context).pushNamed(route);
          }
        },
      ),
    );
  }

  // Método para manejar el cierre de sesión
  void _logout(BuildContext context) async {
    bool shouldLogOut = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
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
        );
      },
    ) ?? false;

    if (shouldLogOut) {
      Navigator.of(context).pushNamedAndRemoveUntil('/login', (Route<dynamic> route) => false);
    }
  }
}


