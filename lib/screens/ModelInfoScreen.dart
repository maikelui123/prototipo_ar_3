import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'ModelDetailScreen.dart';



class ModelInfoScreen extends StatefulWidget {
  @override
  _ModelInfoScreenState createState() => _ModelInfoScreenState();
}

class _ModelInfoScreenState extends State<ModelInfoScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Modelos 3D'),
      ),
      body: StreamBuilder(
        stream: _firestore.collection('componentesPC').snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          }
          switch (snapshot.connectionState) {
            case ConnectionState.waiting:
              return CircularProgressIndicator();
            default:
              return ListView(
                children: snapshot.data!.docs.map((DocumentSnapshot document) {
                  Map<String, dynamic> data = document.data() as Map<String, dynamic>;
                  return Card(
                    child: ListTile(
                      leading: Image.network(data['imagen_url'], width: 100, fit: BoxFit.cover),
                      title: Text(data['nombre']),
                      subtitle: Text(data['descripcion']),
                      onTap: () {
                        // Navega a la pantalla de detalles con los datos del modelo seleccionado
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ModelDetailScreen(
                              nombre: data['nombre'],
                              informacionModelo: data['informacionModelo'],
                            ),
                          ),
                        );
                      },
                    ),
                  );
                }).toList(),
              );
          }
        },
      ),
    );
  }
}


