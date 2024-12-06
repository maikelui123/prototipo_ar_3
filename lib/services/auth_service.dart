import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<String?> registrarConEmailYPassword(
      String email,
      String password,
      String role,
      String firstName,
      String lastName,
      String phone) async {
    try {
      UserCredential userCredential =
      await _auth.createUserWithEmailAndPassword(email: email, password: password);

      User? user = userCredential.user;
      if (user != null) {
        // Imprime los datos que se van a escribir en Firestore
        print('Intentando escribir en Firestore con los siguientes datos:');
        print('Email: $email');
        print('Role: $role');
        print('FirstName: $firstName');
        print('LastName: $lastName');
        print('Phone: $phone');

        // Intentar escribir en Firestore
        try {
          await _firestore.collection('users').doc(user.uid).set({
            'email': email,
            'role': role,
            'firstName': firstName,
            'lastName': lastName,
            'phone': phone,
            'createdAt': FieldValue.serverTimestamp(),
          });
          print('Datos del usuario guardados en Firestore correctamente.');
        } catch (e) {
          print('Error al escribir en Firestore: $e');
          return 'Error al guardar los datos en Firestore: $e';
        }
      } else {
        return 'El usuario creado es nulo';
      }

      return null; // Registro exitoso
    } catch (e) {
      if (e is FirebaseAuthException) {
        return e.message;
      }
      return 'Ocurrió un error desconocido: $e';
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