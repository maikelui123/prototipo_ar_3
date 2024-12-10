import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';


class TeacherHomeScreen extends StatelessWidget {
  // Eliminamos el parámetro welcomeMessage
  TeacherHomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Definir colores personalizados
    final Color primaryColor = Color(0xFF0D47A1); // Azul oscuro
    final Color accentColor = Color(0xFF42A5F5); // Azul claro

    // Obtener el usuario actual
    final user = FirebaseAuth.instance.currentUser;
    String firstName = '';
    String lastName = '';

    // Cargar datos del usuario
    if (user != null) {
      // Puedes utilizar un FutureBuilder o StreamBuilder para obtener los datos del usuario
      // Aquí simplificamos asumiendo que ya tienes los datos disponibles
      // Para una implementación completa, considera usar un StreamBuilder o FutureBuilder
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Inicio', // Título estático
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: primaryColor,
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.logout, color: Colors.white),
            tooltip: 'Cerrar sesión',
            onPressed: () => _logout(context),
          ),
        ],
        elevation: 4,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              accentColor.withOpacity(0.3),
              primaryColor.withOpacity(0.7)
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          children: [
            // Sección de perfil
            Container(
              padding: EdgeInsets.all(16.0),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundImage:
                    AssetImage('assets/images/profile_placeholder.png'),
                  ),
                  SizedBox(width: 16),
                  // Obtener y mostrar el nombre del profesor
                  FutureBuilder<DocumentSnapshot>(
                    future: FirebaseFirestore.instance
                        .collection('users')
                        .doc(user?.uid)
                        .get(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return CircularProgressIndicator(
                          valueColor:
                          AlwaysStoppedAnimation<Color>(Colors.white),
                        );
                      }
                      if (snapshot.hasError || !snapshot.hasData!) {
                        return Text(
                          'Profesor',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        );
                      }
                      var userData =
                      snapshot.data!.data() as Map<String, dynamic>;
                      firstName = userData['firstName'] ?? '';
                      lastName = userData['lastName'] ?? '';
                      return Text(
                        'Profesor $firstName $lastName',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            // Botón de Mensajes
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.pushNamed(context, '/chatList');
                },
                icon: Icon(Icons.message, color: accentColor),
                label: Text(
                  'Mensajes',
                  style: TextStyle(color: accentColor, fontSize: 16),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white.withOpacity(0.9),
                  padding:
                  EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                  elevation: 5,
                ),
              ),
            ),
            SizedBox(height: 10),
            // Grid de opciones
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  children: <Widget>[
                    _buildOptionCard(context, 'Gestión de Contenidos',
                        Icons.folder, '/contentList', primaryColor),
                    _buildOptionCard(context, 'Crear Examen/Tarea',
                        Icons.assignment, '/createExam', primaryColor),
                    _buildOptionCard(context, 'Gestión de Alumnos',
                        Icons.person, '/studentList', primaryColor),
                    _buildOptionCard(context, 'Gestión de Videos de YouTube',
                        Icons.video_library, '/manageVideos', primaryColor),
                    _buildOptionCard(context, 'Actividad de Alumnos',
                        Icons.bar_chart, '/activityChart', primaryColor),
                    _buildOptionCard(context, 'Gráfico Circular de Actividad',
                      Icons.pie_chart, '/activityPieChart', primaryColor,
                    ),
                    // Puedes añadir más tarjetas aquí si lo deseas
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      // Opcional: Botón flotante para añadir nuevas tareas, contenidos, etc.
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Acción al presionar el botón
          // Por ejemplo, navegar a una pantalla de creación rápida
        },
        backgroundColor: accentColor,
        child: Icon(Icons.add),
        tooltip: 'Añadir',
      ),
    );
  }

  Widget _buildOptionCard(BuildContext context, String title, IconData icon,
      String route, Color color) {
    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      color: Colors.white.withOpacity(0.9),
      child: InkWell(
        onTap: () {
          Navigator.pushNamed(context, route);
        },
        borderRadius: BorderRadius.circular(20),
        splashColor: color.withOpacity(0.3),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 50, color: color),
              SizedBox(height: 10),
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
        ),
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
    ) ??
        false;

    if (shouldLogOut) {
      Navigator.of(context)
          .pushNamedAndRemoveUntil('/login', (Route<dynamic> route) => false);
    }
  }
}
