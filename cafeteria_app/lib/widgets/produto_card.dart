import 'package:flutter/material.dart';

class ProdutoCard extends StatelessWidget {
  final String nome;
  final String urlImagem;
  final double preco;
  final VoidCallback? onEditar;
  final VoidCallback? onExcluir;
  final VoidCallback? onAdicionarCarrinho;

  const ProdutoCard({
    super.key,
    required this.nome,
    required this.urlImagem,
    required this.preco,
    this.onEditar,
    this.onExcluir,
    this.onAdicionarCarrinho,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                urlImagem,
                width: 70,
                height: 70,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const Icon(Icons.coffee, size: 50, color: Colors.brown),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(nome, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text("R\$ ${preco.toStringAsFixed(2)}", style: const TextStyle(color: Colors.brown, fontWeight: FontWeight.w600, fontSize: 15)),
                ],
              ),
            ),
            if (onAdicionarCarrinho != null)
              IconButton(
                icon: const Icon(Icons.add_shopping_cart, color: Colors.green),
                tooltip: 'Adicionar ao Carrinho',
                onPressed: onAdicionarCarrinho,
              ),
            if (onEditar != null)
              IconButton(icon: const Icon(Icons.edit, color: Colors.blue), onPressed: onEditar),
            if (onExcluir != null)
              IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: onExcluir),
          ],
        ),
      ),
    );
  }
}