import 'dart:convert';
import 'package:aula11_calc/dao/tarefa_dao.dart';
import 'package:aula11_calc/model/tarefa_model.dart';
import 'package:flutter/services.dart';

class TarefaPresenter {
  final TarefaDao db;

  TarefaPresenter(this.db);

  // Carregar JSON trasnformando em uma lista de tarefas
  Future<List<Tarefa>> carregarTarefas() async {
    List<Tarefa> tarefas = await db.listarTarefas();

    // Se não houver tarefas, carrega do JSON
    if (tarefas.isEmpty) {
      print("Banco de dados limpo");
      final jsonString = await rootBundle.loadString('assets/notas.json');
      final List<dynamic> jsonData = json.decode(jsonString);
      tarefas = jsonData.map((item) => Tarefa.fromJson(item)).toList();
    } else {
      print(
          "puxou informações do banco, estas foram as informações que vieram do banco: ");
      for (Tarefa t in tarefas) {
        print(t.toJson());
      }
    }
    return tarefas;
  }

  Future<List<Tarefa>> salvarTarefas(List<Tarefa> tarefas) async {
    for (Tarefa tarefa in tarefas) {
      tarefa.timestamp = DateTime.now(); // Define o timestamp atual
      await db.inserirTarefa(tarefa); // Insere a tarefa no banco de dados
    }
    return await db.listarTarefas();
  }

  //Função adicionada, responsavel por porcurar a tarefa deseajda
  Future<List<Tarefa>> carregaTarefa(String procura) async {
    final jsonString = await rootBundle.loadString('assets/notas.json');
    final List<dynamic> jsonData = json.decode(jsonString);
    List<Tarefa> lista = jsonData.map((item) => Tarefa.fromJson(item)).toList();
    //Até aqui é a mesma coisa que ja possuia

    // Filtra as tarefas puxando pelo titulo, jogando tudo para lowercase para evitar problemas
    List<Tarefa> resultado = lista
        //A função where tarefa arrow function contains é responsavel por procurar se existe algo relacionado aquilo, e é isso que habilita
        //a procura por uma parte do titulo.
        .where((tarefa) =>
            tarefa.titulo.toLowerCase().contains(procura.toLowerCase()))
        .toList();
    // Retorna a lista de tarefas filtradas (pode estar vazia se não houver resultados)
    return resultado;
  }

  Future<List<String>> inicializaNotas(
      Future<List<Tarefa>> tarefasFuture) async {
    List<Tarefa> tarefas = await tarefasFuture;
    List<String> notas = [];
    for (Tarefa temp in tarefas) {
      notas.add(temp.nota.toString());
    }
    return notas;
  }
}
