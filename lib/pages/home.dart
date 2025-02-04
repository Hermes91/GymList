import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'login_widget.dart';
import 'new_user_widget.dart';
import 'package:url_launcher/url_launcher.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String selectedOption = 'ingresar';
  String _appVersion = 'Cargando...';

  @override
  void initState() {
    super.initState();
    _loadAppVersion();
  }

  Future<void> _loadAppVersion() async {
    final packageInfo = await PackageInfo.fromPlatform();
    setState(() {
      _appVersion = 'v${packageInfo.version}';
    });
  }

  void _setSelectedOption(String option) {
    setState(() {
      selectedOption = option;
    });
  }

  void _showEmailDialog() {
    const email = 'hermeschacon@live.com.ar';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Contacto'),
        content: Row(
          children: [
            Expanded(
              child: SelectableText(
                email, // Allows user to select and copy manually
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
          TextButton(
            onPressed: () async {
              final Uri emailLaunchUri = Uri(
                scheme: 'mailto',
                path: email,
              );
              if (await canLaunchUrl(emailLaunchUri)) {
                await launchUrl(emailLaunchUri);
              }
            },
            child: const Text('Enviar correo'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget content;

    switch (selectedOption) {
      case 'ingresar':
        content = const LoginWidget();
        break;
      case 'crear':
        content = NewUserWidget(
          onSuccess: () {
            _setSelectedOption('ingresar');
          },
        );
        break;
      default:
        content = const Center(child: Text('Opción no válida'));
    }

    return Scaffold(
      backgroundColor: const Color(0xFF2A2D34),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2A2D34),
        title: const Text(
          'Gestión de Socios',
          style:
              TextStyle(color: Color(0xFF80C2AF), fontWeight: FontWeight.bold),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: Row(
              children: [
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.3,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      _buildOptionTile('Ingresar', 'ingresar'),
                      _buildOptionTile('Crear nuevo socio/a', 'crear'),
                    ],
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Card(
                      color: const Color(0xFFEFE9F4),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: content,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Footer
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Align(
              alignment: Alignment.bottomRight,
              child: GestureDetector(
                onTap: _showEmailDialog,
                child: Text(
                  'Desarrollado por Hermes - $_appVersion',
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOptionTile(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          minWidth: 200,
          maxWidth: 500,
        ),
        child: ListTile(
          title: Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          textColor: Colors.white,
          selectedTileColor: const Color(0xFF80C2AF),
          selectedColor: Colors.white,
          hoverColor: const Color(0xFFAAF5CE),
          shape: const BeveledRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(3))),
          selected: selectedOption == value,
          onTap: () => _setSelectedOption(value),
        ),
      ),
    );
  }
}
