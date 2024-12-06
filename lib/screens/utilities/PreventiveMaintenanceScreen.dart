import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';


class PreventiveMaintenanceScreen extends StatefulWidget {
  @override
  _PreventiveMaintenanceScreenState createState() =>
      _PreventiveMaintenanceScreenState();
}

class _PreventiveMaintenanceScreenState
    extends State<PreventiveMaintenanceScreen> {
  // Lista de pasos con su estado (completado o no)
  List<Map<String, dynamic>> steps = [
    {
      "title": "Apaga la computadora y desconéctala.",
      "description": "Desconecta todos los cables para evitar daños eléctricos.",
      "completed": false,
      "animation": "assets/models/power_off.json"
    },
    {
      "title": "Revisa las conexiones de cables.",
      "description": "Asegúrate de que los cables estén firmemente conectados.",
      "completed": false,
      "animation": "assets/models/cable_check.json"
    },
    {
      "title": "Aplica pasta térmica al procesador.",
      "description": "Renueva la pasta térmica para mantener una temperatura óptima.",
      "completed": false,
      "animation": "assets/models/thermal_paste.json"
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Mantenimiento Preventivo",
          style: TextStyle(
            color: Colors.lightBlue,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        backgroundColor: Color(0xFF42F5EC),
      ),
      body: ListView.builder(
        itemCount: steps.length,
        itemBuilder: (context, index) {
          return _buildStepCard(index);
        },
      ),
    );
  }

  // Método para construir cada tarjeta de paso
  Widget _buildStepCard(int index) {
    final step = steps[index];

    return Card(
      elevation: 5,
      margin: EdgeInsets.all(16.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Animación de Lottie
            Lottie.asset(
              step["animation"],
              height: 150,
              fit: BoxFit.contain,
            ),
            SizedBox(height: 10),
            // Título del paso
            Text(
              step["title"],
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 10),
            // Descripción del paso
            Text(
              step["description"],
              style: TextStyle(fontSize: 14, color: Colors.black54),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
            // Botón para marcar como completado
            ElevatedButton.icon(
              onPressed: () {
                setState(() {
                  steps[index]["completed"] = !steps[index]["completed"];
                });
              },
              icon: Icon(
                step["completed"] ? Icons.check_circle : Icons.circle_outlined,
                color: step["completed"] ? Colors.green : Colors.grey,
              ),
              label: Text(
                step["completed"] ? "Completado" : "Marcar como Completado",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: step["completed"] ? Colors.green : Colors.blue,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
