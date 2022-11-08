import 'package:intl/intl.dart';

class Todo {
  String conteudo;
  bool concluido = false;
  String dataCriacao = DateFormat('d/M/y HH:mm:ss').format(DateTime.now());
  String dataConclusao = '';

  Todo({required this.conteudo});

  // Construtor nomeado para criar objeto Todo a partir de um Mapa
  Todo.fromJson(Map<String, dynamic> map) :
    this.conteudo = map['conteudo'],
    this.concluido = map['concluido'],
    this.dataCriacao = map['dataCriacao'],
    this.dataConclusao = map['dataConclusao'];

  // COnversao de um objeto em Mapa
  Map<String, dynamic> toJson() {
    return {
      'conteudo': conteudo,
      'concluido': concluido,
      'dataCriacao': dataCriacao,
      'dataConclusao': dataConclusao
    };
  }
}
