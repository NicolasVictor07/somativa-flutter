
abstract class ItemCardapio {
  String id;
  String nome;
  double preco;
  String urlImagem;

  ItemCardapio({
    required this.id,
    required this.nome,
    required this.preco,
    required this.urlImagem,
  });
}


class Bebida extends ItemCardapio {
  int tamanhoMl;

  Bebida({
    required super.id,
    required super.nome,
    required super.preco,
    required super.urlImagem,
    this.tamanhoMl = 200,
  });

  factory Bebida.fromJson(Map<String, dynamic> json) {
    return Bebida(
      id: json['id'].toString(),
      nome: json['nome'] ?? '',
      preco: double.tryParse(json['preco'].toString()) ?? 0.0,
      urlImagem: json['urlImagem'] ?? 'https://via.placeholder.com/100',
      tamanhoMl: json['tamanhoMl'] ?? 200,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nome': nome,
      'preco': preco,
      'urlImagem': urlImagem,
      'tamanhoMl': tamanhoMl,
    };
  }
}