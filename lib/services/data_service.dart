import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

class DataService {

  Future<File> getFile() async {
    final directory = await getApplicationDocumentsDirectory();
    return File('${directory.path}/data.json');
  }

  Future<File> saveData(List toDoList) async {
    var data = jsonEncode(toDoList);
    var file = await getFile();

    return file.writeAsString(data);
  }

  Future<String?> readData() async {
    try {
      File file = await getFile();
      return file.readAsString();
    } catch(e) {
      return null;
    }
  }
}