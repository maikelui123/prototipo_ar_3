import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import 'PrivacyPolicyScreen.dart'; // Importa la pantalla de política de privacidad
import 'package:email_validator/email_validator.dart'; // Para validar el email
import 'package:flutter/services.dart'; // Para limitar input de campos
import 'package:firebase_auth/firebase_auth.dart'; // Para la verificación de email

class RegistroScreen extends StatefulWidget {
  @override
  _RegistroScreenState createState() => _RegistroScreenState();
}

class _RegistroScreenState extends State<RegistroScreen> {
  final _formKey = GlobalKey<FormState>();
  final AuthService _authService = AuthService();
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  String _email = '';
  String _password = '';
  String _confirmPassword = '';
  String _nombre = '';
  String _apellido = '';
  String _telefono = '';
  String _role = 'alumno';
  bool _acceptedPrivacyPolicy = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final Color customAppBarColor = Colors.blue.shade400;

    return Scaffold(
      appBar: AppBar(
        title: Text('Registro'),
        backgroundColor: customAppBarColor,
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue.shade300, Colors.blue.shade500],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Stack(
          children: [
            // Fondo decorativo
            Positioned(
              top: -100,
              left: -50,
              child: CircleAvatar(
                radius: 150,
                backgroundColor: Colors.white.withOpacity(0.1),
              ),
            ),
            Positioned(
              bottom: -150,
              right: -100,
              child: CircleAvatar(
                radius: 200,
                backgroundColor: Colors.white.withOpacity(0.1),
              ),
            ),
            Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Card(
                  elevation: 8,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Text(
                            'Crear una cuenta',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue.shade800,
                            ),
                          ),
                          SizedBox(height: 20),
                          // Campo de Email con validación detallada
                          _buildEmailField(),
                          SizedBox(height: 20),
                          // Campo de Nombre
                          _buildNameField(),
                          SizedBox(height: 20),
                          // Campo de Apellido
                          _buildLastNameField(),
                          SizedBox(height: 20),
                          // Campo de Teléfono modificado
                          _buildPhoneField(),
                          SizedBox(height: 20),
                          // Campo de Rol
                          _buildRoleField(),
                          SizedBox(height: 20),
                          // Campo de Contraseña con indicador de fortaleza
                          _buildPasswordField(),
                          SizedBox(height: 20),
                          // Campo de Confirmar Contraseña
                          _buildConfirmPasswordField(),
                          SizedBox(height: 20),
                          // Casilla de verificación para la Política de Privacidad
                          _buildPrivacyPolicyCheckbox(),
                          SizedBox(height: 30),
                          // Botón de Registro con indicador de carga
                          _buildRegisterButton(),
                          SizedBox(height: 20),
                          _buildLoginRedirect(),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Métodos separados para construir cada campo, mejorando la legibilidad
  Widget _buildEmailField() {
    return TextFormField(
      decoration: _inputDecoration(
        hintText: 'Email',
        icon: Icons.email,
        isValid: _email.isNotEmpty && EmailValidator.validate(_email),
      ),
      style: TextStyle(color: Colors.black),
      keyboardType: TextInputType.emailAddress,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'El campo de correo no puede estar vacío.';
        }
        if (!EmailValidator.validate(value)) {
          return 'Ingresa un formato de correo válido (ej. usuario@dominio.com).';
        }
        return null;
      },
      onChanged: (value) {
        setState(() {
          _email = value;
        });
      },
    );
  }

  Widget _buildNameField() {
    return TextFormField(
      decoration: _inputDecoration(
        hintText: 'Nombre',
        icon: Icons.person,
        isValid: _nombre.isNotEmpty && _nombre.length >= 2,
      ),
      style: TextStyle(color: Colors.black),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp("[a-zA-ZñÑáéíóúÁÉÍÓÚ ]")),
      ],
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Por favor ingresa tu nombre';
        }
        if (value.length < 2) {
          return 'El nombre debe tener al menos 2 caracteres';
        }
        return null;
      },
      onChanged: (value) {
        setState(() {
          _nombre = value;
        });
      },
    );
  }

  Widget _buildLastNameField() {
    return TextFormField(
      decoration: _inputDecoration(
        hintText: 'Apellido',
        icon: Icons.person_outline,
        isValid: _apellido.isNotEmpty && _apellido.length >= 2,
      ),
      style: TextStyle(color: Colors.black),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp("[a-zA-ZñÑáéíóúÁÉÍÓÚ ]")),
      ],
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Por favor ingresa tu apellido';
        }
        if (value.length < 2) {
          return 'El apellido debe tener al menos 2 caracteres';
        }
        return null;
      },
      onChanged: (value) {
        setState(() {
          _apellido = value;
        });
      },
    );
  }

  Widget _buildPhoneField() {
    return TextFormField(
      decoration: _inputDecoration(
        hintText: 'XXXXXXXX',
        icon: Icons.phone,
        prefixText: '+569 ',
        isValid: _telefono.length == 12,
      ),
      style: TextStyle(color: Colors.black),
      keyboardType: TextInputType.number,
      maxLength: 8,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
      ],
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Por favor ingresa tu teléfono';
        }
        if (!RegExp(r'^\d{8}$').hasMatch(value)) {
          return 'Ingresa los 8 dígitos del número (sin incluir el prefijo)';
        }
        return null;
      },
      onChanged: (value) {
        setState(() {
          _telefono = '+569$value';
        });
      },
    );
  }

  Widget _buildRoleField() {
    return DropdownButtonFormField(
      value: _role,
      items: ['alumno', 'profesor']
          .map((label) => DropdownMenuItem(
        child: Text(
          label,
          style: TextStyle(color: Colors.black),
        ),
        value: label,
      ))
          .toList(),
      onChanged: (value) {
        if (value is String) {
          setState(() => _role = value);
        }
      },
      decoration: _inputDecoration(
        hintText: 'Selecciona tu rol',
        icon: Icons.school,
        isValid: true,
      ),
    );
  }

  Widget _buildPasswordField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          decoration: _inputDecoration(
            hintText: 'Contraseña',
            icon: Icons.lock,
            isValid:
            _password.isNotEmpty && _evaluatePasswordStrength(_password) != 'Muy débil',
            suffixIcon: IconButton(
              icon: Icon(
                _obscurePassword ? Icons.visibility_off : Icons.visibility,
                color: Colors.grey.shade800,
              ),
              onPressed: () {
                setState(() {
                  _obscurePassword = !_obscurePassword;
                });
              },
            ),
          ),
          style: TextStyle(color: Colors.black),
          obscureText: _obscurePassword,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Por favor ingresa una contraseña';
            }
            if (value.length < 8) {
              return 'La contraseña debe tener al menos 8 caracteres';
            }
            if (!RegExp(r'(?=.*?[A-Z])').hasMatch(value)) {
              return 'Debe incluir al menos una mayúscula';
            }
            if (!RegExp(r'(?=.*?[a-z])').hasMatch(value)) {
              return 'Debe incluir al menos una minúscula';
            }
            if (!RegExp(r'(?=.*?[0-9])').hasMatch(value)) {
              return 'Debe incluir al menos un número';
            }
            if (!RegExp(r'(?=.*?[#?!@$%^&*-])').hasMatch(value)) {
              return 'Debe incluir al menos un carácter especial';
            }
            return null;
          },
          onChanged: (value) {
            setState(() {
              _password = value;
            });
          },
        ),
        SizedBox(height: 10),
        Text(
          'Fortaleza de la contraseña: ${_evaluatePasswordStrength(_password)}',
          style: TextStyle(
            color: _getPasswordStrengthColor(_password),
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildConfirmPasswordField() {
    return TextFormField(
      decoration: _inputDecoration(
        hintText: 'Confirmar Contraseña',
        icon: Icons.lock_outline,
        isValid: _confirmPassword.isNotEmpty && _confirmPassword == _password,
        suffixIcon: IconButton(
          icon: Icon(
            _obscureConfirmPassword ? Icons.visibility_off : Icons.visibility,
            color: Colors.grey.shade800,
          ),
          onPressed: () {
            setState(() {
              _obscureConfirmPassword = !_obscureConfirmPassword;
            });
          },
        ),
      ),
      style: TextStyle(color: Colors.black),
      obscureText: _obscureConfirmPassword,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Por favor confirma tu contraseña';
        }
        if (value != _password) {
          return 'Las contraseñas no coinciden';
        }
        return null;
      },
      onChanged: (value) {
        setState(() {
          _confirmPassword = value;
        });
      },
    );
  }

  Widget _buildPrivacyPolicyCheckbox() {
    return Row(
      children: [
        Checkbox(
          value: _acceptedPrivacyPolicy,
          onChanged: (bool? value) {
            setState(() {
              _acceptedPrivacyPolicy = value ?? false;
            });
          },
        ),
        Expanded(
          child: GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => PrivacyPolicyScreen()),
              );
            },
            child: RichText(
              text: TextSpan(
                text: 'He leído y acepto la ',
                style: TextStyle(color: Colors.black, fontSize: 14),
                children: [
                  TextSpan(
                    text: 'Política de Privacidad',
                    style: TextStyle(
                      color: Colors.blue,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRegisterButton() {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blue.shade800,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(32.0),
        ),
        padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
      ),
      onPressed: _isLoading
          ? null
          : () async {
        if (!_acceptedPrivacyPolicy) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                  'Debes aceptar la política de privacidad para registrarte.'),
            ),
          );
          return;
        }
        if (_formKey.currentState!.validate()) {
          setState(() {
            _isLoading = true;
          });
          try {
            String? errorMessage = await _authService.registrarConEmailYPassword(
              _email,
              _password,
              _role,
              _nombre,
              _apellido,
              _telefono,
            );
            if (errorMessage == null) {
              // Enviar correo de verificación
              User? user = _firebaseAuth.currentUser;
              if (user != null && !user.emailVerified) {
                await user.sendEmailVerification();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                        'Se ha enviado un correo para verificar tu cuenta.'),
                  ),
                );
              }
              // Redirige al usuario a la pantalla de inicio de sesión
              Navigator.pushReplacementNamed(context, '/login');
            } else {
              // Mostrar el mensaje de error específico
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(errorMessage),
                ),
              );
            }
          } catch (e) {
            // Captura cualquier excepción y muestra el mensaje de error
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error durante el registro: $e'),
              ),
            );
          } finally {
            setState(() {
              _isLoading = false;
            });
          }
        }
      },
      child: _isLoading
          ? CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
      )
          : Text(
        'Registrarse',
        style: TextStyle(fontSize: 16),
      ),
    );
  }

  Widget _buildLoginRedirect() {
    return GestureDetector(
      onTap: () {
        Navigator.pushReplacementNamed(context, '/login');
      },
      child: Text(
        '¿Ya tienes una cuenta? Inicia sesión',
        style: TextStyle(
          color: Colors.blue.shade800,
          decoration: TextDecoration.underline,
        ),
      ),
    );
  }

  // Función para crear InputDecoration consistente
  InputDecoration _inputDecoration({
    required String hintText,
    required IconData icon,
    bool isValid = true,
    String? prefixText,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      hintText: hintText,
      prefixText: prefixText,
      hintStyle: TextStyle(color: Colors.grey.shade800),
      fillColor: Colors.grey.shade200,
      filled: true,
      errorStyle: TextStyle(color: Colors.redAccent),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      prefixIcon: Icon(icon, color: Colors.grey.shade800),
      suffixIcon: suffixIcon,
      contentPadding: EdgeInsets.symmetric(vertical: 18, horizontal: 16),
    );
  }

  // Evaluar la fortaleza de la contraseña
  String _evaluatePasswordStrength(String password) {
    if (password.isEmpty) return 'Muy débil';
    if (password.length < 6) return 'Muy débil';
    int strength = 0;
    if (RegExp(r'.*[A-Z].*').hasMatch(password)) strength++;
    if (RegExp(r'.*[a-z].*').hasMatch(password)) strength++;
    if (RegExp(r'.*[0-9].*').hasMatch(password)) strength++;
    if (RegExp(r'.*[#?!@$%^&*-].*').hasMatch(password)) strength++;
    if (password.length >= 8) strength++;

    switch (strength) {
      case 1:
        return 'Muy débil';
      case 2:
        return 'Débil';
      case 3:
        return 'Aceptable';
      case 4:
        return 'Fuerte';
      case 5:
        return 'Muy fuerte';
      default:
        return 'Muy débil';
    }
  }

  // Obtener color según fortaleza de contraseña
  Color _getPasswordStrengthColor(String password) {
    String strength = _evaluatePasswordStrength(password);
    switch (strength) {
      case 'Muy débil':
        return Colors.red;
      case 'Débil':
        return Colors.orange;
      case 'Aceptable':
        return Colors.yellow.shade700;
      case 'Fuerte':
        return Colors.lightGreen;
      case 'Muy fuerte':
        return Colors.green;
      default:
        return Colors.red;
    }
  }
}
