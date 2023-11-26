import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Método para registrarse
  Future<String?> registrarConEmailYPassword(
      String email,
      String password,
      String role,
      String firstName,
      String lastName,
      String phone
      ) async {
    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
          email: email,
          password: password
      );

      // Comprueba que el objeto user no es null antes de acceder a uid
      User? user = userCredential.user;
      if (user != null) {
        await _firestore.collection('users').doc(user.uid).set({
          'email': email,
          'role': role,
          'firstName': firstName,
          'lastName': lastName,
          'phone': phone,
          'createdAt': FieldValue.serverTimestamp(),
        });
      } else {
        // Manejar el caso en que el usuario es null
        return 'El usuario creado es nulo';
      }

      return null; // Si no hay error, devuelve null
    } catch (e) {
      if (e is FirebaseAuthException) {
        return e.message; // Devuelve el mensaje de error
      }
      return 'Ocurrió un error desconocido'; // Para otros errores no específicos
    }
  }

  // Método para iniciar sesión
  Future<String?> iniciarSesionConEmailYPassword(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      return null; // Si no hay error, devuelve null
    } catch (e) {
      if (e is FirebaseAuthException) {
        return e.message; // Devuelve el mensaje de error
      }
      return 'Ocurrió un error desconocido'; // Para otros errores no específicos
    }
  }

  // Método para cerrar sesión
  Future<void> cerrarSesion() async {
    try {
      await _auth.signOut();
    } catch (e) {
      print(e.toString());
      throw e; // Lanza el error para que pueda ser manejado por quien llame a esta función
    }
  }
}
