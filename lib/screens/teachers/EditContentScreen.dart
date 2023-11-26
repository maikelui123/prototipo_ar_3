import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';

class EditContentScreen extends StatefulWidget {
  final String componentId;

  EditContentScreen({Key? key, required this.componentId}) : super(key: key);

  @override
  _EditContentScreenState createState() => _EditContentScreenState();
}

class _EditContentScreenState extends State<EditContentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _descripcionController = TextEditingController();
  final _informacionModeloController = TextEditingController();
  final _keywordsController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  File? _imageFile;
  File? _modelFile;

  // Colores personalizados
  final Color lightBlue = Colors.lightBlue.shade100;
  final Color darkBlue = Colors.blue.shade400;

  @override
  void initState() {
    super.initState();
    _loadComponentData();
  }

  void _loadComponentData() async {
    var document = await FirebaseFirestore.instance.collection('componentesPC').doc(widget.componentId).get();
    if (document.exists) {
      var componente = document.data();
      if (componente != null) {
        setState(() {
          _nombreController.text = componente['nombre'];
          _descripcionController.text = componente['descripcion'];
          _informacionModeloController.text = componente['informacionModelo'];
          _keywordsController.text = componente['palabrasClave'].join(', ');
        });
      }
    }
  }

  Future<void> _pickImage() async {
    await _requestPermissions();
    final pickedImage = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedImage != null) {
      setState(() {
        _imageFile = File(pickedImage.path);
      });
    }
  }

  Future<void> _pickModel() async {
    await _requestPermissions();
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['gltf', 'glb', 'obj', 'fbx', 'dae'],
    );

    if (result != null && result.files.single.path != null) {
      setState(() {
        _modelFile = File(result.files.single.path!);
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se seleccionó un archivo de modelo 3D')),
      );
    }
  }

  Future<void> _requestPermissions() async {
    final status = await Permission.storage.request();
    if (!status.isGranted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Se requieren permisos de almacenamiento para esta operación.')),
      );
    }
  }

  Future<String> _uploadFile(File file, String path) async {
    Reference storageReference = FirebaseStorage.instance.ref().child(path);
    UploadTask uploadTask = storageReference.putFile(file);
    TaskSnapshot taskSnapshot = await uploadTask;
    return await taskSnapshot.ref.getDownloadURL();
  }

  Future<void> _updateComponent() async {
    if (_formKey.currentState!.validate()) {
      String imageUrl = '';
      String model3DUrl = '';
      if (_imageFile != null) {
        imageUrl = await _uploadFile(_imageFile!, 'images/${_imageFile!.path.split('/').last}');
      }
      if (_modelFile != null) {
        model3DUrl = await _uploadFile(_modelFile!, 'models/${_modelFile!.path.split('/').last}');
      }
      final keywordsList = _keywordsController.text.split(',').map((keyword) => keyword.trim()).toList();

      await FirebaseFirestore.instance.collection('componentesPC').doc(widget.componentId).update({
        'nombre': _nombreController.text,
        'descripcion': _descripcionController.text,
        'informacionModelo': _informacionModeloController.text,
        'palabrasClave': keywordsList,
        'imagen_url': imageUrl,
        'modelo3D_url': model3DUrl,
      });

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Componente actualizado con éxito')));
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('Editar Componente'),
        backgroundColor: darkBlue,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [lightBlue, darkBlue],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                _buildTextField(theme, _nombreController, 'Nombre del componente'),
                _buildTextField(theme, _descripcionController, 'Descripción'),
                _buildTextField(theme, _informacionModeloController, 'Información del Modelo'),
                _buildTextField(theme, _keywordsController, 'Palabras Clave (separadas por comas)'),
                SizedBox(height: 20),
                _buildButton(theme, _pickImage, 'Seleccionar imagen para el componente'),
                SizedBox(height: 20),
                _buildButton(theme, _pickModel, 'Seleccionar modelo 3D para el componente'),
                SizedBox(height: 20),
                _buildButton(theme, _updateComponent, 'Actualizar Componente', isPrimary: true),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(ThemeData theme, TextEditingController controller, String label) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
          filled: true,
          fillColor: lightBlue.withAlpha(50),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) return 'Este campo es obligatorio';
          return null;
        },
        style: TextStyle(fontSize: 16),
      ),
    );
  }

  Widget _buildButton(ThemeData theme, VoidCallback onPressed, String text, {bool isPrimary = false}) {
    return ElevatedButton(
      onPressed: onPressed,
      child: Text(text),
      style: ElevatedButton.styleFrom(
        primary: isPrimary ? darkBlue : lightBlue,
        onPrimary: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
        padding: EdgeInsets.symmetric(vertical: 12.0),
        textStyle: TextStyle(fontSize: 18),
        elevation: isPrimary ? 4 : 2,
      ),
    );
  }
}