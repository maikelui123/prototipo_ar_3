import 'package:flutter/material.dart';
// import 'Modelos3DScreen.dart'; // Pantalla para Modelos 3D interactivos (Aún no creada)
import '../utilities/PreventiveMaintenanceScreen.dart';
import '../utilities/MedidasSeguridadScreen.dart'; // Pantalla para Physical Security Measures

class Unit1Screen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final Color customAppBarColor = Color(0xFF42F5EC);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Unidad 1: Computadoras Personales',
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
              'Explora los temas de Computadoras Personales con las siguientes secciones:',
              style: TextStyle(fontSize: 18, color: Colors.black87),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
            // Tarjetas para cada sección
            Expanded(
              child: GridView.count(
                crossAxisCount: 1, // Una sola columna
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                children: [
                  // Comentar esta tarjeta hasta que se cree la pantalla correspondiente
                  // _sectionCard(
                  //   context,
                  //   title: 'Modelos 3D Interactivos',
                  //   description: 'Explora componentes como motherboard, tarjeta gráfica y CPU.',
                  //   icon: Icons.developer_board,
                  //   destination: Modelos3DScreen(),
                  // ),
                  _sectionCard(
                    context,
                    title: 'Medidas de seguridad física', // Nombre en inglés
                    description: 'Aprenda a proteger componentes sensibles.',
                    icon: Icons.shield,
                    destination: MedidasSeguridadScreen(),
                  ),
                   _sectionCard(
                     context,
                     title: 'Mantenimiento Preventivo',
                     description: 'Guías para mantener tus dispositivos en óptimas condiciones.',
                     icon: Icons.build,
                     destination: PreventiveMaintenanceScreen(),
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
      color: Colors.blue.shade50,
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
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
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
