import 'dart:convert';
import 'dart:developer';

import 'package:f290_ddm2_todo_list/model/todo_model.dart';
import 'package:f290_ddm2_todo_list/services/data_service.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.light().copyWith(
        colorScheme: const ColorScheme.light(
          primary: Colors.orange,
          secondary: Colors.blueAccent,
        ),
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // 1. Lista para persistencia de estado das tarefas
  List toDoList = [];

  // 2. Controller para obter o texto referente às tarefas adicionadas
  final _controller = TextEditingController();

  // 3. Serviço para persisitir a lista de tarefas
  final _service = DataService();

  @override
  void initState() {
    super.initState();

    // 4. Preenchimento da carga de dados ao iniciar o App.
    _service.readData().then((data) {
      setState(() {
        log('JSON: $data');
        if (data != null) {
          toDoList = jsonDecode(data);
        }
      });
    });
  }

  final GlobalKey<FormFieldState<String>> _formKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ToDo List')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextFormField(
              maxLines: 2,
              controller: _controller,
              decoration: const InputDecoration(
                labelText: 'To Do',
                filled: true,
                prefixIcon: Icon(
                  Icons.text_fields_rounded,
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              // 5. Limite de elementos persistidos na lista
              itemCount: toDoList.length,
              itemBuilder: (context, position) {
                // 6. Conversao do item atual, com base no index, para um objeto ToDo
                var todo = Todo.fromJson(toDoList[position]);

                // 7. O Dismissible irá adicionar o comportamento do swipe para podermos fazer a deleção do item
                return Dismissible(
                  key: Key("$position"),
                  direction: DismissDirection.startToEnd,
                  background: Container(
                    color: Colors.red,
                    child: const Align(
                      alignment: Alignment.centerLeft,
                      child: Icon(
                        Icons.delete,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  onDismissed: (direction) {
                    setState(() {
                      // 8. Remoção do item na lista de referencia
                      toDoList.removeAt(position);

                      // 9. Chamada de serviço para persistir a remoção
                      _service.saveData(toDoList);
                    });
                  },
                  child: CheckboxListTile(
                    secondary: CircleAvatar(
                      // 10. Operador ternário para mudar o ícone com base em seu status
                      child: todo.concluido
                          ? const Icon(Icons.check)
                          : const Icon(Icons.warning),
                    ),
                    // 11. Conteúdo da tarefa
                    value: todo.concluido,
                    title: Text(
                      todo.conteudo,
                      style: TextStyle(
                          // 12. Operador ternário para alterar o estilo do texto com base em seu estado.
                          decoration: todo.concluido
                              ? TextDecoration.lineThrough
                              : TextDecoration.none),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Criada em ${todo.dataCriacao}'),
                        Text(
                          todo.dataConclusao.isEmpty
                              ? ''
                              : 'Finalizada em ${todo.dataConclusao}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    onChanged: (inChecked) {
                      // 13. Mudança de estado da tarefa
                      setState(() {
                        // Atualização de sintaxe de map JSON para objetos
                        todo.concluido = inChecked!;
                        if (inChecked) {
                          // 14. Formatação de data com intl.
                          todo.dataConclusao = DateFormat('d/M/y HH:mm:ss')
                              .format(DateTime.now());
                        } else {
                          todo.dataConclusao = '';
                        }

                        // 15. Persistencia da alteração de estado da tarefa.
                        toDoList[position] = todo.toJson();
                        _service.saveData(toDoList);
                      });
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
            setState(() {
              final conteudo = _controller.text;

              // Verifica se o Widget já foi criado pelo anteriormente
              if (!mounted) return;

              if (conteudo.isEmpty) {
                // Exibição de mensagem de validação de conteúdo obrigatório para preenchimento
                ScaffoldMessenger.of(context)
                  ..removeCurrentSnackBar()
                  ..showSnackBar(const SnackBar(
                    content: Text('Preencha a tarefa.'),
                  ));
                return;
              }

              var newTodo = Todo(conteudo: conteudo);

              // Atualização para conversao de objeto em mapa para persistencia em JSON
              toDoList.add(newTodo.toJson());
              _controller.text = '';

              _service.saveData(toDoList);
            });
          },
          icon: const Icon(Icons.add),
          label: const Text('Adicionar')),
    );
  }
}
