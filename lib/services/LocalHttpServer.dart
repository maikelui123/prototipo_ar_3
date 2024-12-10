import 'dart:io';
import 'package:path_provider/path_provider.dart';

class LocalHttpServer {
  static HttpServer? _server;
  static int port = 8080;

  static Future<void> startServer() async {
    if (_server == null) {
      _server = await HttpServer.bind(InternetAddress.loopbackIPv4, port);
      print('Servidor local iniciado en http://localhost:$port');

      _server!.listen((HttpRequest request) async {
        final path = request.uri.path.substring(1);
        final dir = await getApplicationDocumentsDirectory();
        final filePath = '${dir.path}/$path';
        final file = File(filePath);

        if (await file.exists()) {
          request.response.headers.contentType = ContentType.binary;
          await file.openRead().pipe(request.response);
        } else {
          request.response.statusCode = HttpStatus.notFound;
          request.response.write('Archivo no encontrado');
          await request.response.close();
        }
      });
    }
  }

  static String getFileUrl(String fileName) {
    return 'http://localhost:$port/$fileName';
  }
}
