import 'package:flutter/material.dart';
import 'ModelViewerScreen.dart'; // Pantalla para visualizar modelos

class MedidasSeguridadScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final Color customAppBarColor = Color(0xFF42F5EC);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Physical Security Measures',
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
            // Descripción de la sección
            Text(
              'Explora los componentes de computadoras personales con los siguientes modelos interactivos:',
              style: TextStyle(fontSize: 18, color: Colors.black87),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
            // Tarjetas para cada modelo
            Expanded(
              child: GridView.count(
                crossAxisCount: 1, // Una sola columna para mejor visibilidad
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                children: [
                  _sectionCard(
                    context,
                    title: 'Motherboard',
                    description: 'Explora el modelo interactivo de una placa base.',
                    icon: Icons.developer_board,
                    modelPath: 'assets/models/motherboard.glb',
                  ),
                  _sectionCard(
                    context,
                    title: 'CPU',
                    description: 'Descubre cómo luce un procesador por dentro.',
                    icon: Icons.computer,
                    modelPath: 'assets/models/CPU.glb',
                  ),
                  _sectionCard(
                    context,
                    title: 'RAM',
                    description: 'Explora los módulos de memoria RAM.',
                    icon: Icons.storage,
                    modelPath: 'assets/models/RAM.glb',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionCard(BuildContext context,
      {required String title,
        required String description,
        required IconData icon,
        required String modelPath}) {
    return Card(
      elevation: 5,
      color: Colors.blue.shade50,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ModelViewerScreen(
                modelPath: modelPath,
                title: title,
              ),
            ),
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
