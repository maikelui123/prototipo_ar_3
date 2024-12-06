import 'package:flutter/material.dart';
import '../models/ModelsOSIScreen.dart';
import '../utilities/NetworkTopologyScreen.dart'; // Importa la nueva pantalla

class Unit3Screen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final Color customAppBarColor = Color(0xFF42F5EC);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Unidad 3: Redes de Datos',
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
              'Profundiza en Redes de Datos con las siguientes secciones:',
              style: TextStyle(fontSize: 18, color: Colors.black87),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
            // Tarjetas de las secciones
            Expanded(
              child: GridView.count(
                crossAxisCount: 1,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                children: [
                  _sectionCard(
                    context,
                    title: 'Modelos OSI/TCP-IP',
                    description: 'Comprende la organización y tipos de redes.',
                    icon: Icons.network_wifi,
                    destination: ModelsOSIScreen(),
                  ),
                  _sectionCard(
                    context,
                    title: 'Organización de Redes',
                    description: 'Crea topologías simples con nodos y cables.',
                    icon: Icons.cable,
                    destination: NetworkTopologyScreen(), // Nuevo destino
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionCard(BuildContext context, {required String title, required String description, required IconData icon, required Widget destination}) {
    return Card(
      elevation: 5,
      color: Colors.orange.shade50,
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
              Icon(icon, size: 50, color: Colors.orange),
              SizedBox(height: 10),
              Text(
                title,
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87),
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
