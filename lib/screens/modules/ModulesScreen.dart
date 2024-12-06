import 'package:flutter/material.dart';
import 'Unit1Screen.dart';
import 'Unit2Screen.dart';
import 'Unit3Screen.dart';

class ModulesScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final Color customAppBarColor = Color(0xFF42F5EC);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Módulos de la Asignatura',
          style: TextStyle(
            color: Colors.lightBlue,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        backgroundColor: customAppBarColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _moduleCard(
              context,
              title: 'Unidad 1: Computadoras Personales',
              description: 'Modelos 3D interactivos, medidas de seguridad y mantenimiento preventivo.',
              color: Colors.blue.shade100,
              destination: Unit1Screen(),
            ),
            SizedBox(height: 16),
            _moduleCard(
              context,
              title: 'Unidad 2: Sistemas Operativos',
              description: 'Escaneo de logos, licencias y computación en la nube.',
              color: Colors.green.shade100,
              destination: Unit2Screen(),
            ),
            SizedBox(height: 16),
            _moduleCard(
              context,
              title: 'Unidad 3: Redes de Datos',
              description: 'Organización de redes, modelos OSI/TCP/IP y tipos de redes.',
              color: Colors.orange.shade100,
              destination: Unit3Screen(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _moduleCard(BuildContext context,
      {required String title,
        required String description,
        required Color color,
        required Widget destination}) {
    return Card(
      elevation: 5,
      color: color,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => destination),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                description,
                style: TextStyle(fontSize: 14, color: Colors.black87),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
