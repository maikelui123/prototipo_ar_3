import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class StudentListScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Definir colores personalizados
    Color lightBlue = Colors.lightBlue.shade100;
    Color darkBlue = Colors.blue.shade400;

    return Scaffold(
      appBar: AppBar(
        title: Text('Lista de Alumnos', style: TextStyle(color: lightBlue)),
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
        child: StreamBuilder(
          stream: FirebaseFirestore.instance.collection('users')
              .where('role', isEqualTo: 'alumno')
              .snapshots(),
          builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.hasError) {
              return Center(child: Text('Error al cargar los alumnos'));
            }
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }

            return ListView(
              children: snapshot.data!.docs.map((DocumentSnapshot document) {
                Map<String, dynamic> alumno = document.data() as Map<String, dynamic>;
                return Card(
                  color: Colors.white,
                  margin: EdgeInsets.all(8),
                  child: ListTile(
                    leading: Icon(Icons.person, color: darkBlue),
                    title: Text('${alumno['firstName']} ${alumno['lastName']}', style: TextStyle(color: darkBlue)),
                    subtitle: Text(alumno['email']),
                  ),
                );
              }).toList(),
            );
          },
        ),
      ),
    );
  }
}
