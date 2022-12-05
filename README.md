# f290_ddm2_todo_list

## Main Widget

Crie o widget principal e configure o tema do App com as cores laranja e e azul

```dart
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
```

## HomePage - Parte I

Crie a página principal do App; no arquivo `pages/home/home_page.dart`.

```dart
class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ToDo List')),
      body: Center(child: Text('Body')),
      ),
      floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
            //TODO: 
          },
          icon: const Icon(Icons.add),
          label: const Text('Adicionar')),
    );
  }
}
```

## Service para Persistência de Dados em Arquivo

Para que possamos persistir os dados da Lista de tarefas iremos criar um Service para facilitar o desenvolvimento.

1. Crie o arquivo `services\data_service.dart`e adicione o código abaixo.

```dart
import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

class DataService {
  // Obtem o arquivo de dados independente da plataforma; todos os métodos do serviço serão assícronos, então utilizaremos sempre a dupla async e await quando utilizarmos retornos Futures.
  Future<File> getFile() async {
    // Obtém a localização do local de armazenamento dos dispositivos suportados pelo Flutter, voce não precisa se preocupar com a localização em cada plataforma.
    final directory = await getApplicationDocumentsDirectory();
    return File('${directory.path}/data.json');
  }

  Future<File> saveData(List toDoList) async {
    // Convertendo a lista de Maps em JSON
    var data = jsonEncode(toDoList);
    var file = await getFile();

    return file.writeAsString(data);
  }

  Future<String?> readData() async {
    try {
      File file = await getFile();

      // Convertendo o arquivo de dados JSON em uma String.
      return file.readAsString();
    } catch (e) {
      return null;
    }
  }
}
```

2. Faça uma chamada ao serviço no `initState`, este método é executado quando a aplicação é carregada e ele irá carregar os dados persistidos no arquivo de dados para realizar o preenchimento de dados da lista de tarefas.

```dart
@override
  void initState() {
    super.initState();

    _service.readData().then((data) {
      setState(() {
        log('JSON: $data');
        if (data != null) {
          toDoList = jsonDecode(data);
        }
      });
    });
  }
```

## HomePage - Parte II

1. Substitua o `Center` por uma `Column`.
2. Inclua na `Column` um `TextField`.

```dart
body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextFormField(
              maxLines: 2,
              // Adição do controlador de texto
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
```

3. Adicione um `Expanded` para ocupar o restante do espaço da tela com um `ListView`, logo abaixo do `Padding`.

```dart
    Expanded(
    child: ListView.builder(
        itemCount: toDoList.length,
        itemBuilder: (context, position) {        
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
                //TODO:
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
                    style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                ],
            ),
            onChanged: (inChecked) {      
                //TODO:          
            },
            ),
        );
        },
    ),
    ),
```
