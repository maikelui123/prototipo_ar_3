// main.dart

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_options.dart';
import 'screens/auth/login_screen.dart';
import 'screens/teachers/TeacherHomeScreen.dart';
import 'screens/utilities/home_screen.dart';
import 'screens/auth/registro_screen.dart';
import 'screens/teachers/content_management_screen.dart';
import 'screens/teachers/ExamCreationScreen.dart';
import 'screens/teachers/student_list_screen.dart';
import 'screens/teachers/ContentListScreen.dart';
import 'screens/utilities/SplashScreen.dart';
import 'services/music_service.dart';
import 'screens/teachers/manage_videos_screen.dart';
import 'screens/models/ModelsOSIScreen.dart';
import 'screens/utilities/CloudComputingScreen.dart';
import 'screens/utilities/ForosScreen.dart';
import 'screens/utilities/CrearForoScreen.dart';
import 'screens/Messaging/ChatListScreen.dart';
import 'screens/Messaging/ChatScreen.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'screens/modules/ModulesScreen.dart';

// Importa la pantalla de Política de Privacidad
import 'screens/auth/PrivacyPolicyScreen.dart';

// Inicializa el FlutterLocalNotificationsPlugin
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
FlutterLocalNotificationsPlugin();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializa Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Configuración de notificaciones locales
  const AndroidInitializationSettings initializationSettingsAndroid =
  AndroidInitializationSettings('@mipmap/ic_launcher');

  const InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
  );

  await flutterLocalNotificationsPlugin.initialize(
    initializationSettings,
    // Puedes manejar el toque en la notificación con onSelectNotification
    // onSelectNotification: (String? payload) {
    //   // Maneja el toque en la notificación
    // },
  );

  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this); // Observa cambios en el estado de la app
    // **Eliminar esta línea si no es necesaria**
    // BackgroundMusicService.playMusic(); // Inicia la música al abrir la app
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this); // Deja de observar cambios
    // **Eliminar esta línea si no es necesaria**
    // BackgroundMusicService.stopMusic(); // Detén la música al cerrar la app
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      // La app pasó a segundo plano, detén la música
      BackgroundMusicService.stopMusic();
    } else if (state == AppLifecycleState.resumed) {
      // La app volvió al primer plano, reproduce la música
      BackgroundMusicService.playMusic();
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Nombre de tu Aplicación',
      theme: ThemeData(
        // Configuraciones de tema
        primarySwatch: Colors.blue,
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
        '/manageVideos': (context) => ManageVideosScreen(),
        '/osiModels': (context) => ModelsOSIScreen(), // Ruta existente
        '/cloudComputing': (context) => CloudComputingScreen(), // Nueva ruta agregada
        '/foros': (context) => ForosScreen(), // Nueva ruta para ForosScreen
        '/crearForo': (context) => CrearForoScreen(), // Nueva ruta para CrearForoScreen
        '/chatList': (context) => ChatListScreen(), // Nueva ruta para ChatListScreen
        // Añade la ruta para PrivacyPolicyScreen
        '/privacyPolicy': (context) => PrivacyPolicyScreen(),
        // Eliminamos '/chatScreen' de las rutas fijas y lo manejamos en onGenerateRoute
      },
      onGenerateRoute: (settings) {
        // Manejo de rutas con argumentos
        if (settings.name == '/teacherHome') {
          // TeacherHomeScreen no requiere 'welcomeMessage'
          return MaterialPageRoute(
            builder: (context) => TeacherHomeScreen(),
          );
        } else if (settings.name == '/studentHome') {
          final welcomeMessage = settings.arguments as String;
          return MaterialPageRoute(
            builder: (context) => HomeScreen(welcomeMessage: welcomeMessage),
          );
        } else if (settings.name == '/chatScreen') {
          final args = settings.arguments as Map<String, dynamic>;
          return MaterialPageRoute(
            builder: (context) => ChatScreen(
              peerId: args['peerId'],
              peerName: args['peerName'],
            ),
          );
        }
        return null; // Devolver null si no hay coincidencia
      },
    );
  }
}

// Pantalla inicial `PantallaInicial`
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
                  if (snapshot.hasData && snapshot.data!.exists) {
                    Map<String, dynamic> userData = snapshot.data!.data() as Map<String, dynamic>;
                    String role = userData['role'] ?? 'alumno';
                    // Aquí navegamos a la pantalla del profesor o del alumno, según el rol
                    if (role == 'profesor') {
                      return TeacherHomeScreen();
                    } else {
                      return HomeScreen(
                        welcomeMessage:
                        'Bienvenido alumno ${userData['firstName']} ${userData['lastName']}',
                      );
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
