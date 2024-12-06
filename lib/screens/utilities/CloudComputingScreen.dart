import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:animated_text_kit/animated_text_kit.dart';

class CloudComputingScreen extends StatefulWidget {
  @override
  _CloudComputingScreenState createState() => _CloudComputingScreenState();
}

class _CloudComputingScreenState extends State<CloudComputingScreen> {
  final Map<String, String> cloudComponents = {
    "SaaS": "Software as a Service: Proporciona software a través de Internet. Ejemplo: Google Docs.",
    "PaaS": "Platform as a Service: Ofrece herramientas y entornos para desarrollo. Ejemplo: Google App Engine.",
    "IaaS": "Infrastructure as a Service: Proporciona infraestructura virtual. Ejemplo: Amazon EC2.",
  };

  final FlutterTts flutterTts = FlutterTts();
  String? selectedComponent;
  bool isSpeaking = false;

  @override
  void initState() {
    super.initState();
    _initTts();
  }

  void _initTts() {
    flutterTts.setLanguage("es-ES");
    flutterTts.setSpeechRate(0.5);
    flutterTts.setVolume(1.0);
    flutterTts.setPitch(1.0);

    flutterTts.setCompletionHandler(() {
      setState(() {
        isSpeaking = false;
      });
    });
  }

  Future<void> _speak(String text) async {
    if (isSpeaking) {
      await flutterTts.stop();
      setState(() {
        isSpeaking = false;
      });
    } else {
      setState(() {
        isSpeaking = true;
      });
      await flutterTts.speak(text);
    }
  }

  void _onComponentTap(String component) {
    setState(() {
      selectedComponent = component;
    });
    _speak(cloudComponents[component]!);
  }

  @override
  Widget build(BuildContext context) {
    final Color customAppBarColor = Color(0xFF42F5EC);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Sistemas Operativos y Computación en la Nube",
          style: TextStyle(
            color: Colors.lightBlue,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        backgroundColor: customAppBarColor,
        iconTheme: IconThemeData(color: Colors.lightBlue.shade100),
        elevation: 10,
      ),
      body: Column(
        children: [
          SizedBox(height: 20),
          Text(
            "Modelos de Computación en la Nube",
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.blue.shade700,
            ),
          ),
          SizedBox(height: 20),
          Expanded(
            flex: 2,
            child: InteractiveViewer(
              boundaryMargin: EdgeInsets.all(20),
              minScale: 0.5,
              maxScale: 4.0,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  SvgPicture.asset(
                    'assets/images/cloud_computing.svg',
                    semanticsLabel: 'Diagrama de Computación en la Nube',
                  ),
                  // Overlay de botones transparentes sobre componentes del SVG
                  // Ajusta las posiciones según tu SVG
                  Positioned(
                    top: 80,
                    left: 120,
                    child: GestureDetector(
                      onTap: () => _onComponentTap("SaaS"),
                      child: Container(
                        width: 150,
                        height: 60,
                        color: Colors.transparent,
                      ),
                    ),
                  ),
                  Positioned(
                    top: 200,
                    left: 100,
                    child: GestureDetector(
                      onTap: () => _onComponentTap("PaaS"),
                      child: Container(
                        width: 200,
                        height: 60,
                        color: Colors.transparent,
                      ),
                    ),
                  ),
                  Positioned(
                    top: 320,
                    left: 80,
                    child: GestureDetector(
                      onTap: () => _onComponentTap("IaaS"),
                      child: Container(
                        width: 240,
                        height: 60,
                        color: Colors.transparent,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 20),
          if (selectedComponent != null)
            Expanded(
              flex: 1,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: AnimatedTextKit(
                  animatedTexts: [
                    TypewriterAnimatedText(
                      cloudComponents[selectedComponent!]!,
                      textStyle: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
                      speed: Duration(milliseconds: 50),
                    ),
                  ],
                  isRepeatingAnimation: false,
                ),
              ),
            ),
          Expanded(
            flex: 1,
            child: ListView.builder(
              itemCount: cloudComponents.keys.length,
              itemBuilder: (context, index) {
                String key = cloudComponents.keys.elementAt(index);
                return Card(
                  margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: ListTile(
                    title: Text(
                      key,
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    trailing: Icon(Icons.info_outline, color: Colors.blue),
                    onTap: () => _showDescription(context, key, cloudComponents[key]!),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showDescription(BuildContext context, String title, String description) {
    _speak(description);
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: AnimatedTextKit(
            animatedTexts: [
              TypewriterAnimatedText(
                description,
                textStyle: TextStyle(fontSize: 16.0),
                speed: Duration(milliseconds: 50),
              ),
            ],
            isRepeatingAnimation: false,
          ),
          actions: [
            TextButton(
              child: Text("Cerrar"),
              onPressed: () {
                flutterTts.stop();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    flutterTts.stop();
    super.dispose();
  }
}
