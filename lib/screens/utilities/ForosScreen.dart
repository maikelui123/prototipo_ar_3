import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'MensajesScreen.dart'; // Asegúrate de que la ruta sea correcta
import 'package:intl/intl.dart'; // Para formatear fechas
import 'CrearForoScreen.dart'; // Importa CrearForoScreen

class ForosScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Foros de Discusión",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        backgroundColor: Colors.blueAccent, // Puedes personalizar el color
        elevation: 4,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('foros')
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text("Error al cargar los foros"));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          var foros = snapshot.data!.docs;

          if (foros.isEmpty) {
            return Center(child: Text("No hay foros disponibles."));
          }

          return ListView.builder(
            itemCount: foros.length,
            itemBuilder: (context, index) {
              var foro = foros[index].data() as Map<String, dynamic>;
              String titulo = foro['titulo'] ?? 'Sin Título';
              String descripcion = foro['descripcion'] ?? 'Sin Descripción';
              String unidad = foro['unidad'] ?? 'General';
              Timestamp? createdAt = foro['createdAt'];
              DateTime fechaCreacion = createdAt != null
                  ? createdAt.toDate()
                  : DateTime.now();
              String fechaFormateada =
              DateFormat('dd/MM/yyyy').format(fechaCreacion);

              // Obtener el número de mensajes en el foro
              return FutureBuilder<QuerySnapshot>(
                future: FirebaseFirestore.instance
                    .collection('foros')
                    .doc(foros[index].id)
                    .collection('mensajes')
                    .get(),
                builder: (context, mensajesSnapshot) {
                  if (mensajesSnapshot.connectionState ==
                      ConnectionState.waiting) {
                    return SizedBox(); // Mientras se cargan los mensajes, no mostramos nada
                  }

                  int numeroMensajes = mensajesSnapshot.data?.docs.length ?? 0;

                  return Padding(
                    padding:
                    const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                    child: Card(
                      elevation: 3,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(15),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => MensajesScreen(
                                foroId: foros[index].id,
                                foroTitulo: titulo,
                              ),
                            ),
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Título del Foro
                              Text(
                                titulo,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 8),
                              // Descripción del Foro
                              Text(
                                descripcion,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                              ),
                              SizedBox(height: 8),
                              // Categoría y Fecha
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  // Categoría del Foro
                                  Chip(
                                    label: Text(
                                      unidad,
                                      style: TextStyle(
                                        color: Colors.white,
                                      ),
                                    ),
                                    backgroundColor: Colors.blueAccent,
                                  ),
                                  // Fecha de Creación
                                  Text(
                                    fechaFormateada,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 8),
                              // Número de Mensajes
                              Row(
                                children: [
                                  Icon(
                                    Icons.message,
                                    size: 16,
                                    color: Colors.grey[600],
                                  ),
                                  SizedBox(width: 4),
                                  Text(
                                    '$numeroMensajes Mensaje${numeroMensajes != 1 ? 's' : ''}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navegar a CrearForoScreen
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => CrearForoScreen()),
          );
        },
        child: Icon(Icons.add_comment),
        backgroundColor: Colors.blueAccent,
        tooltip: 'Crear Nuevo Foro',
      ),
    );
  }
}
