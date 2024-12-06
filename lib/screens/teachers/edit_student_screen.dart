// screens/students/EditStudentScreen.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EditStudentScreen extends StatefulWidget {
  final String studentId;

  EditStudentScreen({Key? key, required this.studentId}) : super(key: key);

  @override
  _EditStudentScreenState createState() => _EditStudentScreenState();
}

class _EditStudentScreenState extends State<EditStudentScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final _formKey = GlobalKey<FormState>();
  String _firstName = '';
  String _lastName = '';
  String _email = '';
  String _phone = '';

  @override
  void initState() {
    super.initState();
    _loadStudentData();
  }

  void _loadStudentData() async {
    var document =
    await _firestore.collection('users').doc(widget.studentId).get();
    if (document.exists) {
      var alumno = document.data();
      if (alumno != null) {
        setState(() {
          _firstName = alumno['firstName'] ?? '';
          _lastName = alumno['lastName'] ?? '';
          _email = alumno['email'] ?? '';
          _phone = alumno['phone'] ?? '';
        });
      }
    }
  }

  void _saveStudentData() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      await _firestore.collection('users').doc(widget.studentId).update({
        'firstName': _firstName,
        'lastName': _lastName,
        'email': _email,
        'phone': _phone,
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Datos actualizados correctamente')),
      );
      Navigator.pop(context);
    }
  }

  void _sendMessage() {
    // Implementa la lógica para enviar un mensaje al alumno
    // Puedes navegar a la pantalla de Chat o abrir un diálogo
    // Aquí te dejo un ejemplo simple de diálogo
    showDialog(
      context: context,
      builder: (context) {
        String message = '';
        return AlertDialog(
          title: Text('Enviar Mensaje'),
          content: TextField(
            onChanged: (value) {
              message = value;
            },
            decoration: InputDecoration(hintText: "Escribe tu mensaje aquí"),
            maxLines: 3,
          ),
          actions: [
            TextButton(
              child: Text('Cancelar', style: TextStyle(color: Colors.grey)),
              onPressed: () => Navigator.of(context).pop(),
            ),
            ElevatedButton(
              child: Text('Enviar'),
              onPressed: () {
                if (message.trim().isNotEmpty) {
                  // Aquí debes implementar la lógica para enviar el mensaje
                  // Por ejemplo, agregarlo a una colección de mensajes en Firestore
                  _firestore
                      .collection('messages')
                      .doc(widget.studentId)
                      .collection('chats')
                      .add({
                    'senderId': FirebaseFirestore.instance
                        .collection('users')
                        .doc()
                        .id, // Reemplaza con el ID del profesor
                    'message': message,
                    'timestamp': FieldValue.serverTimestamp(),
                  });
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Mensaje enviado')),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Definiendo colores
    final Color primaryColor = Color(0xFF0D47A1); // Azul oscuro
    final Color accentColor = Color(0xFF42A5F5); // Azul claro
    final Color backgroundColor = Colors.white;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Editar Alumno',
          style: TextStyle(color: accentColor, fontWeight: FontWeight.bold),
        ),
        backgroundColor: primaryColor,
        actions: [
          IconButton(
            icon: Icon(Icons.message, color: accentColor),
            tooltip: 'Enviar Mensaje',
            onPressed: _sendMessage,
          ),
        ],
        elevation: 4,
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [accentColor.withOpacity(0.1), primaryColor.withOpacity(0.05)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Card(
            shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            elevation: 8,
            color: backgroundColor,
            child: Padding(
              padding: EdgeInsets.all(20.0),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    // Nombre
                    TextFormField(
                      initialValue: _firstName,
                      decoration: InputDecoration(
                        labelText: 'Nombre',
                        labelStyle: TextStyle(color: primaryColor),
                        prefixIcon: Icon(Icons.person, color: primaryColor),
                        filled: true,
                        fillColor: Colors.grey[100],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15.0),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor, ingresa el nombre';
                        }
                        return null;
                      },
                      onSaved: (value) => _firstName = value!.trim(),
                    ),
                    SizedBox(height: 15),
                    // Apellido
                    TextFormField(
                      initialValue: _lastName,
                      decoration: InputDecoration(
                        labelText: 'Apellido',
                        labelStyle: TextStyle(color: primaryColor),
                        prefixIcon: Icon(Icons.person_outline, color: primaryColor),
                        filled: true,
                        fillColor: Colors.grey[100],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15.0),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor, ingresa el apellido';
                        }
                        return null;
                      },
                      onSaved: (value) => _lastName = value!.trim(),
                    ),
                    SizedBox(height: 15),
                    // Email
                    TextFormField(
                      initialValue: _email,
                      decoration: InputDecoration(
                        labelText: 'Email',
                        labelStyle: TextStyle(color: primaryColor),
                        prefixIcon: Icon(Icons.email, color: primaryColor),
                        filled: true,
                        fillColor: Colors.grey[100],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15.0),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor, ingresa el email';
                        }
                        if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                          return 'Por favor, ingresa un email válido';
                        }
                        return null;
                      },
                      onSaved: (value) => _email = value!.trim(),
                    ),
                    SizedBox(height: 15),
                    // Teléfono
                    TextFormField(
                      initialValue: _phone,
                      decoration: InputDecoration(
                        labelText: 'Teléfono',
                        labelStyle: TextStyle(color: primaryColor),
                        prefixIcon: Icon(Icons.phone, color: primaryColor),
                        filled: true,
                        fillColor: Colors.grey[100],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15.0),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      keyboardType: TextInputType.phone,
                      onSaved: (value) => _phone = value!.trim(),
                    ),
                    SizedBox(height: 25),
                    // Botones
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Guardar Cambios
                        ElevatedButton.icon(
                          onPressed: _saveStudentData,
                          icon: Icon(Icons.save, color: accentColor),
                          label: Text(
                            'Guardar',
                            style: TextStyle(color: accentColor),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryColor,
                            padding: EdgeInsets.symmetric(
                                horizontal: 20, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                        ),
                        // Cancelar
                        OutlinedButton.icon(
                          onPressed: () => Navigator.pop(context),
                          icon: Icon(Icons.cancel, color: primaryColor),
                          label: Text(
                            'Cancelar',
                            style: TextStyle(color: primaryColor),
                          ),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: primaryColor),
                            padding: EdgeInsets.symmetric(
                                horizontal: 20, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _sendMessage,
        backgroundColor: primaryColor,
        child: Icon(Icons.message, color: accentColor),
        tooltip: 'Enviar Mensaje',
      ),
    );
  }
}
