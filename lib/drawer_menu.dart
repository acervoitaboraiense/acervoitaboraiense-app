import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'doacao_page.dart';
import 'sobre_page.dart';

const Color kPrimary = Color(0xFF291F75);
const Color kAccent  = Color(0xFF6B5FD1);

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  Future<void> _abrirSite() async {
    try {
      await launchUrl(
        Uri.parse('https://memoriaitaboraiense.shop'),
        mode: LaunchMode.externalApplication,
      );
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          Container(
            height: 190,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [kPrimary, kAccent],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: const [
                    Icon(Icons.menu_book, color: Colors.white, size: 44),
                    SizedBox(height: 10),
                    Text(
                      'Acervo Itaboraiense',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Uma organização sem fins lucrativos dedicada à cidade de Itaboraí, no Rio de Janeiro.',
                      style: TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),
          ),

          _item(
            context,
            icon: Icons.home_outlined,
            label: 'Início',
            onTap: () => Navigator.pop(context),
          ),
          _item(
            context,
            icon: Icons.info_outline,
            label: 'Sobre o projeto',
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SobrePage()),
              );
            },
          ),
          _item(
            context,
            icon: Icons.favorite_outline,
            label: 'Apoie o acervo',
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const DoacaoPage()),
              );
            },
          ),
          _item(
            context,
            icon: Icons.mail_outline,
            label: 'Contato',
            onTap: () {
              Navigator.pop(context);
              _abrirSite();
            },
          ),

          const Divider(),

          _item(
            context,
            icon: Icons.public,
            label: 'Abrir site',
            onTap: () {
              Navigator.pop(context);
              _abrirSite();
            },
          ),

          const Divider(),

          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'Versão 1.0.0\nOpen-source sob licença MIT',
              style: TextStyle(color: Colors.grey, fontSize: 11),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _item(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: kPrimary),
      title: Text(label),
      onTap: onTap,
    );
  }
}
