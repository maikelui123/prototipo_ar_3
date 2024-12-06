import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Importa FirebaseAuth
import 'package:intl/intl.dart'; // Para formatear fechas

class MensajesScreen extends StatefulWidget {
  final String foroId;
  final String foroTitulo;

  MensajesScreen({required this.foroId, required this.foroTitulo});

  @override
  _MensajesScreenState createState() => _MensajesScreenState();
}

class _MensajesScreenState extends State<MensajesScreen> {
  final TextEditingController _mensajeController = TextEditingController();
  String? autorNombre; // Variable para almacenar el nombre del autor
  bool isLoading = true; // Variable para manejar el estado de carga
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _obtenerNombreUsuario(); // Obtener el nombre del usuario al iniciar
  }

  // Método para obtener el nombre completo del usuario autenticado
  Future<void> _obtenerNombreUsuario() async {
    User? usuario = FirebaseAuth.instance.currentUser;
    if (usuario != null) {
      try {
        DocumentSnapshot documento = await FirebaseFirestore.instance
            .collection('users')
            .doc(usuario.uid)
            .get();

        if (documento.exists) {
          Map<String, dynamic> datos = documento.data() as Map<String, dynamic>;
          setState(() {
            autorNombre = '${datos['firstName']} ${datos['lastName']}';
            isLoading = false;
          });
        } else {
          setState(() {
            autorNombre = 'Usuario Desconocido';
            isLoading = false;
          });
        }
      } catch (e) {
        setState(() {
          autorNombre = 'Error al obtener el nombre';
          isLoading = false;
        });
        print('Error al obtener el nombre del usuario: $e');
      }
    } else {
      setState(() {
        autorNombre = 'Usuario No Autenticado';
        isLoading = false;
      });
    }
  }

  // Método para enviar un mensaje
  void _enviarMensaje() async {
    if (_mensajeController.text.trim().isEmpty || autorNombre == null) return;

    await FirebaseFirestore.instance
        .collection('foros')
        .doc(widget.foroId)
        .collection('mensajes')
        .add({
      'autor': autorNombre, // Usar el nombre completo del usuario
      'mensaje': _mensajeController.text.trim(),
      'createdAt': FieldValue.serverTimestamp(),
      'uid': FirebaseAuth.instance.currentUser?.uid, // Para identificar al usuario
    });

    _mensajeController.clear();

    // Desplazar la vista al último mensaje después de enviar
    _scrollToBottom();
  }

  // Método para desplazar la vista al final de la lista de mensajes
  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.minScrollExtent,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  // Método para formatear la fecha y hora
  String _formatearFecha(Timestamp timestamp) {
    DateTime fecha = timestamp.toDate();
    return DateFormat('dd/MM/yyyy hh:mm a').format(fecha);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.foroTitulo),
        backgroundColor: Colors.blue, // Puedes personalizar el color
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator()) // Muestra un spinner mientras se carga
          : Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('foros')
                  .doc(widget.foroId)
                  .collection('mensajes')
                  .orderBy('createdAt', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text("Error al cargar los mensajes"));
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                var mensajes = snapshot.data!.docs;

                // Desplazar al último mensaje cuando se actualiza la lista
                WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());

                return ListView.builder(
                  controller: _scrollController,
                  reverse: true, // Para que el ListView empiece desde abajo
                  itemCount: mensajes.length,
                  itemBuilder: (context, index) {
                    var mensaje = mensajes[index].data() as Map<String, dynamic>;
                    bool esAutor = mensaje['uid'] == FirebaseAuth.instance.currentUser?.uid;

                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                      child: Align(
                        alignment:
                        esAutor ? Alignment.centerRight : Alignment.centerLeft,
                        child: Column(
                          crossAxisAlignment: esAutor
                              ? CrossAxisAlignment.end
                              : CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (!esAutor)
                                  CircleAvatar(
                                    child: Text(mensaje['autor'][0].toUpperCase()),
                                    backgroundColor: Colors.blueAccent,
                                    foregroundColor: Colors.white,
                                    radius: 15,
                                  ),
                                SizedBox(width: 8),
                                Flexible(
                                  child: Container(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 8),
                                    decoration: BoxDecoration(
                                      color: esAutor
                                          ? Colors.blue.shade100
                                          : Colors.grey.shade200,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Column(
                                      crossAxisAlignment: esAutor
                                          ? CrossAxisAlignment.end
                                          : CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          mensaje['autor'] ?? 'Autor Desconocido',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black87,
                                          ),
                                        ),
                                        SizedBox(height: 4),
                                        Text(
                                          mensaje['mensaje'] ?? '',
                                          style: TextStyle(fontSize: 16),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                SizedBox(width: 8),
                                if (esAutor)
                                  CircleAvatar(
                                    child: Text(mensaje['autor'][0].toUpperCase()),
                                    backgroundColor: Colors.blueAccent,
                                    foregroundColor: Colors.white,
                                    radius: 15,
                                  ),
                              ],
                            ),
                            SizedBox(height: 2),
                            Text(
                              mensaje['createdAt'] != null
                                  ? _formatearFecha(mensaje['createdAt'])
                                  : "Sin fecha",
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Divider(height: 1),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
            color: Colors.white,
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _mensajeController,
                    decoration: InputDecoration(
                      hintText: "Escribe un mensaje...",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      contentPadding: EdgeInsets.symmetric(
                          horizontal: 16, vertical: 0),
                    ),
                  ),
                ),
                SizedBox(width: 8),
                FloatingActionButton(
                  onPressed: _enviarMensaje,
                  child: Icon(Icons.send),
                  backgroundColor: Colors.blue,
                  mini: true,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _mensajeController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}
