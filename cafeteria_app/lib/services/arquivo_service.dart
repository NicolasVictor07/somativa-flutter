import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ArquivoService {
  // Persistência no Armazenamento Interno 
  static Future<void> salvarRegistroInterno(String texto) async {
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      List<String> historico = prefs.getStringList('pedidos_disco') ?? [];
      historico.add(texto);
      await prefs.setStringList('pedidos_disco', historico);
      return;
    }

    final dir = await getApplicationDocumentsDirectory();
    final ficheiro = File('${dir.path}/pedidos.txt');
    await ficheiro.writeAsString('$texto\n', mode: FileMode.append);
  }

  // Persistência no Armazenamento Externo
  static Future<String> exportarRelatorioExterno(String conteudoCsv) async {
    if (kIsWeb) {
      return 'Armazenamento externo simulado na Web.';
    }

    // Procura o diretório de armazenamento externo do dispositivo
    Directory? dirExterno = await getExternalStorageDirectory();
    dirExterno ??= await getApplicationDocumentsDirectory();

    final ficheiroExterno = File('${dirExterno.path}/relatorio_vendas_cafeteria.csv');
    await ficheiroExterno.writeAsString(conteudoCsv);
    return 'Ficheiro exportado para: ${ficheiroExterno.path}';
  }

  static Future<String> lerHistorico() async {
    try {
      if (kIsWeb) {
        final prefs = await SharedPreferences.getInstance();
        List<String> historico = prefs.getStringList('pedidos_disco') ?? [];
        if (historico.isEmpty) return 'Nenhum pedido registado.';
        return historico.join('\n');
      }

      final dir = await getApplicationDocumentsDirectory();
      final ficheiro = File('${dir.path}/pedidos.txt');
      if (!await ficheiro.exists()) return 'Nenhum pedido registado.';
      return await ficheiro.readAsString();
    } catch (e) {
      return 'Nenhum pedido registado.';
    }
  }
}