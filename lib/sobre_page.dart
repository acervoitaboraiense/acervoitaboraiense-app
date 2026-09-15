import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

const Color kPrimary   = Color(0xFF291F75);
const Color kSecondary = Color(0xFF3D3663);
const Color kAccent    = Color(0xFF6B5FD1);

class SobrePage extends StatelessWidget {
  const SobrePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sobre o projeto'),
        backgroundColor: kPrimary,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Center(
            child: Icon(Icons.menu_book, size: 64, color: kPrimary),
          ),
          const SizedBox(height: 16),
          const Center(
            child: Text(
              'Sobre o Acervo Itaboraiense',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: kPrimary,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 6),
          const Center(
            child: Text(
              'Uma organização que guarda os acervos de Itaboraí no coração.',
              style: TextStyle(
                fontSize: 14,
                color: Colors.black54,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
          const SizedBox(height: 32),

          const Text(
            'O Acervo Itaboraiense é um projeto dedicado à preservação, '
            'organização e divulgação da memória histórica e cultural da '
            'cidade de Itaboraí, no estado do Rio de Janeiro. Reunimos em um '
            'só lugar documentos, fotografias, áudios, vídeos e outros '
            'registros que contam a história da cidade e de sua gente.\n\n'
            'Este site não é uma loja virtual. Não vendemos produtos, não '
            'fazemos publicidade e não temos fins comerciais. Trata-se de um '
            'espaço colaborativo e sem fins lucrativos, criado para que '
            'moradores, pesquisadores, estudantes e curiosos possam consultar '
            'e contribuir com o patrimônio histórico de Itaboraí.',
            style: TextStyle(fontSize: 15, height: 1.6),
          ),

          const SizedBox(height: 28),

          const Text(
            'O que você encontra aqui',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: kSecondary,
            ),
          ),
          const SizedBox(height: 12),
          _itemLista(
            Icons.menu_book_outlined,
            'Livros e documentos históricos',
            'Obras raras, registros oficiais e papéis antigos',
          ),
          _itemLista(
            Icons.photo_camera_outlined,
            'Fotografias',
            'Imagens que retratam ruas, praças, festas e o cotidiano da cidade',
          ),
          _itemLista(
            Icons.mic_outlined,
            'Áudios e depoimentos',
            'Relatos orais de moradores e personagens importantes',
          ),
          _itemLista(
            Icons.videocam_outlined,
            'Vídeos',
            'Registros audiovisuais de eventos, celebrações e momentos marcantes',
          ),
          _itemLista(
            Icons.map_outlined,
            'Mapas, certidões, jornais e obras de arte',
            'Tudo o que ajuda a reconstruir a trajetória de Itaboraí',
          ),

          const SizedBox(height: 28),

          const Text(
            'Sobre a mudança de domínio',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: kSecondary,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Atualmente o acervo está hospedado no domínio '
            'memoriaitaboraiense.shop, mas em breve migraremos para o '
            'endereço acervoitaboraiense.org.\n\n'
            'A mudança não afetará o conteúdo nem o acesso: tudo continuará '
            'disponível, apenas em um novo endereço.',
            style: TextStyle(fontSize: 15, height: 1.6),
          ),

          const SizedBox(height: 28),

          const Text(
            'Como contribuir',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: kSecondary,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Se você possui documentos, fotos ou gravações relacionadas à '
            'história de Itaboraí, sua contribuição é muito bem-vinda. Basta '
            'acessar a página inicial, escolher a categoria correspondente e '
            'enviar o arquivo com as informações disponíveis.\n\n'
            'O acervo cresce com a participação da comunidade. Cada material '
            'enviado é uma peça a mais na construção coletiva da memória da '
            'cidade.',
            style: TextStyle(fontSize: 15, height: 1.6),
          ),

          const SizedBox(height: 28),

          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: kAccent.withOpacity(0.08),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: kAccent.withOpacity(0.2)),
            ),
            child: const Row(
              children: [
                Icon(Icons.person_outline, color: kPrimary),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Idealizador e mantenedor do projeto',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: kSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),

          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              icon: const Icon(Icons.public),
              label: const Text('Visitar o site oficial'),
              style: OutlinedButton.styleFrom(
                foregroundColor: kPrimary,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              onPressed: () async {
                await launchUrl(
                  Uri.parse('https://memoriaitaboraiense.shop'),
                  mode: LaunchMode.externalApplication,
                );
              },
            ),
          ),

          const SizedBox(height: 32),
          Center(
            child: Text(
              '© 2026 Acervo Itaboraiense',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontStyle: FontStyle.italic,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _itemLista(IconData icon, String titulo, String descricao) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: kAccent.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: kPrimary, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  titulo,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                Text(
                  descricao,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
