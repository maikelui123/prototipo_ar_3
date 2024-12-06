import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lottie/lottie.dart'; // Importa el paquete Lottie
import '../../services/auth_service.dart';
import 'package:flutter_tts/flutter_tts.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final AuthService _authService = AuthService();
  String _email = '';
  String _password = '';
  final FlutterTts flutterTts = FlutterTts();
  bool _isPasswordVisible = false;
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

  Future<void> _getAndNavigateByUserRole(String uid) async {
    FirebaseFirestore _firestore = FirebaseFirestore.instance;
    DocumentSnapshot userDoc = await _firestore.collection('users').doc(uid).get();

    if (userDoc.exists) {
      Map<String, dynamic>? userData = userDoc.data() as Map<String, dynamic>?;
      if (userData != null) {
        String welcomeMessage = 'Bienvenido ${userData['role'] == 'profesor' ? 'profesor' : 'alumno'} ${userData['firstName']} ${userData['lastName']}';
        if (userData['role'] == 'profesor') {
          // Navegación a la pantalla de inicio del profesor con mensaje de bienvenida
          Navigator.pushReplacementNamed(context, '/teacherHome', arguments: welcomeMessage);
        } else {
          // Navegación a la pantalla de inicio del alumno con mensaje de bienvenida
          Navigator.pushReplacementNamed(context, '/studentHome', arguments: welcomeMessage);
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('No se encontraron datos del usuario.'))
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('No se encontraron datos del usuario.'))
      );
    }
  }

  void _showPasswordResetDialog() {
    showDialog(
      context: context,
      builder: (context) {
        String email = '';
        return AlertDialog(
          title: Text('Restablecer contraseña'),
          content: TextFormField(
            onChanged: (value) => email = value,
            decoration: InputDecoration(
              hintText: 'Ingresa tu email',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                _resetPassword(email);
                Navigator.of(context).pop();
              },
              child: Text('Enviar'),
            ),
          ],
        );
      },
    );
  }

  void _resetPassword(String email) async {
    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Por favor, ingresa un email')),
      );
      return;
    }

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Correo de restablecimiento enviado')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al enviar correo')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color customAppBarColor = Color(0xFF42F5EC);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Inicia Sesión',
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
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [Colors.blue.shade300, Colors.blue.shade500],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Lottie.asset('assets/Animation1.json', width: 200, height: 200),
                  TextFormField(
                    decoration: InputDecoration(
                      hintText: 'Email',
                      hintStyle: TextStyle(color: Colors.grey.shade800), // Texto de sugerencia más oscuro
                      fillColor: Colors.white,
                      filled: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      prefixIcon: Icon(Icons.email, color: Colors.grey.shade800), // Ícono más oscuro
                    ),
                    style: TextStyle(color: Colors.black), // Texto de entrada más oscuro
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor ingresa un email';
                      }
                      return null;
                    },
                    onChanged: (value) {
                      setState(() {
                        _email = value;
                      });
                    },
                  ),
                  SizedBox(height: 20),
                  TextFormField(
                    decoration: InputDecoration(
                      hintText: 'Contraseña',
                      hintStyle: TextStyle(color: Colors.grey.shade800), // Texto de sugerencia más oscuro
                      fillColor: Colors.white,
                      filled: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      prefixIcon: Icon(Icons.lock, color: Colors.grey.shade800), // Ícono más oscuro
                      suffixIcon: IconButton(
                        icon: Icon(
                          _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                          color: Colors.grey.shade800,
                        ),
                        onPressed: () {
                          setState(() {
                            _isPasswordVisible = !_isPasswordVisible;
                          });
                        },
                      ),
                    ),
                    style: TextStyle(color: Colors.black), // Texto de entrada más oscuro
                    obscureText: !_isPasswordVisible,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor ingresa una contraseña';
                      }
                      return null;
                    },
                    onChanged: (value) {
                      setState(() {
                        _password = value;
                      });
                    },
                  ),
                  SizedBox(height: 30),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.blue.shade800,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(32.0),
                      ),
                      padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                    ),
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        String? errorMessage = await _authService.iniciarSesionConEmailYPassword(_email, _password);
                        if (errorMessage == null) {
                          String? uid = FirebaseAuth.instance.currentUser?.uid;
                          if (uid != null) {
                            await _getAndNavigateByUserRole(uid);
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('No se pudo obtener el ID del usuario.'))
                            );
                          }
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(errorMessage))
                          );
                        }
                      }
                    },
                    child: Text(
                      'Iniciar Sesión',
                      style: TextStyle(color: Colors.blue.shade800),
                    ),
                  ),
                  SizedBox(height: 20),
                  TextButton(
                    style: TextButton.styleFrom(
                      backgroundColor: Colors.blue.shade800,
                    ),
                    onPressed: () {
                      Navigator.pushNamed(context, '/registro');
                    },
                    child: Text('Registrarse'),
                  ),
                  SizedBox(height: 20),
                  TextButton(
                    onPressed: () {
                      _showPasswordResetDialog();
                    },
                    child: Text('¿Olvidaste tu contraseña?'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _toggleSpeech(
              "Hola y bienvenido a la pantalla de inicio de sesión. Aquí deberás ingresar tu dirección de correo electrónico y tu contraseña para acceder a todas las funciones de la aplicación. Si por alguna razón has olvidado tu contraseña, no te preocupes. Simplemente haz clic en el enlace de '¿Olvidaste tu contraseña?' para recibir instrucciones sobre cómo restablecerla. Si aún no tienes una cuenta, puedes registrarte fácilmente haciendo clic en el botón de 'Registrarse'. ¡Estamos encantados de tenerte aquí!"
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
