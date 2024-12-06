import 'package:audioplayers/audioplayers.dart';

class BackgroundMusicService {
  static final AudioPlayer _audioPlayer = AudioPlayer();

  static Future<void> playMusic() async {
    await _audioPlayer.setVolume(0.5); // Ajusta el volumen a un nivel adecuado

    // Reproduce la música
    await _audioPlayer.play(AssetSource('music/musica.mp3'));

    // Escuchar cuando la música termina y reiniciarla
    _audioPlayer.onPlayerComplete.listen((event) {
      _audioPlayer.seek(Duration.zero); // Vuelve al inicio
      playMusic(); // Reproduce la música nuevamente
    });
  }

  static void stopMusic() {
    _audioPlayer.stop(); // Detiene la música
    // Es posible que también quieras limpiar el listener aquí, si es necesario
  }
}
