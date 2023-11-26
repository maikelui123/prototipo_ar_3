import 'dart:io';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

class OCRService {
  final TextRecognizer textRecognizer = TextRecognizer();

  Future<String> detectText(File imageFile) async {
    final inputImage = InputImage.fromFile(imageFile);
    final RecognizedText recognizedText = await textRecognizer.processImage(inputImage);

    // Cerramos el reconocedor de texto para liberar recursos
    textRecognizer.close();

    // Devolvemos todo el texto detectado
    return recognizedText.text;
  }
}
