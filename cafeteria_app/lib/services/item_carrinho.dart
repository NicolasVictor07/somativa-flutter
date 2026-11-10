import '../models/produto.dart';

class ItemCarrinho {
  final Bebida bebida;
  int quantidade;

  ItemCarrinho({
    required this.bebida,
    this.quantidade = 1,
  });

  double get subtotal => bebida.preco * quantidade;
}