import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class CrearForoScreen extends StatefulWidget {
  @override
  _CrearForoScreenState createState() => _CrearForoScreenState();
}

class _CrearForoScreenState extends State<CrearForoScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _tituloController = TextEditingController();
  final TextEditingController _descripcionController = TextEditingController();
  String? _selectedCategoria;
  bool _isLoading = false;

  // Lista de categorías predefinidas
  final List<String> _categorias = [
    'Hardware',
    'Redes',
    'Software',
    'Seguridad',
    'Desarrollo',
    'Otros',
  ];

  // Método para crear un nuevo foro en Firestore
  Future<void> _crearForo() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      User? usuario = FirebaseAuth.instance.currentUser;
      if (usuario == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Debes estar autenticado para crear un foro.')),
        );
        setState(() {
          _isLoading = false;
        });
        return;
      }

      // Obtener el nombre completo del usuario
      DocumentSnapshot usuarioDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(usuario.uid)
          .get();

      String autorNombre = 'Usuario Desconocido';
      if (usuarioDoc.exists) {
        Map<String, dynamic> datos = usuarioDoc.data() as Map<String, dynamic>;
        autorNombre = '${datos['firstName']} ${datos['lastName']}';
      }

      // Crear el foro en Firestore
      await FirebaseFirestore.instance.collection('foros').add({
        'titulo': _tituloController.text.trim(),
        'descripcion': _descripcionController.text.trim(),
        'unidad': _selectedCategoria,
        'createdAt': FieldValue.serverTimestamp(),
        'autor': autorNombre, // Opcional: Puedes agregar el autor del foro
      });

      // Limpiar los campos del formulario
      _tituloController.clear();
      _descripcionController.clear();
      setState(() {
        _selectedCategoria = null;
        _isLoading = false;
      });

      // Mostrar mensaje de éxito y regresar a la pantalla anterior
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Foro creado exitosamente.')),
      );

      Navigator.of(context).pop();
    } catch (e) {
      print('Error al crear el foro: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al crear el foro. Inténtalo nuevamente.')),
      );
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _tituloController.dispose();
    _descripcionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Definir colores personalizados
    final Color customAppBarColor = Color(0xFF42F5EC);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Crear Nuevo Foro',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        backgroundColor: customAppBarColor,
        elevation: 4,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Campo de Título
              TextFormField(
                controller: _tituloController,
                decoration: InputDecoration(
                  labelText: 'Título del Foro',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Por favor, ingresa un título.';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),

              // Campo de Descripción
              TextFormField(
                controller: _descripcionController,
                decoration: InputDecoration(
                  labelText: 'Descripción del Foro',
                  border: OutlineInputBorder(),
                ),
                maxLines: 4,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Por favor, ingresa una descripción.';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),

              // Dropdown de Categoría
              DropdownButtonFormField<String>(
                value: _selectedCategoria,
                decoration: InputDecoration(
                  labelText: 'Categoría',
                  border: OutlineInputBorder(),
                ),
                items: _categorias.map((categoria) {
                  return DropdownMenuItem(
                    value: categoria,
                    child: Text(categoria),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedCategoria = value;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, selecciona una categoría.';
                  }
                  return null;
                },
              ),
              SizedBox(height: 24),

              // Botón de Envío
              Center(
                child: ElevatedButton.icon(
                  onPressed: _crearForo,
                  icon: Icon(Icons.send),
                  label: Text('Crear Foro'),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    textStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    backgroundColor: customAppBarColor, // Reemplazamos 'primary' por 'backgroundColor'
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
