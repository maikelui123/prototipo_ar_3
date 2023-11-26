import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:arcore_flutter_plugin/arcore_flutter_plugin.dart';
import 'package:vector_math/vector_math_64.dart' as vector;

class Model3DManager {
  Future<String> downloadModel(String url) async {
    var uri = Uri.parse(url);
    var response = await http.get(uri);
    var documentDirectory = await getApplicationDocumentsDirectory();
    var firstPath = documentDirectory.path + "/models";
    var filePathAndName = documentDirectory.path + '/models/model.gltf';
    await Directory(firstPath).create(recursive: true); // Crea el directorio si no existe
    File file = new File(filePathAndName);
    file.writeAsBytesSync(response.bodyBytes);
    return filePathAndName;
  }

  void addModelToScene(ArCoreController controller, String modelPath) {
    final node = ArCoreReferenceNode(
      name: '3DModel',
      object3DFileName: modelPath,
      position: vector.Vector3(0, 0, -1.5),
    );

    controller.addArCoreNode(node);
  }
}