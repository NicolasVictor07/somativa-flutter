import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'models/produto.dart';
import 'services/item_carrinho.dart';
import 'services/api_service.dart';
import 'services/cache_service.dart';
import 'services/cep_service.dart';
import 'services/arquivo_service.dart';
import 'widgets/produto_card.dart';

void main() {
  runApp(const MeuAppCafeteria());
}

class MeuAppCafeteria extends StatefulWidget {
  const MeuAppCafeteria({super.key});

  @override
  State<MeuAppCafeteria> createState() => _MeuAppCafeteriaState();
}

class _MeuAppCafeteriaState extends State<MeuAppCafeteria> {
  bool temaEscuro = false;

  @override
  void initState() {
    super.initState();
    _carregarTema();
  }

  void _carregarTema() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      temaEscuro = prefs.getBool('tema_escuro') ?? false;
    });
  }

  void _alternarTema() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      temaEscuro = !temaEscuro;
      prefs.setBool('tema_escuro', temaEscuro);
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: temaEscuro ? ThemeData.dark() : ThemeData(primarySwatch: Colors.brown),
      home: CafeteriaScreen(
        temaEscuro: temaEscuro,
        onAlternarTema: _alternarTema,
      ),
    );
  }
}

class CafeteriaScreen extends StatefulWidget {
  final bool temaEscuro;
  final VoidCallback onAlternarTema;

  const CafeteriaScreen({
    super.key,
    required this.temaEscuro,
    required this.onAlternarTema,
  });

  @override
  State<CafeteriaScreen> createState() => _CafeteriaScreenState();
}

class _CafeteriaScreenState extends State<CafeteriaScreen> {
  String nomeCliente = '';
  late Future<List<Bebida>> futuroProdutos;
  final List<ItemCarrinho> carrinho = [];

  @override
  void initState() {
    super.initState();
    _atualizarLista();
  }

  void _atualizarLista() {
    setState(() {
      futuroProdutos = ApiService.obterProdutos();
    });
    CacheService.lerNome().then((v) => setState(() => nomeCliente = v));
  }

  void _adicionarAoCarrinho(Bebida b) {
    setState(() {
      final indice = carrinho.indexWhere((item) => item.bebida.id == b.id);
      if (indice >= 0) {
        carrinho[indice].quantidade++;
      } else {
        carrinho.add(ItemCarrinho(bebida: b));
      }
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${b.nome} adicionado ao carrinho!'), duration: const Duration(seconds: 1)),
    );
  }

  double get _totalCarrinho => carrinho.fold(0.0, (soma, item) => soma + item.subtotal);

  // Ecrã Modal de Finalização do Carrinho
  void _abrirCarrinho() {
    final cepCtrl = TextEditingController();
    String endereco = '';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setSheetState) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 16,
            right: 16,
            top: 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Resumo do Pedido', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const Divider(),
              if (carrinho.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(20),
                  child: Text('O carrinho está vazio.'),
                )
              else ...[
                ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 180),
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: carrinho.length,
                    itemBuilder: (ctx, i) => ListTile(
                      title: Text(carrinho[i].bebida.nome),
                      subtitle: Text('${carrinho[i].quantidade}x R\$ ${carrinho[i].bebida.preco.toStringAsFixed(2)}'),
                      trailing: Text('R\$ ${carrinho[i].subtotal.toStringAsFixed(2)}'),
                    ),
                  ),
                ),
                Text('Total: R\$ ${_totalCarrinho.toStringAsFixed(2)}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.brown)),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: cepCtrl,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: 'CEP para Entrega', isDense: true),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.search),
                      onPressed: () async {
                        final res = await CepService.buscarEndereco(cepCtrl.text);
                        setSheetState(() => endereco = res);
                      },
                    ),
                  ],
                ),
                if (endereco.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Text(endereco, style: const TextStyle(fontSize: 12, color: Colors.green)),
                  ),
                const SizedBox(height: 10),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.brown),
                  icon: const Icon(Icons.check, color: Colors.white),
                  label: const Text('Confirmar e Guardar', style: TextStyle(color: Colors.white)),
                  onPressed: () async {
                    final resumo = 'Pedido: ${carrinho.length} itens | Total: R\$ ${_totalCarrinho.toStringAsFixed(2)} | Entrega: $endereco';
                    await ArquivoService.salvarRegistroInterno(resumo);
                    setState(() => carrinho.clear());
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Pedido registado no disco com sucesso!')),
                    );
                  },
                ),
              ],
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  // Exportar para o Armazenamento Externo
  void _exportarParaDiscoExterno() async {
    final relatorio = 'ID,CLIENTE,DATA\n1,$nomeCliente,${DateTime.now().toIso8601String()}\n';
    final mensagem = await ArquivoService.exportarRelatorioExterno(relatorio);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Armazenamento Externo'),
        content: Text(mensagem),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('OK')),
        ],
      ),
    );
  }

  void _modalNovoCafe() {
    final nomeCtrl = TextEditingController();
    final precoCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Novo Café (POST)'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nomeCtrl, decoration: const InputDecoration(labelText: 'Nome')),
            TextField(controller: precoCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Preço')),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () async {
              if (nomeCtrl.text.isNotEmpty && precoCtrl.text.isNotEmpty) {
                await ApiService.criarProduto(
                  nomeCtrl.text,
                  double.tryParse(precoCtrl.text) ?? 0.0,
                  'https://images.unsplash.com/photo-1510591509098-f4fdc6d0ff04?w=200',
                );
                _atualizarLista();
              }
              Navigator.pop(ctx);
            },
            child: const Text('Cadastrar'),
          ),
        ],
      ),
    );
  }

  void _modalEditarPreco(Bebida p) {
    final precoCtrl = TextEditingController(text: p.preco.toString());
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Editar (PUT): ${p.nome}'),
        content: TextField(controller: precoCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Novo Preço')),
        actions: [
          TextButton(
            onPressed: () async {
              final novoPreco = double.tryParse(precoCtrl.text);
              if (novoPreco != null) {
                await ApiService.atualizarPreco(p.id, novoPreco, p.nome, p.urlImagem);
                _atualizarLista();
              }
              Navigator.pop(ctx);
            },
            child: const Text('Atualizar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Minha Cafeteria'),
        backgroundColor: Colors.brown,
        actions: [
          IconButton(
            icon: Icon(widget.temaEscuro ? Icons.light_mode : Icons.dark_mode),
            tooltip: 'Alternar Tema',
            onPressed: widget.onAlternarTema,
          ),
          IconButton(
            icon: const Icon(Icons.file_download),
            tooltip: 'Armazenamento Externo',
            onPressed: _exportarParaDiscoExterno,
          ),
          Stack(
            children: [
              IconButton(icon: const Icon(Icons.shopping_cart), onPressed: _abrirCarrinho),
              if (carrinho.isNotEmpty)
                Positioned(
                  right: 6,
                  top: 6,
                  child: CircleAvatar(
                    radius: 9,
                    backgroundColor: Colors.red,
                    child: Text('${carrinho.length}', style: const TextStyle(fontSize: 11, color: Colors.white)),
                  ),
                ),
            ],
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.brown,
        onPressed: _modalNovoCafe,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            color: widget.temaEscuro ? Colors.black26 : Colors.brown.shade100,
            width: double.infinity,
            child: Text('Cliente: $nomeCliente', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ),
          Expanded(
            child: FutureBuilder<List<Bebida>>(
              future: futuroProdutos,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
                if (snapshot.hasError) return Center(child: Text('Erro: ${snapshot.error}'));
                final lista = snapshot.data ?? [];
                return ListView.builder(
                  itemCount: lista.length,
                  itemBuilder: (context, i) {
                    final cafe = lista[i];
                    return ProdutoCard(
                      nome: cafe.nome,
                      preco: cafe.preco,
                      urlImagem: cafe.urlImagem,
                      onAdicionarCarrinho: () => _adicionarAoCarrinho(cafe),
                      onEditar: () => _modalEditarPreco(cafe),
                      onExcluir: () async {
                        await ApiService.deletarProduto(cafe.id);
                        _atualizarLista();
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}