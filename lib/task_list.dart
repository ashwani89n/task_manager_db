import 'dart:convert';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class TaskScreenList extends StatefulWidget {
  const TaskScreenList({super.key});

  @override
  State<TaskScreenList> createState() => _TaskScreenListState();
}

class _TaskScreenListState extends State<TaskScreenList> {
  final TextEditingController _taskController = TextEditingController();
  DatabaseReference databaseReference = FirebaseDatabase.instance.ref("tasks");

  List<String> tasks = [];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [Text('Task Manager')],
        ),
        backgroundColor: Colors.black87,
      ),
      body: Column(
        verticalDirection: VerticalDirection.down,
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: tasks.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(
                    tasks[index],
                    style: const TextStyle(
                      color: Colors.black,
                    ),
                  ),
                  // title: Text(tasks[index].name,),
                  trailing: IconButton(
                    onPressed: () {
                      deleteTask(tasks[index]);
                    },
                    icon: const Icon(Icons.delete, color: Colors.black),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _taskController,
                    decoration: const InputDecoration(
                      labelText: 'Enter Task Name',
                      labelStyle: TextStyle(color: Colors.black),
                      fillColor: Colors.white, // Change the background color
                      filled: true,
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.black),
                      ),
                    ),
                    onSubmitted: (taskName) {
                      if (taskName.isNotEmpty) {
                        addTask(taskName);
                        setState(() {
                          taskName = '';
                        });
                      }
                    },
                  ),
                ),
                const SizedBox(
                  width: 16,
                ),
                ElevatedButton(
                  onPressed: () {
                    if (_taskController.text.isNotEmpty) {
                      addTask(_taskController.text);
                      setState(() {
                        _taskController.text = '';
                      });
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black, // Background color
                    foregroundColor: Colors.white, // Text color
                  ),
                  child: const Text(
                    'Add Task',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                const SizedBox(
                  width: 16,
                ),
                ElevatedButton(
                  onPressed: retriveData,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black, // Background color
                    foregroundColor: Colors.white, // Text color
                  ),
                  child: const Text(
                    'Fetch Task',
                    style: TextStyle(color: Colors.white),
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    retriveData();
    setState(() {});
    super.initState();
  }

  void addTask(String taskName) {
    debugPrint("Add");
    DatabaseReference database = FirebaseDatabase.instance.ref("tasks");
    print("Saved");
    String data = taskName;
    database.push().set(data);
    retriveData();
    setState(() {});
  }

  Future<void> retriveData() async {
    tasks = [];
    DatabaseEvent data = await databaseReference.once();
    Object? strData = data.snapshot.value;
    if (strData != null) {
      String jsonEn = jsonEncode(strData);

      Map<String, dynamic> jsonDe = jsonDecode(jsonEn);
      Iterable<dynamic> vals = jsonDe.values;
      for (String val in vals) {
        tasks.add(val);
      }
    }
    setState(() {});
  }

  void toogleCompletion(int index) {
    setState(() {});
  }

  Future<void> deleteTask(String taskName) async {
    debugPrint("Delete");
    String deleteKey = '';
    DatabaseEvent data = await databaseReference.once();
    Object? strData = data.snapshot.value;
    String jsonEn = jsonEncode(strData);
    Map<String, dynamic> jsonDe = jsonDecode(jsonEn);
    for (final String key in jsonDe.keys) {
      if (jsonDe[key] == taskName) {
        deleteKey = key;
      }
    }
    if (deleteKey != '') {
      debugPrint('$deleteKey');
      await databaseReference.child(deleteKey).remove();
      retriveData();
    }
  }
}
