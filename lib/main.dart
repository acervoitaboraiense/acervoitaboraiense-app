import 'dart:convert';
import 'package:material_ui/material_ui.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

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
      ),
      home: const HomePage(),
    );
  }
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
  String? _erro;
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
      final resp = await http.get(Uri.parse('$kBaseUrl?acao=categorias'));
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
      final resp = await http.get(uri);
      if (resp.statusCode != 200) throw Exception('HTTP ${resp.statusCode}');
      final data = json.decode(utf8.decode(resp.bodyBytes));
      if (!mounted) return;
      setState(() {
        _itens = data['itens'] ?? [];
        _totalPaginas = data['total_paginas'] ?? 1;
        _total = data['total'] ?? 0;
        _carregando = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() { _erro = 'Erro ao carregar: $e'; _carregando = false; });
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
          if (_total > 0) _buildContador(),
          Expanded(child: _buildCorpo()),
          if (_totalPaginas > 1) _buildPaginacao(),
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
    if (_erro != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 12),
              Text(_erro!, textAlign: TextAlign.center),
              const SizedBox(height: 12),
              FilledButton(
                onPressed: () => _carregar(resetar: true),
                child: const Text('Tentar novamente'),
              ),
            ],
          ),
        ),
      );
    }
    if (_itens.isEmpty) {
      return const Center(child: Text('Nenhum item encontrado.'));
    }
    return RefreshIndicator(
      onRefresh: () => _carregar(resetar: true),
      child: ListView.builder(
        itemCount: _itens.length,
        itemBuilder: (context, i) => _buildItemCard(_itens[i]),
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

class DetalhePage extends StatefulWidget {
  final String id;
  const DetalhePage({super.key, required this.id});
  @override
  State<DetalhePage> createState() => _DetalhePageState();
}

class _DetalhePageState extends State<DetalhePage> {
  Map<String, dynamic>? _item;
  bool _carregando = true;
  String? _erro;

  @override
  void initState() {
    super.initState();
    _carregar();
  }

  Future<void> _carregar() async {
    try {
      final resp = await http.get(Uri.parse('$kBaseUrl?acao=item&id=${widget.id}'));
      if (resp.statusCode == 200) {
        final data = json.decode(utf8.decode(resp.bodyBytes));
        if (!mounted) return;
        setState(() { _item = data['item']; _carregando = false; });
      } else {
        if (!mounted) return;
        setState(() { _erro = 'Item não encontrado'; _carregando = false; });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() { _erro = 'Erro: $e'; _carregando = false; });
    }
  }

  Future<void> _abrirArquivo(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Não foi possível abrir o arquivo')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalhes'),
        backgroundColor: kPrimary,
        foregroundColor: Colors.white,
      ),
      body: _carregando
          ? const Center(child: CircularProgressIndicator())
          : _erro != null
              ? Center(child: Text(_erro!))
              : _buildDetalhe(),
    );
  }

  Widget _buildDetalhe() {
    final item    = _item!;
    final campos  = (item['campos'] as Map<String, dynamic>?) ?? {};
    final labels  = (item['campos_labels'] as Map<String, dynamic>?) ?? {};
    final arquivo = (item['arquivo'] as Map<String, dynamic>?) ?? {};

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(item['titulo'] ?? '',
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
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
        const Divider(height: 28),
        ...campos.entries
            .where((e) => e.key != 'titulo' && e.value.toString().isNotEmpty)
            .map((e) {
          final label = (labels[e.key] as Map?)?['label'] ?? e.key;
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 5),
            child: RichText(
              text: TextSpan(
                style: const TextStyle(color: Colors.black87, fontSize: 15, height: 1.4),
                children: [
                  TextSpan(
                    text: '$label: ',
                    style: const TextStyle(fontWeight: FontWeight.bold, color: kSecondary),
                  ),
                  TextSpan(text: e.value.toString()),
                ],
              ),
            ),
          );
        }),
        if ((item['descricao'] ?? '').toString().isNotEmpty) ...[
          const Divider(height: 28),
          const Text('Descrição',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 6),
          Text(item['descricao']),
        ],
        const Divider(height: 28),
        Text('Publicado em: ${item['data_publicacao'] ?? ''}',
            style: const TextStyle(color: Colors.black54, fontSize: 13)),
        if ((arquivo['tamanho'] ?? 0) > 0)
          Text('Tamanho: ${((arquivo['tamanho'] / 1024) as num).toStringAsFixed(2)} KB',
              style: const TextStyle(color: Colors.black54, fontSize: 13)),
        const SizedBox(height: 24),
        if (arquivo['url'] != null)
          FilledButton.icon(
            icon: const Icon(Icons.open_in_new),
            label: const Text('Abrir arquivo'),
            style: FilledButton.styleFrom(
              backgroundColor: kPrimary,
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            onPressed: () => _abrirArquivo(arquivo['url']),
          ),
      ],
    );
  }
}
