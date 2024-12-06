import 'package:flutter/material.dart';
import '../utilities/CloudComputingScreen.dart';
import '../utilities/LicenciasScreen.dart';

class Unit2Screen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final Color customAppBarColor = Color(0xFF42F5EC);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Unidad 2: Sistemas Operativos',
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
          children: [
            // Descripción de la unidad
            Text(
              'Explora los temas de Sistemas Operativos con las siguientes secciones:',
              style: TextStyle(fontSize: 18, color: Colors.black87),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
            // Tarjetas de las secciones
            Expanded(
              child: GridView.count(
                crossAxisCount: 1, // Cambiado a 1 tarjeta por fila
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                children: [
                  _sectionCard(
                    context,
                    title: 'Computación en la Nube',
                    description: 'Aprende sobre servicios en la nube y su gestión.',
                    icon: Icons.cloud,
                    destination: CloudComputingScreen(),
                  ),
                  _sectionCard(
                    context,
                    title: 'Licencias',
                    description: 'Entiende los diferentes tipos de licencias de software.',
                    icon: Icons.assignment,
                    destination: LicenciasScreen(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionCard(
      BuildContext context, {
        required String title,
        required String description,
        required IconData icon,
        required Widget destination,
      }) {
    return Card(
      elevation: 5,
      color: Colors.green.shade100,
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
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 50, color: Colors.blue),
              SizedBox(height: 10),
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 8),
              Text(
                description,
                style: TextStyle(fontSize: 14, color: Colors.black54),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
