import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'pix.dart';

const Color kPrimary   = Color(0xFF291F75);
const Color kSecondary = Color(0xFF3D3663);
const Color kAccent    = Color(0xFF6B5FD1);

const String kPixChave  = 'doacao@memoriaitaboraiense.shop';
const String kPixNome   = 'ACERVO ITABORAIENSE';
const String kPixCidade = 'ITABORAI';

class DoacaoPage extends StatelessWidget {
  const DoacaoPage({super.key});

  String get _payload => PixPayload.gerar(
        chave: kPixChave,
        nome: kPixNome,
        cidade: kPixCidade,
      );

  Future<void> _copiar(BuildContext context, String texto, String msg) async {
    await Clipboard.setData(ClipboardData(text: texto));
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Apoie o acervo'),
        backgroundColor: kPrimary,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [kPrimary, kAccent],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: const [
                Icon(Icons.favorite, color: Colors.white, size: 46),
                SizedBox(height: 12),
                Text(
                  'Uma doação, por menor\ que seja, pode salvar milhares\ de acervos.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          const Text('O que fazemos com o valor?', style: _tituloSecao),
          const SizedBox(height: 12),
          _itemImpacto(Icons.cloud_outlined, 'Hospedagem e domínio', 'Mantém o site e o aplicativo no ar'),
          _itemImpacto(Icons.camera_alt_outlined, 'Digitalização', 'Preserva novos documentos e fotos'),
          _itemImpacto(Icons.build_outlined, 'Manutenção', 'Correções, melhorias e novas funções'),
          _itemImpacto(Icons.groups_outlined, 'Comunidade', 'Ações de preservação dentro da organização'),

          const SizedBox(height: 24),

          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.amber.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.amber.shade200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.visibility_outlined,
                        color: Colors.amber.shade900, size: 20),
                    const SizedBox(width: 8),
                    Text('Divisão do valor recebido:',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.amber.shade900)),
                  ],
                ),
                const SizedBox(height: 8),
                const Text(
                  '• 10% para o idealizador\n'
                  '• 30% para a hospedagem e domínio do site\n'
                  '• 40% para a digitalização de acervos\n'
                  '• 20% de reserva para imprevistos',
                  style: TextStyle(fontSize: 13, height: 1.55),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          const Text('Doe via Pix', style: _tituloSecao),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.black12),
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: QrImageView(
                    data: _payload,
                    version: QrVersions.auto,
                    size: 220,
                    backgroundColor: Colors.white,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Aponte a câmera do seu banco\npara o QR Code acima',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 13, color: Colors.black54),
                ),
                const SizedBox(height: 20),
                const Divider(),
                const SizedBox(height: 12),
                const Text('Chave Pix',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                const SizedBox(height: 6),
                SelectableText(
                  kPixChave,
                  style: const TextStyle(fontSize: 14, color: kSecondary),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    icon: const Icon(Icons.copy),
                    label: const Text('Copiar chave Pix'),
                    style: FilledButton.styleFrom(
                      backgroundColor: kPrimary,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    onPressed: () => _copiar(context, kPixChave, 'Chave Pix copiada!'),
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.qr_code),
                    label: const Text('Copiar código Pix (copia e cola)'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: kPrimary,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    onPressed: () =>
                        _copiar(context, _payload, 'Código Pix copiado!'),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 28),

          const Text('Não pode doar?', style: _tituloSecao),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: const [
                _AltItem(icon: Icons.share_outlined,
                    texto: 'Compartilhe o aplicativo com amigos e familiares'),
                SizedBox(height: 12),
                _AltItem(icon: Icons.photo_library_outlined,
                    texto: 'Envie fotos e documentos antigos para o Acervo Itaboraiense'),
                SizedBox(height: 12),
                _AltItem(icon: Icons.school_outlined,
                    texto: 'Sugira o Acervo Itaboraiense para professores e pesquisadores'),
              ],
            ),
          ),

  Widget _itemImpacto(IconData icon, String titulo, String descricao) {
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
                Text(titulo,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                Text(descricao,
                    style: const TextStyle(fontSize: 12, color: Colors.black54)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

const TextStyle _tituloSecao = TextStyle(
  fontSize: 16,
  fontWeight: FontWeight.bold,
  color: kSecondary,
);

class _AltItem extends StatelessWidget {
  final IconData icon;
  final String texto;
  const _AltItem({required this.icon, required this.texto});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: kPrimary, size: 20),
        const SizedBox(width: 12),
        Expanded(child: Text(texto, style: const TextStyle(fontSize: 13))),
      ],
    );
  }
}
