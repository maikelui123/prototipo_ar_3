import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';

class EditProfileScreen extends StatefulWidget {
  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;
  final _picker = ImagePicker();
  File? _profileImage;
  String _firstName = '';
  String _lastName = '';
  String _phone = '';
  String _profilePictureUrl = '';
  bool _isLoading = false; // Indica si está cargando datos

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _loadUserData() async {
    setState(() {
      _isLoading = true;
    });

    final userId = _auth.currentUser?.uid;
    if (userId != null) {
      final userDoc = await _firestore.collection('users').doc(userId).get();
      if (userDoc.exists) {
        final data = userDoc.data();
        setState(() {
          _firstName = data?['firstName'] ?? '';
          _lastName = data?['lastName'] ?? '';
          _phone = data?['phone'] ?? '';
          _profilePictureUrl = data?['profilePictureUrl'] ?? '';
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 50,
    );
    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _saveProfile() async {
    if (_formKey.currentState?.validate() ?? false) {
      _formKey.currentState?.save();
      final userId = _auth.currentUser?.uid;

      setState(() {
        _isLoading = true;
      });

      try {
        if (_profileImage != null) {
          final storageRef = FirebaseStorage.instance
              .ref()
              .child('profile_pictures/$userId.jpg');
          await storageRef.putFile(_profileImage!);
          _profilePictureUrl = await storageRef.getDownloadURL();
        }

        await _firestore.collection('users').doc(userId).update({
          'firstName': _firstName,
          'lastName': _lastName,
          'phone': _phone,
          'profilePictureUrl': _profilePictureUrl,
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Perfil actualizado exitosamente')),
        );

        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al actualizar el perfil: $e')),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Colores personalizados
    final Color customAppBarColor = Color(0xFF42F5EC);
    Color lightBlue = Colors.lightBlue.shade100;
    Color darkBlue = Colors.blue.shade400;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Editar Perfil',
          style: TextStyle(
            color: Colors.lightBlue,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        backgroundColor: customAppBarColor,
        elevation: 10,
        iconTheme: IconThemeData(color: lightBlue),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Stack(
        children: [
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [lightBlue, darkBlue],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: _pickImage,
                      child: CircleAvatar(
                        radius: 60,
                        backgroundColor: Colors.white,
                        child: ClipOval(
                          child: _profileImage != null
                              ? Image.file(
                            _profileImage!,
                            width: 110,
                            height: 110,
                            fit: BoxFit.cover,
                          )
                              : _profilePictureUrl.isNotEmpty
                              ? Image.network(
                            _profilePictureUrl,
                            width: 110,
                            height: 110,
                            fit: BoxFit.cover,
                          )
                              : Image.asset(
                            'assets/images/default_avatar.png',
                            width: 110,
                            height: 110,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 16),
                    _buildTextField(
                      initialValue: _firstName,
                      labelText: 'Nombre',
                      icon: Icons.person,
                      validator: (value) => value?.isEmpty == true
                          ? 'Por favor ingresa tu nombre'
                          : null,
                      onSaved: (value) => _firstName = value ?? '',
                    ),
                    SizedBox(height: 16),
                    _buildTextField(
                      initialValue: _lastName,
                      labelText: 'Apellido',
                      icon: Icons.person_outline,
                      validator: (value) => value?.isEmpty == true
                          ? 'Por favor ingresa tu apellido'
                          : null,
                      onSaved: (value) => _lastName = value ?? '',
                    ),
                    SizedBox(height: 16),
                    _buildTextField(
                      initialValue: _phone,
                      labelText: 'Teléfono',
                      icon: Icons.phone,
                      keyboardType: TextInputType.phone,
                      validator: (value) => value?.isEmpty == true
                          ? 'Por favor ingresa tu número de teléfono'
                          : null,
                      onSaved: (value) => _phone = value ?? '',
                    ),
                    SizedBox(height: 30),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.blue.shade800,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(32.0),
                        ),
                        padding: EdgeInsets.symmetric(
                            horizontal: 32, vertical: 12),
                      ),
                      onPressed: _saveProfile,
                      child: Text(
                        'Guardar',
                        style: TextStyle(color: Colors.blue.shade800),
                      ),
                    ),
                    SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required String initialValue,
    required String labelText,
    required IconData icon,
    required FormFieldValidator<String> validator,
    required FormFieldSetter<String> onSaved,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextFormField(
      initialValue: initialValue,
      decoration: InputDecoration(
        hintText: labelText,
        hintStyle: TextStyle(color: Colors.grey.shade800),
        fillColor: Colors.white,
        filled: true,
        labelText: labelText,
        labelStyle: TextStyle(color: Colors.grey.shade800),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        prefixIcon: Icon(icon, color: Colors.grey.shade800),
      ),
      style: TextStyle(color: Colors.black),
      keyboardType: keyboardType,
      validator: validator,
      onSaved: onSaved,
    );
  }
}
