import 'dart:convert';

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
      theme: ThemeData(
          primarySwatch: Colors.deepOrange, accentColor: Colors.blueAccent),
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List toDoList = [];
  final _controller = TextEditingController();
  final _service = DataService();

  @override
  void initState() {
    super.initState();

    _service.readData().then((data) {
      setState(() {
        print('JSON: $data');
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
              itemCount: toDoList.length,
              itemBuilder: (context, position) {
                // Conversao de mapa para objeto
                var todo = Todo.fromJson(toDoList[position]);
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
                      toDoList.removeAt(position);
                      _service.saveData(toDoList);
                    });
                  },
                  child: CheckboxListTile(
                    secondary: CircleAvatar(
                      child: todo.concluido
                          ? const Icon(Icons.check)
                          : const Icon(Icons.warning),
                    ),
                    value: todo.concluido,
                    title: Text(
                      todo.conteudo,
                      style: TextStyle(
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
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    onChanged: (inChecked) {
                      setState(() {
                        // Atualização de sintaxe de mapa para objetos
                        todo.concluido = inChecked!;
                        if (inChecked) {
                          todo.dataConclusao = DateFormat('d/M/y HH:mm:ss')
                              .format(DateTime.now());
                        } else {
                          todo.dataConclusao = '';
                        }

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

              if (!mounted) return;

              if (conteudo.isEmpty) {
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
