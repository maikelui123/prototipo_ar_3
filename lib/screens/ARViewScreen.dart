import 'package:flutter/material.dart';
import 'package:arcore_flutter_plugin/arcore_flutter_plugin.dart';
import 'package:vector_math/vector_math_64.dart' as vector;
import 'package:cloud_firestore/cloud_firestore.dart';

class ARViewScreen extends StatefulWidget {
  @override
  _ARViewScreenState createState() => _ARViewScreenState();
}

class _ARViewScreenState extends State<ARViewScreen> {
  ArCoreController? arCoreController;
  Future<String>? model3DUrlFuture;

  @override
  void dispose() {
    arCoreController?.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    model3DUrlFuture = getModel3DUrl();
  }

  Future<String> getModel3DUrl() async {
    final collection = FirebaseFirestore.instance.collection('componentesPC');
    final querySnapshot = await collection.get();
    if (querySnapshot.docs.isNotEmpty) {
      // Asumiendo que el primer documento tiene el campo 'modelo3D_url'.
      return querySnapshot.docs.first.get('modelo3D_url');
    }
    throw Exception('Modelo 3D URL no encontrado'); // O manejar esto adecuadamente.
  }

  void _whenArCoreViewCreated(ArCoreController controller) {
    arCoreController = controller;
    model3DUrlFuture!.then((model3DUrl) {
      final node = ArCoreReferenceNode(
        name: "Modelo3D",
        objectUrl: model3DUrl,
        position: vector.Vector3(0, 0, -1),
        scale: vector.Vector3(0.5, 0.5, 0.5),
      );
      controller.addArCoreNodeWithAnchor(node);
    }).catchError((error) {
      // Manejar el error aquí.
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Vista AR del Modelo'),
      ),
      body: FutureBuilder<String>(
        future: model3DUrlFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done && snapshot.hasData) {
            return ArCoreView(
              onArCoreViewCreated: _whenArCoreViewCreated,
              enableTapRecognizer: true,
            );
          } else if (snapshot.hasError) {
            return Center(child: Text('Error al cargar el modelo 3D: ${snapshot.error}'));
          } else {
            return Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}
