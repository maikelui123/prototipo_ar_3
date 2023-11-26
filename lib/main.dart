import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_options.dart';
import 'screens/login_screen.dart';
import 'screens/teachers/TeacherHomeScreen.dart';
import 'screens/home_screen.dart';
import 'screens/registro_screen.dart';
import 'screens/teachers/content_management_screen.dart';
import 'screens/teachers/ExamCreationScreen.dart';
import 'screens/teachers/student_list_screen.dart';
import 'screens/teachers/ContentListScreen.dart';
import 'screens/SplashScreen.dart';

// 2. Función principal `main` para inicializar Firebase
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}

// 3. Widget principal `MyApp`
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Configuración del tema y las rutas de la app
    return MaterialApp(
      title: 'Nombre de tu Aplicación',
      theme: ThemeData(
        // Configuraciones de tema
      ),
      initialRoute: '/', // Ruta inicial
      routes: {
        '/': (context) => SplashScreen(), // Ruta para SplashScreen
        '/home': (context) => PantallaInicial(), // Ruta para pantalla inicial
        '/login': (context) => LoginScreen(),
        '/registro': (context) => RegistroScreen(),
        '/contentManagement': (context) => ContentManagementScreen(),
        '/createExam': (context) => CreateExamScreen(),
        '/studentList': (context) => StudentListScreen(),
        '/contentList': (context) => ContentListScreen(),
        // Agrega más rutas según sea necesario
      },
      onGenerateRoute: (settings) {
        // Manejo de rutas con argumentos
        if (settings.name == '/teacherHome') {
          final welcomeMessage = settings.arguments as String;
          return MaterialPageRoute(
            builder: (context) => TeacherHomeScreen(welcomeMessage: welcomeMessage),
          );
        } else if (settings.name == '/studentHome') {
          final welcomeMessage = settings.arguments as String;
          return MaterialPageRoute(
            builder: (context) => HomeScreen(welcomeMessage: welcomeMessage),
          );
        }
        return null; // Devolver null si no hay coincidencia
      },
    );
  }
}

// 4. Pantalla inicial `PantallaInicial`
class PantallaInicial extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // StreamBuilder para escuchar cambios en el estado de autenticación
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.active) {
          User? user = snapshot.data;
          if (user == null) {
            return LoginScreen(); // Si no hay usuario, mostramos la pantalla de inicio de sesión
          } else {
            // Si hay usuario, obtenemos sus datos y navegamos a la pantalla correspondiente
            return FutureBuilder<DocumentSnapshot>(
              future: FirebaseFirestore.instance.collection('users').doc(user.uid).get(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  if (snapshot.hasError) {
                    return Center(child: Text('Error al obtener el rol del usuario'));
                  }
                  if (snapshot.hasData) {
                    Map<String, dynamic> userData = snapshot.data!.data() as Map<String, dynamic>;
                    String role = userData['role'] ?? 'alumno';
                    // Aquí navegamos a la pantalla del profesor o del alumno, según el rol
                    if (role == 'profesor') {
                      // Pasamos un mensaje de bienvenida como argumento
                      return TeacherHomeScreen(welcomeMessage: 'Bienvenido profesor ${userData['firstName']} ${userData['lastName']}');
                    } else {
                      // Pasamos un mensaje de bienvenida como argumento
                      return HomeScreen(welcomeMessage: 'Bienvenido alumno ${userData['firstName']} ${userData['lastName']}');
                    }
                  } else {
                    return LoginScreen(); // Si no hay datos, vuelve a la pantalla de inicio de sesión
                  }
                }
                // Mientras los datos se están cargando, muestra un spinner
                return Center(child: CircularProgressIndicator());
              },
            );
          }
        }
        // Mientras se espera a que la conexión se active, muestra un spinner
        return Center(child: CircularProgressIndicator());
      },
    );
  }
}


