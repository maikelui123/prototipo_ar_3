import 'package:flutter/material.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Colores personalizados
    final Color primaryColor = Color(0xFF42A5F5);
    final Color secondaryColor = Colors.white;
    final Color accentColor = Color(0xFF1E88E5);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Política de Privacidad",
          style: TextStyle(
            color: secondaryColor,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        backgroundColor: primaryColor,
        iconTheme: IconThemeData(color: secondaryColor),
        centerTitle: true,
        elevation: 0,
      ),
      body: Container(
        color: secondaryColor,
        child: Stack(
          children: [
            // Fondo decorativo
            Positioned(
              top: -100,
              left: -50,
              child: CircleAvatar(
                radius: 150,
                backgroundColor: primaryColor.withOpacity(0.2),
              ),
            ),
            Positioned(
              bottom: -150,
              right: -100,
              child: CircleAvatar(
                radius: 200,
                backgroundColor: primaryColor.withOpacity(0.2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Encabezado con logo
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.privacy_tip,
                          color: primaryColor,
                          size: 50,
                        ),
                      ],
                    ),
                    SizedBox(height: 20),
                    _sectionTitle("Introducción", primaryColor),
                    _sectionContent(
                        "En MaikAR, estamos comprometidos con la protección de la privacidad de nuestros usuarios y el cumplimiento de la Ley Nº 19.628 sobre Protección de la Vida Privada en Chile. Esta política describe cómo recolectamos, usamos, almacenamos y protegemos los datos personales de nuestros usuarios."),
                    SizedBox(height: 20),
                    _sectionTitle("Recolección de Datos Personales", primaryColor),
                    _sectionContent(
                        "Recolectamos los siguientes datos personales para proporcionar y mejorar nuestros servicios:"),
                    _bulletPoint("Datos de Registro: Nombre, correo electrónico, contraseña y número de teléfono."),
                    _bulletPoint("Datos de Uso: Información sobre cómo interactúas con la aplicación, incluyendo términos de búsqueda y acciones realizadas."),
                    _bulletPoint("Otros Datos: Información proporcionada voluntariamente por el usuario, como retroalimentación o preguntas."),
                    SizedBox(height: 20),
                    _sectionTitle("Uso de Datos Personales", primaryColor),
                    _sectionContent(
                        "Los datos personales serán utilizados únicamente para los siguientes propósitos:"),
                    _bulletPoint("Proveer y personalizar los servicios ofrecidos en la aplicación."),
                    _bulletPoint("Mejorar la experiencia del usuario mediante análisis de datos."),
                    _bulletPoint("Comunicarnos con los usuarios para enviar actualizaciones, soporte técnico o información relevante."),
                    _bulletPoint("Cumplir con obligaciones legales y regulatorias."),
                    SizedBox(height: 20),
                    _sectionTitle("Consentimiento", primaryColor),
                    _sectionContent(
                        "El tratamiento de los datos personales se realiza solo con el consentimiento explícito del usuario, recolectado en el momento del registro o cuando sea necesario para una funcionalidad específica. Los usuarios pueden retirar su consentimiento en cualquier momento contactándonos a través de los medios proporcionados."),
                    SizedBox(height: 20),
                    _sectionTitle("Derechos de los Titulares de Datos", primaryColor),
                    _sectionContent(
                        "De acuerdo con la Ley Nº 19.628, los usuarios tienen los siguientes derechos:"),
                    _bulletPoint("Acceso: Solicitar información sobre los datos personales recolectados y tratados."),
                    _bulletPoint("Rectificación: Corregir datos incorrectos, incompletos o desactualizados."),
                    _bulletPoint("Cancelación: Solicitar la eliminación de sus datos personales cuando no sean necesarios para los fines para los que fueron recolectados."),
                    _bulletPoint("Oposición: Negarse al tratamiento de sus datos en ciertos casos especificados por la ley."),
                    _sectionContent(
                        "Para ejercer estos derechos, los usuarios pueden enviar una solicitud a nuestro correo electrónico:"),
                    GestureDetector(
                      onTap: () {
                        // Implementar acción para enviar correo electrónico
                      },
                      child: Text(
                        "maikel.quisbert@inacapmail.cl",
                        style: TextStyle(
                          color: accentColor,
                          decoration: TextDecoration.underline,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    _sectionTitle("Transferencia de Datos a Terceros", primaryColor),
                    _sectionContent(
                        "No compartimos los datos personales de los usuarios con terceros sin su consentimiento, salvo en los siguientes casos:"),
                    _bulletPoint("Cumplimiento de obligaciones legales o regulatorias."),
                    _bulletPoint("Prestadores de servicios que actúen en nuestro nombre, quienes estarán sujetos a estrictos acuerdos de confidencialidad."),
                    SizedBox(height: 20),
                    _sectionTitle("Seguridad de los Datos", primaryColor),
                    _sectionContent(
                        "Implementamos medidas técnicas y organizativas para garantizar la seguridad de los datos personales, incluyendo:"),
                    _bulletPoint("Cifrado de datos en tránsito y en reposo."),
                    _bulletPoint("Autenticación segura para el acceso a la aplicación."),
                    _bulletPoint("Monitoreo continuo para prevenir accesos no autorizados."),
                    SizedBox(height: 20),
                    _sectionTitle("Periodo de Conservación", primaryColor),
                    _sectionContent(
                        "Los datos personales se conservarán únicamente durante el tiempo necesario para cumplir con los fines establecidos en esta política o conforme a lo requerido por la ley."),
                    SizedBox(height: 20),
                    _sectionTitle("Actualizaciones a la Política de Privacidad", primaryColor),
                    _sectionContent(
                        "Nos reservamos el derecho de actualizar esta política de privacidad. Cualquier cambio será notificado a los usuarios a través de la aplicación o por correo electrónico."),
                    SizedBox(height: 20),
                    _sectionTitle("Contacto", primaryColor),
                    _sectionContent(
                        "Si tienes preguntas o inquietudes sobre esta política de privacidad, puedes contactarnos en:"),
                    _bulletPoint("Correo electrónico: maikel.quisbert@inacapmail.cl"),
                    _bulletPoint("Teléfono: +56967479094"),
                    SizedBox(height: 30),
                    Center(
                      child: Text(
                        "Esta política de privacidad está vigente desde el 02 de diciembre de 2024.",
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String title, Color color) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: color,
      ),
    );
  }

  Widget _sectionContent(String content) {
    return Text(
      content,
      style: TextStyle(fontSize: 16, height: 1.5),
    );
  }

  Widget _bulletPoint(String content) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.circle,
            size: 6,
            color: Colors.grey.shade600,
          ),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              content,
              style: TextStyle(fontSize: 16, height: 1.5),
            ),
          ),
        ],
      ),
    );
  }
}
