import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';

class ContentManagementScreen extends StatefulWidget {
  @override
  _ContentManagementScreenState createState() => _ContentManagementScreenState();
}

class _ContentManagementScreenState extends State<ContentManagementScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _descripcionController = TextEditingController();
  final _informacionModeloController = TextEditingController();
  final _keywordsController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  File? _imageFile;
  File? _modelFile;

  final Color lightBlue = Colors.lightBlue.shade100;
  final Color darkBlue = Colors.blue.shade400;

  @override
  void dispose() {
    _nombreController.dispose();
    _descripcionController.dispose();
    _informacionModeloController.dispose();
    _keywordsController.dispose();
    super.dispose();
  }

  Future<void> _requestPermissions() async {
    final status = await Permission.storage.request();
    if (!status.isGranted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Se requieren permisos de almacenamiento para esta operación.')),
      );
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
      allowedExtensions: ['gltf', 'glb', 'obj', 'fbx', 'dae'], // Sin puntos delante
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


  Future<String> _uploadFile(File file, String path) async {
    Reference storageReference = FirebaseStorage.instance.ref().child(path);
    UploadTask uploadTask = storageReference.putFile(file);
    TaskSnapshot taskSnapshot = await uploadTask;
    return await taskSnapshot.ref.getDownloadURL();
  }

  Future<void> _saveComponent() async {
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

      await FirebaseFirestore.instance.collection('componentesPC').add({
        'nombre': _nombreController.text,
        'descripcion': _descripcionController.text,
        'informacionModelo': _informacionModeloController.text,
        'palabrasClave': keywordsList,
        'imagen_url': imageUrl,
        'modelo3D_url': model3DUrl,
      });

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Componente guardado con éxito')));
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Gestión de Contenidos'),
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
        child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints viewportConstraints) {
            return SingleChildScrollView(
              padding: EdgeInsets.all(16.0),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: viewportConstraints.maxHeight,
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildTextField(_nombreController, 'Nombre del componente'),
                      _buildTextField(_descripcionController, 'Descripción'),
                      _buildTextField(_informacionModeloController, 'Información del Modelo'),
                      _buildTextField(_keywordsController, 'Palabras Clave (separadas por comas)'),
                      _buildImagePickerButton(),
                      _buildModelPickerButton(),
                      _buildSaveButton(),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(),
        ),
        validator: (value) => value != null && value.isNotEmpty ? null : 'Este campo es obligatorio',
      ),
    );
  }

  Widget _buildImagePickerButton() {
    return ElevatedButton(
      onPressed: _pickImage,
      child: Text('Seleccionar imagen para el componente'),
      style: ElevatedButton.styleFrom(primary: darkBlue),
    );
  }

  Widget _buildModelPickerButton() {
    return ElevatedButton(
      onPressed: _pickModel,
      child: Text('Seleccionar modelo 3D para el componente'),
      style: ElevatedButton.styleFrom(primary: darkBlue),
    );
  }

  Widget _buildSaveButton() {
    return ElevatedButton(
      onPressed: _saveComponent,
      child: Text('Guardar Componente'),
      style: ElevatedButton.styleFrom(primary: darkBlue),
    );
  }
}