import 'package:flutter/material.dart';

class ModelsOSIScreen extends StatefulWidget {
  @override
  _ModelsOSIScreenState createState() => _ModelsOSIScreenState();
}

class _ModelsOSIScreenState extends State<ModelsOSIScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<Map<String, String>> osiModel = [
    {
      "name": "Capa de Aplicación",
      "description": "Proporciona servicios directamente a las aplicaciones.",
      "example": "Ejemplo: HTTP, FTP."
    },
    {
      "name": "Capa de Presentación",
      "description": "Traduce los datos al formato que entienden las aplicaciones.",
      "example": "Ejemplo: Cifrado, Compresión."
    },
    {
      "name": "Capa de Sesión",
      "description": "Gestiona las conexiones entre aplicaciones.",
      "example": "Ejemplo: Sesiones de inicio y cierre."
    },
    {
      "name": "Capa de Transporte",
      "description": "Garantiza la transmisión confiable de datos.",
      "example": "Ejemplo: TCP, UDP."
    },
    {
      "name": "Capa de Red",
      "description": "Gestiona el direccionamiento y el enrutamiento de datos.",
      "example": "Ejemplo: Protocolo IP."
    },
    {
      "name": "Capa de Enlace de Datos",
      "description": "Proporciona transferencia de datos entre nodos conectados.",
      "example": "Ejemplo: Ethernet."
    },
    {
      "name": "Capa Física",
      "description": "Encargada de la transmisión de bits a través de medios físicos.",
      "example": "Ejemplo: Cables de fibra óptica."
    },
  ];

  final List<Map<String, String>> tcpIpModel = [
    {
      "name": "Capa de Aplicación",
      "description": "Combina las capas de aplicación, presentación y sesión del modelo OSI.",
      "example": "Ejemplo: HTTP, FTP, SMTP."
    },
    {
      "name": "Capa de Transporte",
      "description": "Proporciona comunicación de extremo a extremo y control de flujo.",
      "example": "Ejemplo: TCP, UDP."
    },
    {
      "name": "Capa de Internet",
      "description": "Encargada del direccionamiento y enrutamiento de paquetes.",
      "example": "Ejemplo: IP, ICMP."
    },
    {
      "name": "Capa de Acceso a Red",
      "description": "Gestiona la interfaz con el hardware de red y la transmisión física de datos.",
      "example": "Ejemplo: Ethernet, Wi-Fi."
    },
  ];

  final List<Color> osiColors = [
    Colors.red.shade200,
    Colors.orange.shade200,
    Colors.yellow.shade200,
    Colors.green.shade200,
    Colors.blue.shade200,
    Colors.indigo.shade200,
    Colors.purple.shade200,
  ];

  final List<Color> tcpIpColors = [
    Colors.purple.shade200,
    Colors.blue.shade200,
    Colors.green.shade200,
    Colors.orange.shade200,
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Widget _buildModelTab(List<Map<String, String>> modelData, List<Color> colors) {
    return SingleChildScrollView(
      child: Column(
        children: modelData.asMap().entries.map((entry) {
          int index = entry.key;
          Map<String, String> layer = entry.value;
          return GestureDetector(
            onTap: () {
              _showLayerDetails(
                context,
                layer["name"]!,
                layer["description"]!,
                layer["example"]!,
              );
            },
            child: Container(
              height: 80,
              margin: EdgeInsets.symmetric(vertical: 4, horizontal: 16),
              decoration: BoxDecoration(
                color: colors[index],
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.shade400,
                    offset: Offset(0, 2),
                    blurRadius: 4,
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  layer["name"]!,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    color: Colors.grey.shade800,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final Color customAppBarColor = Color(0xFF42F5EC);

    return Scaffold(
      appBar: AppBar(
        title: Text("Modelos OSI y TCP/IP"),
        backgroundColor: customAppBarColor,
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: "Modelo OSI"),
            Tab(text: "Modelo TCP/IP"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildModelTab(osiModel, osiColors),
          _buildModelTab(tcpIpModel, tcpIpColors),
        ],
      ),
    );
  }

  void _showLayerDetails(BuildContext context, String name, String description, String example) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(name),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(description, style: TextStyle(fontSize: 16)),
                SizedBox(height: 16),
                Text(example, style: TextStyle(fontSize: 14, fontStyle: FontStyle.italic)),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: Text("Cerrar"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
