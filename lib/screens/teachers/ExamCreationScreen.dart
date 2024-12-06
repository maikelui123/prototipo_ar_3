import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart';

class CreateExamScreen extends StatefulWidget {
  @override
  _CreateExamScreenState createState() => _CreateExamScreenState();
}

class _CreateExamScreenState extends State<CreateExamScreen> {
  final _formKey = GlobalKey<FormState>();
  String _title = '';
  String _description = '';
  DateTime _dueDate = DateTime.now();
  List<String> _assignedTo = []; // IDs de los estudiantes asignados
  Map<String, String> _criteria = {"contenido": "", "originalidad": "", "presentación": ""};
  List<Map<String, dynamic>> _students = []; // Lista de estudiantes con id y nombre

  @override
  void initState() {
    super.initState();
    _fetchStudentIds();
  }

  void _fetchStudentIds() async {
    var studentsSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('role', isEqualTo: 'alumno')
        .get();

    setState(() {
      _students = studentsSnapshot.docs.map((doc) => {
        'id': doc.id, // Guarda el ID del estudiante
        'name': doc.data()['firstName'] + " " + doc.data()['lastName'], // Crea un nombre completo
      }).toList();
    });
  }

  Future<void> _saveExam() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      await FirebaseFirestore.instance.collection('exams').add({
        'title': _title,
        'description': _description,
        'dueDate': Timestamp.fromDate(_dueDate),
        'assignedTo': _assignedTo,
        'createdBy': 'profesorId123', // Obtener el ID del profesor actual
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'criteria': _criteria,
        'status': 'abierta',
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Examen guardado con éxito')));
      Navigator.pop(context);
    }
  }

  void _previewExam() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Vista Previa del Examen'),
        content: SingleChildScrollView(
          child: ListBody(
            children: <Widget>[
              Text('Título: $_title', style: TextStyle(fontWeight: FontWeight.bold)),
              Text('Descripción: $_description'),
              Text('Fecha de entrega: ${_dueDate.toLocal()}'),
              // Mostrar más detalles si es necesario
            ],
          ),
        ),
        actions: <Widget>[
          TextButton(
            child: Text('Cerrar'),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Color lightBlue = Colors.lightBlue.shade100;
    Color darkBlue = Colors.blue.shade400;

    return Scaffold(
      appBar: AppBar(
        title: Text('Crear Examen/Tarea'),
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
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                children: [
                  TextFormField(
                    decoration: InputDecoration(labelText: 'Título del examen/tarea'),
                    validator: (value) => value!.isEmpty ? 'Este campo no puede estar vacío' : null,
                    onSaved: (value) => _title = value!,
                  ),
                  TextFormField(
                    decoration: InputDecoration(labelText: 'Descripción'),
                    validator: (value) => value!.isEmpty ? 'Este campo no puede estar vacío' : null,
                    onSaved: (value) => _description = value!,
                  ),
                  TextFormField(
                    decoration: InputDecoration(labelText: 'Puntos por contenido'),
                    validator: (value) => value!.isEmpty ? 'Este campo no puede estar vacío' : null,
                    onSaved: (value) => _criteria['contenido'] = value!,
                  ),
                  TextFormField(
                    decoration: InputDecoration(labelText: 'Puntos por originalidad'),
                    validator: (value) => value!.isEmpty ? 'Este campo no puede estar vacío' : null,
                    onSaved: (value) => _criteria['originalidad'] = value!,
                  ),
                  TextFormField(
                    decoration: InputDecoration(labelText: 'Puntos por presentación'),
                    validator: (value) => value!.isEmpty ? 'Este campo no puede estar vacío' : null,
                    onSaved: (value) => _criteria['presentación'] = value!,
                  ),
                  ElevatedButton(
                    onPressed: _previewExam,
                    child: Text('Vista Previa del Examen'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: darkBlue,
                    ),
                  ),
                  ElevatedButton(
                    onPressed: _saveExam,
                    child: Text('Guardar Examen/Tarea'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: darkBlue,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _saveExam,
        child: Icon(Icons.save),
        backgroundColor: darkBlue,
        tooltip: 'Guardar Examen/Tarea',
      ),
    );
  }
}
