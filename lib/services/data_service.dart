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
