import 'package:aula11_calc/model/tarefa_model.dart';
import 'package:aula11_calc/presenter/tarefa_presenter.dart';
import 'package:flutter/material.dart';

class TarefaView extends StatefulWidget {
  final TarefaPresenter presenter;

  TarefaView({required this.presenter});

  @override
  _TarefasViewState createState() => _TarefasViewState();
}

class _TarefasViewState extends State<TarefaView> {
  late Future<List<Tarefa>> _tarefas;
  String pesquisa = "";
  List<String> _notas = []; // Mantém como List<String>

  @override
  void initState() {
    super.initState();
    _tarefas = widget.presenter.carregarTarefas();
    _inicializarNotas(); // Chama a função para inicializar as notas
  }

  Future<void> _inicializarNotas() async {
    _notas = await widget.presenter
        .inicializaNotas(_tarefas); // Aguarda a inicialização das notas
    setState(() {}); // Atualiza a view após carregar as notas
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Notas dos Trabalhos'),
      ),
      body: Column(
        children: [
          Expanded(
            child: FutureBuilder<List<Tarefa>>(
              future: _tarefas,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Erro ao carregar tarefas'));
                }

                final tarefas = snapshot.data!;
                return ListView.builder(
                  itemCount: tarefas.length,
                  itemBuilder: (context, index) {
                    final tarefa = tarefas[index];
                    return ListTile(
                      title: Text(tarefa.titulo),
                      subtitle: Text('Peso: ${tarefa.peso}'),
                      trailing: Container(
                        width: 100,
                        child: TextField(
                          controller:
                              TextEditingController(text: _notas[index]),
                          decoration: InputDecoration(labelText: 'Nota'),
                          keyboardType: TextInputType.number,
                          onChanged: (value) {
                            tarefa.nota =
                                double.tryParse(value); // Atualiza a nota
                          },
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          TextField(
            decoration: InputDecoration(labelText: 'Insira o nome da tarefa'),
            keyboardType: TextInputType.text,
            onChanged: (value) {
              pesquisa = value;
            },
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: () {
              _carregarTarefas(pesquisa);
            },
            child: Text('Pesquisar'),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.save),
        onPressed: () async {
          final tarefas = await _tarefas;
          await widget.presenter.salvarTarefas(tarefas);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Notas salvas com sucesso')),
          );
        },
      ),
    );
  }

  void _carregarTarefas(String procura) async {
    final List<Tarefa>? tarefas = await widget.presenter.carregaTarefa(procura);
    if (tarefas != null) {
      setState(() {
        _tarefas = Future.value(tarefas);
      });
    }
  }
}
