import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:arcore_flutter_plugin/arcore_flutter_plugin.dart';
import 'package:vector_math/vector_math_64.dart' as vector;

class ARScreen extends StatefulWidget {
  @override
  _ARScreenState createState() => _ARScreenState();
}

class _ARScreenState extends State<ARScreen> {
  ArCoreController? arCoreController;

  @override
  void dispose() {
    arCoreController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ARCore Flutter'),
      ),
      body: ArCoreView(
        onArCoreViewCreated: _onArCoreViewCreated,
      ),
    );
  }

  void _onArCoreViewCreated(ArCoreController controller) {
    arCoreController = controller;

    // Descarga y agrega el modelo 3D
    _downloadAndAddModel(controller);
  }

  void _downloadAndAddModel(ArCoreController controller) async {
    final url = 'https://firebasestorage.googleapis.com/v0/b/proyecto-prototipo-03.appspot.com/o/modelos3D%2Fcpu%2Fscene.gltf?alt=media&token=6fc82c9e-2e1f-4477-a503-6074922e847f';
    final modelPath = await _downloadModel(url);
    _addArCoreNode(controller, modelPath);
  }

  Future<String> _downloadModel(String url) async {
    var uri = Uri.parse(url);
    var response = await http.get(uri);
    var documentDirectory = await getApplicationDocumentsDirectory();
    var firstPath = documentDirectory.path + "/models";
    var filePathAndName = documentDirectory.path + '/models/model.gltf';
    await Directory(firstPath).create(recursive: true);
    File file = new File(filePathAndName);
    file.writeAsBytesSync(response.bodyBytes);
    return filePathAndName;
  }

  void _addArCoreNode(ArCoreController controller, String modelPath) {
    final node = ArCoreReferenceNode(
      name: '3DModel',
      object3DFileName: modelPath,
      position: vector.Vector3(0, 0, -1.5),
    );
    controller.addArCoreNode(node);
  }
}
