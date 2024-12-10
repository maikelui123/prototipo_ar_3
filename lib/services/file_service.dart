import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class FileService {
  // Descarga un modelo con progreso
  Future<String> downloadModel(String url, String fileName, Function(double) onProgress) async {
    try {
      final request = http.Request('GET', Uri.parse(url));
      final response = await http.Client().send(request);

      if (response.statusCode == 200) {
        final contentLength = response.contentLength ?? 0;
        int bytesDownloaded = 0;

        final directory = await getApplicationDocumentsDirectory();
        final filePath = '${directory.path}/$fileName';
        final file = File(filePath);

        final sink = file.openWrite();
        await response.stream.forEach((chunk) {
          bytesDownloaded += chunk.length;
          sink.add(chunk);
          // Emitir progreso (bytes descargados / total)
          if (contentLength > 0) {
            onProgress(bytesDownloaded / contentLength);
          }
        });
        await sink.close();

        return filePath;
      } else {
        throw Exception('Error descargando el modelo. Código: ${response.statusCode}');
      }
    } catch (e) {
      print('Error al descargar modelo: $e');
      throw e;
    }
  }

  // Verifica si el modelo existe localmente, si no, lo descarga (si hay internet)
  // Aquí se llama a downloadModel con un callback vacío para onProgress,
  // puedes reemplazarlo por una función que actualice el estado de la UI.
  Future<String> getModelPath(String url, String fileName) async {
    final directory = await getApplicationDocumentsDirectory();
    final filePath = '${directory.path}/$fileName';
    final file = File(filePath);

    if (await file.exists()) {
      // El archivo ya existe localmente
      return filePath;
    } else {
      // El archivo no existe localmente, verificamos la conexión
      var connectivityResult = await (Connectivity().checkConnectivity());
      if (connectivityResult == ConnectivityResult.none) {
        // No hay conexión a Internet
        throw Exception('No hay conexión a Internet para descargar el modelo.');
      } else {
        // Hay conexión, descargamos el modelo con un callback vacío de progreso
        return await downloadModel(url, fileName, (progress) {});
      }
    }
  }
}
