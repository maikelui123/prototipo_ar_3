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
    // Realizar la búsqueda en Firestore en la colección deseada
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
      // Guardar en Firestore
      await FirebaseFirestore.instance.collection('exams').add({
        'title': _title,
        'description': _description,
        'dueDate': Timestamp.fromDate(_dueDate),
        'assignedTo': _assignedTo,
        'createdBy': 'profesorId123', // Aquí deberías obtener el ID del profesor actual
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'criteria': _criteria,
        'status': 'abierta',
        // 'grade' se inicializa vacío
      });
      // Mostrar mensaje de éxito
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Examen guardado con éxito')));
      // Regresar a la pantalla anterior o navegar a donde desees
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Crear Examen/Tarea'),
      ),
      body: SingleChildScrollView(
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
                  onPressed: () {
                    DatePicker.showDateTimePicker(
                      context,
                      showTitleActions: true,
                      minTime: DateTime.now(),
                      onConfirm: (date) {
                        setState(() => _dueDate = date);
                      },
                      currentTime: _dueDate,
                      locale: LocaleType.es, // Ajusta el idioma al español
                    );
                  },
                  child: Text('Seleccionar fecha de entrega'),
                ),
                Wrap(
                  children: _students.map((student) {
                    return ChoiceChip(
                      label: Text(student['name']), // Muestra el nombre del estudiante
                      selected: _assignedTo.contains(student['id']),
                      onSelected: (isSelected) {
                        setState(() {
                          if (isSelected) {
                            _assignedTo.add(student['id']);
                          } else {
                            _assignedTo.removeWhere((id) => id == student['id']);
                          }
                        });
                      },
                    );
                  }).toList(),
                ),
                ElevatedButton(
                  onPressed: _saveExam,
                  child: Text('Guardar Examen/Tarea'),
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _saveExam,
        child: Icon(Icons.save),
        tooltip: 'Guardar Examen/Tarea',
      ),
    );
  }
}
