import 'package:flutter/material.dart';
import 'dart:async';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

  @override
  void initState() {
    super.initState();
    Timer(Duration(seconds: 3), () {
      Navigator.of(context).pushReplacementNamed('/home');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Fondo negro
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            // Ajusta el tamaño del logo a un 60% del ancho de la pantalla, por ejemplo
            Image.asset('assets/images/logo.png', width: MediaQuery.of(context).size.width * 0.6),
            SizedBox(height: 24),
            // Indicador de progreso verde limón
            CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.lime)),
          ],
        ),
      ),
    );
  }
}
