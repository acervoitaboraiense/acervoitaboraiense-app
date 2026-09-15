import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'drawer_menu.dart';
import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:http/http.dart' as http;
import 'package:just_audio/just_audio.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:google_fonts/google_fonts.dart';

const String kBaseUrl = 'https://memoriaitaboraiense.shop/api.php';
const Color kPrimary   = Color(0xFF291F75);
const Color kSecondary = Color(0xFF3D3663);
const Color kAccent    = Color(0xFF6B5FD1);

void main() => runApp(const AcervoApp());

class AcervoApp extends StatelessWidget {
  const AcervoApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Acervo Itaboraiense',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: kPrimary),
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF5F4FA),
        textTheme: GoogleFonts.latoTextTheme(),
      ),
      home: const HomePage(),
    );
  }
}

enum TipoErro { semInternet, servidor, naoEncontrado, generico, vazio }

class AppErro {
  final TipoErro tipo;
  final String mensagem;
  AppErro(this.tipo, this.mensagem);
}

AppErro classificarErro(Object e, {int? statusCode}) {
  if (statusCode == 404) {
    return AppErro(TipoErro.naoEncontrado,
        'Não encontramos esse conteúdo no acervo.');
  }
  if (statusCode != null && statusCode >= 500) {
    return AppErro(TipoErro.servidor,
        'O servidor do acervo está indisponível no momento. Tente novamente em alguns instantes.');
  }
  final str = e.toString();
  if (e is SocketException ||
      str.contains('SocketException') ||
      str.contains('Failed host lookup')) {
    return AppErro(TipoErro.semInternet,
        'Sem conexão com a internet. Verifique sua rede e tente novamente.');
  }
  if (e is TimeoutException || str.contains('TimeoutException')) {
    return AppErro(TipoErro.semInternet,
        'A conexão demorou demais. Verifique sua internet.');
  }
  return AppErro(TipoErro.generico, 'Algo deu errado: $str');
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<dynamic> _itens = [];
  List<dynamic> _categorias = [];
  bool _carregando = true;
  AppErro? _erro;
  String _busca = '';
  String _categoria = '';
  int _pagina = 1;
  int _totalPaginas = 1;
  int _total = 0;
  final TextEditingController _buscaController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _carregarCategorias();
    _carregar();
  }

  @override
  void dispose() {
    _buscaController.dispose();
    super.dispose();
  }

  Future<void> _carregarCategorias() async {
    try {
      final resp = await http
          .get(Uri.parse('$kBaseUrl?acao=categorias'))
          .timeout(const Duration(seconds: 15));
      final data = json.decode(utf8.decode(resp.bodyBytes));
      if (mounted) setState(() => _categorias = data['categorias'] ?? []);
    } catch (_) {}
  }

  Future<void> _carregar({bool resetar = false}) async {
    if (resetar) _pagina = 1;
    setState(() { _carregando = true; _erro = null; });

    try {
      final uri = Uri.parse(
        '$kBaseUrl?acao=listar&pagina=$_pagina&por_pagina=20'
        '&busca=${Uri.encodeComponent(_busca)}'
        '&categoria=${Uri.encodeComponent(_categoria)}',
      );
      final resp = await http.get(uri).timeout(const Duration(seconds: 15));
      if (resp.statusCode != 200) {
        if (!mounted) return;
        setState(() {
          _erro = classificarErro('HTTP ${resp.statusCode}', statusCode: resp.statusCode);
          _carregando = false;
        });
        return;
      }
      final data = json.decode(utf8.decode(resp.bodyBytes));
      if (!mounted) return;
      final itens = data['itens'] ?? [];
      setState(() {
        _itens = itens;
        _totalPaginas = data['total_paginas'] ?? 1;
        _total = data['total'] ?? 0;
        _carregando = false;
        if (itens.isEmpty && _total == 0) {
          _erro = AppErro(TipoErro.vazio, 'Nenhum item encontrado.');
        }
      });
    } catch (e) {
      if (!mounted) return;
      setState(() { _erro = classificarErro(e); _carregando = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Acervo Itaboraiense'),
        backgroundColor: kPrimary,
        foregroundColor: Colors.white,
        elevation: 2,
      ),
      body: Column(
        children: [
          _buildBarraBusca(),
          _buildFiltroCategorias(),
          if (_total > 0 && _erro == null) _buildContador(),
          Expanded(child: _buildCorpo()),
          if (_totalPaginas > 1 && _erro == null) _buildPaginacao(),
        ],
      ),
    );
  }

  Widget _buildBarraBusca() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 6),
      child: TextField(
        controller: _buscaController,
        decoration: InputDecoration(
          hintText: 'Buscar por título, autor, enviado por...',
          prefixIcon: const Icon(Icons.search),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          suffixIcon: _busca.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _buscaController.clear();
                    setState(() => _busca = '');
                    _carregar(resetar: true);
                  },
                )
              : null,
        ),
        onSubmitted: (v) {
          setState(() => _busca = v.trim());
          _carregar(resetar: true);
        },
      ),
    );
  }

  Widget _buildFiltroCategorias() {
    if (_categorias.isEmpty) return const SizedBox.shrink();
    return SizedBox(
      height: 45,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 6),
            child: FilterChip(
              label: const Text('Todas'),
              selected: _categoria.isEmpty,
              selectedColor: kAccent.withOpacity(0.25),
              onSelected: (_) {
                setState(() => _categoria = '');
                _carregar(resetar: true);
              },
            ),
          ),
          ..._categorias.map((cat) {
            final chave = cat['chave'].toString();
            return Padding(
              padding: const EdgeInsets.only(right: 6),
              child: FilterChip(
                label: Text(cat['label']),
                selected: _categoria == chave,
                selectedColor: kAccent.withOpacity(0.25),
                onSelected: (_) {
                  setState(() => _categoria = chave);
                  _carregar(resetar: true);
                },
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildContador() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          '$_total item(ns) no acervo',
          style: const TextStyle(color: kSecondary, fontSize: 12, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  Widget _buildCorpo() {
    if (_carregando) return const Center(child: CircularProgressIndicator());
    if (_erro != null) return _buildErroWidget(_erro!);
    return RefreshIndicator(
      onRefresh: () => _carregar(resetar: true),
      child: ListView.builder(
        itemCount: _itens.length,
        itemBuilder: (context, i) => _buildItemCard(_itens[i]),
      ),
    );
  }

  Widget _buildErroWidget(AppErro erro) {
    IconData icone;
    Color cor;
    String titulo;
    switch (erro.tipo) {
      case TipoErro.semInternet:
        icone = Icons.wifi_off_rounded;
        cor = Colors.orange;
        titulo = 'Sem conexão';
        break;
      case TipoErro.servidor:
        icone = Icons.cloud_off_rounded;
        cor = Colors.red;
        titulo = 'Servidor indisponível';
        break;
      case TipoErro.naoEncontrado:
        icone = Icons.search_off_rounded;
        cor = Colors.blueGrey;
        titulo = 'Não encontrado';
        break;
      case TipoErro.vazio:
        icone = Icons.inbox_outlined;
        cor = Colors.blueGrey;
        titulo = 'Acervo vazio';
        break;
      case TipoErro.generico:
        icone = Icons.error_outline_rounded;
        cor = Colors.red;
        titulo = 'Erro';
        break;
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icone, size: 72, color: cor),
            const SizedBox(height: 16),
            Text(titulo,
                style: TextStyle(
                    fontSize: 18, fontWeight: FontWeight.bold, color: cor)),
            const SizedBox(height: 10),
            Text(erro.mensagem,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 14, color: Colors.black87)),
            const SizedBox(height: 20),
            FilledButton.icon(
              icon: const Icon(Icons.refresh),
              label: const Text('Tentar novamente'),
              style: FilledButton.styleFrom(backgroundColor: kPrimary),
              onPressed: () {
                _carregarCategorias();
                _carregar(resetar: true);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildItemCard(dynamic item) {
    final autorObra  = (item['autor_obra'] ?? '').toString();
    final enviadoPor = (item['enviado_por'] ?? 'Anônimo').toString();
    final ext        = (item['arquivo']?['extensao'] ?? '').toString().toUpperCase();

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      elevation: 1.5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => DetalhePage(id: item['id'])),
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      item['titulo'] ?? 'Sem título',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: kPrimary,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      item['categoria_label'] ?? '',
                      style: const TextStyle(
                        color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              if (autorObra.isNotEmpty)
                _linhaInfo(Icons.person_outline, 'Autor: $autorObra'),
              _linhaInfo(Icons.upload_outlined, 'Enviado por: $enviadoPor'),
              if (ext.isNotEmpty)
                _linhaInfo(Icons.insert_drive_file_outlined, 'Arquivo: .$ext'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _linhaInfo(IconData icon, String texto) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Icon(icon, size: 14, color: kSecondary),
          const SizedBox(width: 6),
          Expanded(child: Text(texto, style: const TextStyle(fontSize: 13))),
        ],
      ),
    );
  }

  Widget _buildPaginacao() {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: _pagina > 1
                ? () { setState(() => _pagina--); _carregar(); }
                : null,
          ),
          Text('$_pagina / $_totalPaginas',
              style: const TextStyle(fontWeight: FontWeight.bold)),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: _pagina < _totalPaginas
                ? () { setState(() => _pagina++); _carregar(); }
                : null,
          ),
        ],
      ),
    );
  }
}

bool ehImagem(String ext) =>
    ['jpg', 'jpeg', 'png', 'gif', 'webp', 'bmp'].contains(ext.toLowerCase());
bool ehPdf(String ext) => ext.toLowerCase() == 'pdf';
bool ehAudio(String ext) =>
    ['mp3', 'wav', 'ogg', 'm4a'].contains(ext.toLowerCase());
bool ehTxt(String ext) => ext.toLowerCase() == 'txt';

IconData iconePorExtensao(String ext) {
  final e = ext.toLowerCase();
  if (ehImagem(e)) return Icons.image_outlined;
  if (ehPdf(e)) return Icons.picture_as_pdf_outlined;
  if (ehAudio(e)) return Icons.audiotrack_outlined;
  if (['doc', 'docx'].contains(e)) return Icons.description_outlined;
  if (['xls', 'xlsx'].contains(e)) return Icons.table_chart_outlined;
  if (e == 'txt') return Icons.text_snippet_outlined;
  return Icons.insert_drive_file_outlined;
}

String formatarTamanho(num bytes) {
  if (bytes < 1024) return '$bytes B';
  if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(2)} KB';
  return '${(bytes / (1024 * 1024)).toStringAsFixed(2)} MB';
}

class DetalhePage extends StatefulWidget {
  final String id;
  const DetalhePage({super.key, required this.id});
  @override
  State<DetalhePage> createState() => _DetalhePageState();
}

class _DetalhePageState extends State<DetalhePage> {
  Map<String, dynamic>? _item;
  bool _carregando = true;
  AppErro? _erro;

  @override
  void initState() {
    super.initState();
    _carregar();
  }

  Future<void> _carregar() async {
    setState(() { _carregando = true; _erro = null; });
    try {
      final resp = await http
          .get(Uri.parse('$kBaseUrl?acao=item&id=${widget.id}'))
          .timeout(const Duration(seconds: 15));
      if (resp.statusCode != 200) {
        if (!mounted) return;
        setState(() {
          _erro = classificarErro('HTTP ${resp.statusCode}', statusCode: resp.statusCode);
          _carregando = false;
        });
        return;
      }
      final data = json.decode(utf8.decode(resp.bodyBytes));
      if (!mounted) return;
      setState(() { _item = data['item']; _carregando = false; });
    } catch (e) {
      if (!mounted) return;
      setState(() { _erro = classificarErro(e); _carregando = false; });
    }
  }

  Future<void> _abrirExterno(String url) async {
    final uri = Uri.parse(url);
    try {
      final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!ok && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Não foi possível abrir externamente')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro: $e')),
        );
      }
    }
  }

  void _abrirVisualizador(String url, String ext, String titulo, String nomeOriginal) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => VisualizadorPage(
          url: url,
          extensao: ext,
          titulo: titulo,
          nomeOriginal: nomeOriginal,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalhes do item'),
        backgroundColor: kPrimary,
        foregroundColor: Colors.white,
      ),
      body: _carregando
          ? const Center(child: CircularProgressIndicator())
          : _erro != null
              ? _buildErro()
              : _buildDetalhe(),
    );
  }

  Widget _buildErro() {
    final e = _erro!;
    IconData icone;
    Color cor;
    switch (e.tipo) {
      case TipoErro.semInternet:
        icone = Icons.wifi_off_rounded; cor = Colors.orange; break;
      case TipoErro.servidor:
        icone = Icons.cloud_off_rounded; cor = Colors.red; break;
      case TipoErro.naoEncontrado:
        icone = Icons.search_off_rounded; cor = Colors.blueGrey; break;
      default:
        icone = Icons.error_outline_rounded; cor = Colors.red;
    }
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icone, size: 72, color: cor),
            const SizedBox(height: 16),
            Text(e.mensagem, textAlign: TextAlign.center),
            const SizedBox(height: 20),
            FilledButton.icon(
              icon: const Icon(Icons.refresh),
              label: const Text('Tentar novamente'),
              style: FilledButton.styleFrom(backgroundColor: kPrimary),
              onPressed: _carregar,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetalhe() {
    final item    = _item!;
    final campos  = (item['campos'] as Map<String, dynamic>?) ?? {};
    final labels  = (item['campos_labels'] as Map<String, dynamic>?) ?? {};
    final arquivo = (item['arquivo'] as Map<String, dynamic>?) ?? {};
    final ext     = (arquivo['extensao'] ?? '').toString();
    final url     = (arquivo['url'] ?? '').toString();
    final titulo  = (item['titulo'] ?? '').toString();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(titulo,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, height: 1.25)),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          children: [
            Chip(
              label: Text(item['categoria_label'] ?? ''),
              backgroundColor: kPrimary,
              labelStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ],
        ),

        if (ehImagem(ext) && url.isNotEmpty) ...[
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: AspectRatio(
              aspectRatio: 16 / 10,
              child: Image.network(
                url,
                fit: BoxFit.cover,
                loadingBuilder: (c, child, p) {
                  if (p == null) return child;
                  return Container(
                    color: Colors.black12,
                    child: const Center(child: CircularProgressIndicator()),
                  );
                },
                errorBuilder: (c, e, s) => Container(
                  color: Colors.black12,
                  child: const Center(child: Text('Não foi possível carregar a imagem')),
                ),
              ),
            ),
          ),
        ],

        const SizedBox(height: 20),
        const Divider(),
        const SizedBox(height: 8),

        const Text('Informações',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: kSecondary)),
        const SizedBox(height: 8),
        ..._buildCampos(campos, labels),

        if ((item['descricao'] ?? '').toString().isNotEmpty) ...[
          const SizedBox(height: 20),
          const Divider(),
          const SizedBox(height: 8),
          const Text('Descrição',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: kSecondary)),
          const SizedBox(height: 6),
          Text(item['descricao'], style: const TextStyle(height: 1.5)),
        ],

        const SizedBox(height: 20),
        const Divider(),
        const SizedBox(height: 8),
        const Text('Arquivo',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: kSecondary)),
        const SizedBox(height: 10),
        _buildArquivoCard(url, ext, titulo, arquivo),

        const SizedBox(height: 20),
        const Divider(),
        const SizedBox(height: 8),
        _linhaDetalhe(Icons.calendar_today_outlined, 'Publicado em',
            item['data_publicacao'] ?? '—'),

        const SizedBox(height: 32),
      ],
    );
  }

  Widget _buildArquivoCard(String url, String ext, String titulo, Map<String, dynamic> arquivo) {
    final suportadoNoApp = ehImagem(ext) || ehPdf(ext) || ehAudio(ext) || ehTxt(ext);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.black12),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(iconePorExtensao(ext), size: 36, color: kPrimary),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(arquivo['nome_original'] ?? '(sem nome)',
                        style: const TextStyle(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 4),
                    Text(
                      '${ext.toUpperCase()} • ${formatarTamanho((arquivo['tamanho'] ?? 0) as num)}',
                      style: const TextStyle(fontSize: 12, color: Colors.black54),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (suportadoNoApp && url.isNotEmpty)
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                icon: const Icon(Icons.visibility_outlined),
                label: Text(
                  ehImagem(ext) ? 'Ver imagem no aplicativo'
                  : ehPdf(ext)    ? 'Ler PDF no aplicativo'
                  : ehAudio(ext)  ? 'Ouvir áudio no aplicativo'
                  : 'Ler texto no aplicativo',
                ),
                style: FilledButton.styleFrom(
                  backgroundColor: kPrimary,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onPressed: () => _abrirVisualizador(
                  url, ext, titulo, arquivo['nome_original'] ?? '',
                ),
              ),
            ),
          if (url.isNotEmpty) ...[
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                icon: const Icon(Icons.open_in_new),
                label: const Text('Abrir em outro aplicativo'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: kPrimary,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                onPressed: () => _abrirExterno(url),
              ),
            ),
          ],
        ],
      ),
    );
  }

  List<Widget> _buildCampos(Map<String, dynamic> campos, Map<String, dynamic> labels) {
    final chaves = <String>[];
    for (final k in labels.keys) {
      if (k != 'titulo') chaves.add(k);
    }
    for (final k in campos.keys) {
      if (k != 'titulo' && !chaves.contains(k)) chaves.add(k);
    }
    if (chaves.isEmpty) {
      return [const Text('Nenhuma informação cadastrada.', style: TextStyle(color: Colors.black54))];
    }
    return chaves.map((chave) {
      final label = (labels[chave] as Map?)?['label']?.toString() ?? chave;
      final valor = (campos[chave] ?? '').toString();
      final vazio = valor.trim().isEmpty;
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 130,
              child: Text(label,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, color: kSecondary, fontSize: 13)),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                vazio ? '—' : valor,
                style: TextStyle(
                  fontSize: 14,
                  color: vazio ? Colors.black38 : Colors.black87,
                  fontStyle: vazio ? FontStyle.italic : FontStyle.normal,
                ),
              ),
            ),
          ],
        ),
      );
    }).toList();
  }

  Widget _linhaDetalhe(IconData icon, String label, String valor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 16, color: kSecondary),
          const SizedBox(width: 8),
          Text('$label: ',
              style: const TextStyle(fontWeight: FontWeight.bold, color: kSecondary, fontSize: 13)),
          Expanded(child: Text(valor, style: const TextStyle(fontSize: 13))),
        ],
      ),
    );
  }
}

class VisualizadorPage extends StatelessWidget {
  final String url;
  final String extensao;
  final String titulo;
  final String nomeOriginal;
  const VisualizadorPage({
    super.key,
    required this.url,
    required this.extensao,
    required this.titulo,
    required this.nomeOriginal,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const AppDrawer(),
      appBar: AppBar(
        title: const Text('Acervo Itaboraiense'),
        backgroundColor: kPrimary,
        foregroundColor: Colors.white,
      ),
      backgroundColor: Colors.black,
      body: _buildViewer(context),
    );
  }

  Widget _buildViewer(BuildContext context) {
    if (ehImagem(extensao)) return _ImagemViewer(url: url);
    if (ehPdf(extensao)) return _PdfViewer(url: url);
    if (ehAudio(extensao)) return _AudioViewer(url: url, titulo: titulo);
    if (ehTxt(extensao)) return _TxtViewer(url: url);
    return _NaoSuportado(url: url, extensao: extensao);
  }
}

class _ImagemViewer extends StatelessWidget {
  final String url;
  const _ImagemViewer({required this.url});

  @override
  Widget build(BuildContext context) {
    return InteractiveViewer(
      minScale: 0.5,
      maxScale: 5.0,
      child: Center(
        child: Image.network(
          url,
          fit: BoxFit.contain,
          loadingBuilder: (c, child, p) {
            if (p == null) return child;
            return const Center(child: CircularProgressIndicator(color: Colors.white));
          },
          errorBuilder: (c, e, s) => const Center(
            child: Text('Não foi possível carregar a imagem',
                style: TextStyle(color: Colors.white)),
          ),
        ),
      ),
    );
  }
}

class _PdfViewer extends StatelessWidget {
  final String url;
  const _PdfViewer({required this.url});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: _baixarPdf(url),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: Colors.white));
        }
        if (snapshot.hasError || !snapshot.hasData) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.picture_as_pdf_outlined, color: Colors.white, size: 60),
                  const SizedBox(height: 16),
                  Text('Erro ao baixar PDF: ${snapshot.error}',
                      style: const TextStyle(color: Colors.white),
                      textAlign: TextAlign.center),
                ],
              ),
            ),
          );
        }
        return PDFView(
          filePath: snapshot.data!,
          enableSwipe: true,
          swipeHorizontal: false,
          autoSpacing: true,
          pageFling: true,
          onError: (e) => Center(
            child: Text('Erro: $e', style: const TextStyle(color: Colors.white)),
          ),
        );
      },
    );
  }

  Future<String> _baixarPdf(String url) async {
    final resp = await http.get(Uri.parse(url));
    if (resp.statusCode != 200) {
      throw Exception('HTTP ${resp.statusCode}');
    }
    final dir = Directory.systemTemp;
    final file = File('${dir.path}/visualizador_${DateTime.now().millisecondsSinceEpoch}.pdf');
    await file.writeAsBytes(resp.bodyBytes);
    return file.path;
  }
}

class _AudioViewer extends StatefulWidget {
  final String url;
  final String titulo;
  const _AudioViewer({required this.url, required this.titulo});
  @override
  State<_AudioViewer> createState() => _AudioViewerState();
}

class _AudioViewerState extends State<_AudioViewer> {
  final AudioPlayer _player = AudioPlayer();
  bool _carregando = true;
  String? _erro;

  @override
  void initState() {
    super.initState();
    _iniciar();
  }

  Future<void> _iniciar() async {
    try {
      await _player.setUrl(widget.url);
      setState(() => _carregando = false);
      _player.play();
    } catch (e) {
      setState(() { _erro = '$e'; _carregando = false; });
    }
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  String _fmt(Duration d) {
    final m = d.inMinutes.toString().padLeft(2, '0');
    final s = (d.inSeconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    if (_carregando) {
      return const Center(child: CircularProgressIndicator(color: Colors.white));
    }
    if (_erro != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text('Erro ao carregar áudio: $_erro',
              style: const TextStyle(color: Colors.white),
              textAlign: TextAlign.center),
        ),
      );
    }
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.audiotrack, size: 100, color: Colors.white),
            const SizedBox(height: 24),
            Text(widget.titulo,
                style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center),
            const SizedBox(height: 32),
            StreamBuilder<Duration>(
              stream: _player.positionStream,
              builder: (context, snapshot) {
                final pos = snapshot.data ?? Duration.zero;
                final dur = _player.duration ?? Duration.zero;
                return Column(
                  children: [
                    Slider(
                      value: pos.inSeconds.toDouble().clamp(0, dur.inSeconds.toDouble()),
                      max: dur.inSeconds.toDouble().clamp(1, double.infinity),
                      activeColor: kAccent,
                      onChanged: (v) => _player.seek(Duration(seconds: v.toInt())),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(_fmt(pos), style: const TextStyle(color: Colors.white70)),
                        Text(_fmt(dur), style: const TextStyle(color: Colors.white70)),
                      ],
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 20),
            StreamBuilder<PlayerState>(
              stream: _player.playerStateStream,
              builder: (context, snapshot) {
                final playing = snapshot.data?.playing ?? false;
                return IconButton(
                  iconSize: 72,
                  color: Colors.white,
                  icon: Icon(playing ? Icons.pause_circle_filled : Icons.play_circle_filled),
                  onPressed: () => playing ? _player.pause() : _player.play(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _TxtViewer extends StatefulWidget {
  final String url;
  const _TxtViewer({required this.url});
  @override
  State<_TxtViewer> createState() => _TxtViewerState();
}

class _TxtViewerState extends State<_TxtViewer> {
  String? _conteudo;
  String? _erro;

  @override
  void initState() {
    super.initState();
    _baixar();
  }

  Future<void> _baixar() async {
    try {
      final resp = await http.get(Uri.parse(widget.url));
      setState(() => _conteudo = utf8.decode(resp.bodyBytes, allowMalformed: true));
    } catch (e) {
      setState(() => _erro = '$e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_erro != null) {
      return Center(
        child: Text('Erro: $_erro',
            style: const TextStyle(color: Colors.white), textAlign: TextAlign.center),
      );
    }
    if (_conteudo == null) {
      return const Center(child: CircularProgressIndicator(color: Colors.white));
    }
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      child: SingleChildScrollView(
        child: SelectableText(
          _conteudo!,
          style: const TextStyle(fontSize: 14, height: 1.5),
        ),
      ),
    );
  }
}

class _NaoSuportado extends StatelessWidget {
  final String url;
  final String extensao;
  const _NaoSuportado({required this.url, required this.extensao});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(iconePorExtensao(extensao), size: 100, color: Colors.white),
            const SizedBox(height: 20),
            Text(
              'Arquivos .$extensao não podem ser visualizados no app.\nUse o botão abaixo para abrir em outro aplicativo.',
              style: const TextStyle(color: Colors.white),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              icon: const Icon(Icons.open_in_new),
              label: const Text('Abrir em outro aplicativo'),
              style: FilledButton.styleFrom(backgroundColor: kAccent),
              onPressed: () async {
                final uri = Uri.parse(url);
                await launchUrl(uri, mode: LaunchMode.externalApplication);
              },
            ),
          ],
        ),
      ),
    );
  }
}
