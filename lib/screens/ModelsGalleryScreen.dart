import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ModelsGalleryScreen extends StatelessWidget {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Galería de Modelos 3D'),
      ),
      body: StreamBuilder(
        stream: firestore.collection('componentesPC').snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error al cargar los modelos'));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          var models = snapshot.data!.docs;

          return ListView.builder(
            itemCount: models.length,
            itemBuilder: (context, index) {
              var model = models[index].data() as Map<String, dynamic>;

              return Card(
                child: ListTile(
                  title: Text(model['nombre']),
                  leading: Image.network(model['imagen_url']),
                  onTap: () {
                    // Aquí debes implementar la acción de mostrar el modelo en AR
                    // Por ejemplo, podrías navegar a una nueva pantalla que tome model['modelo3D_url']
                    // y lo utilice para cargar el modelo en AR.
                    _showARModel(context, model['modelo3D_url']);
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _showARModel(BuildContext context, String modelUrl) {
    // Implementa la navegación a la pantalla de AR aquí
    // Necesitarías un paquete de Flutter que soporte AR, como ar_flutter_plugin
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ARViewScreen(modelUrl: modelUrl),
      ),
    );
  }
}

// Debes crear una nueva pantalla llamada ARViewScreen
// Aquí hay un esqueleto básico de lo que podría ser esa pantalla

class ARViewScreen extends StatelessWidget {
  final String modelUrl;

  ARViewScreen({required this.modelUrl});

  @override
  Widget build(BuildContext context) {
    // El contenido de esta pantalla dependerá del paquete de AR que elijas
    // y de cómo este paquete requiere que cargues y muestres modelos 3D
    return Scaffold(
      appBar: AppBar(
        title: Text('Vista AR del Modelo'),
      ),
      body: Center(
        // Aquí deberías tener algún tipo de ARWidget que tome modelUrl
        // y muestre el modelo en AR
        child: Text('Visualizador AR no implementado'),
      ),
    );
  }
}
