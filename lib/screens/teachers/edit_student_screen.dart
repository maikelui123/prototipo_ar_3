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

  @override
  void initState() {
    super.initState();
    _loadStudentData();
  }

  void _loadStudentData() async {
    var document = await _firestore.collection('users').doc(widget.studentId).get();
    if (document.exists) {
      var alumno = document.data();
      if (alumno != null) {
        setState(() {
          _firstName = alumno['firstName'] ?? '';
          _lastName = alumno['lastName'] ?? '';
          _email = alumno['email'] ?? '';
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
      });
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Definiendo colores
    Color lightBlue = Colors.lightBlue.shade100;
    Color darkBlue = Colors.blue.shade400;

    return Scaffold(
      appBar: AppBar(
        title: Text('Editar Alumno', style: TextStyle(color: lightBlue)),
        backgroundColor: darkBlue,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [lightBlue, darkBlue],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Form(
          key: _formKey,
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              children: <Widget>[
                TextFormField(
                  initialValue: _firstName,
                  decoration: InputDecoration(
                    labelText: 'Nombre',
                    labelStyle: TextStyle(color: darkBlue),
                    fillColor: Colors.white,
                    filled: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                  onSaved: (value) => _firstName = value ?? '',
                ),
                SizedBox(height: 10),
                TextFormField(
                  initialValue: _lastName,
                  decoration: InputDecoration(
                    labelText: 'Apellido',
                    labelStyle: TextStyle(color: darkBlue),
                    fillColor: Colors.white,
                    filled: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                  onSaved: (value) => _lastName = value ?? '',
                ),
                SizedBox(height: 10),
                TextFormField(
                  initialValue: _email,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    labelStyle: TextStyle(color: darkBlue),
                    fillColor: Colors.white,
                    filled: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                  onSaved: (value) => _email = value ?? '',
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    primary: darkBlue,
                    onPrimary: lightBlue,
                  ),
                  onPressed: _saveStudentData,
                  child: Text('Guardar Cambios'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

