import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'app_color.dart';
import 'widget_background.dart';

class CreateTaskScreen extends StatefulWidget {
  final bool isEdit;
  final String documentId;  // Ganti ke documentId
  final String name;
  final String description;
  final String date;

  // Konstruktor untuk CreateTaskScreen
  CreateTaskScreen({
    required this.isEdit,
    this.documentId = '',  // Ganti taskId dengan documentId
    this.name = '',
    this.description = '',
    this.date = '',
  });

  @override
  _CreateTaskScreenState createState() => _CreateTaskScreenState();
}

class _CreateTaskScreenState extends State<CreateTaskScreen> {
  final GlobalKey<ScaffoldState> scaffoldState = GlobalKey<ScaffoldState>();
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final AppColor appColor = AppColor();
  final TextEditingController controllerName = TextEditingController();
  final TextEditingController controllerDescription = TextEditingController();
  final TextEditingController controllerDate = TextEditingController();

  late double widthScreen;
  late double heightScreen;
  DateTime date = DateTime.now().add(Duration(days: 1));
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.isEdit) {
      controllerName.text = widget.name;
      controllerDescription.text = widget.description;
      controllerDate.text = widget.date;
    }
  }

  @override
  Widget build(BuildContext context) {
    MediaQueryData mediaQueryData = MediaQuery.of(context);
    widthScreen = mediaQueryData.size.width;
    heightScreen = mediaQueryData.size.height;

    return Scaffold(
      key: scaffoldState,
      backgroundColor: appColor.colorPrimary,
      body: SafeArea(
        child: Stack(
          children: <Widget>[
            WidgetBackground(),
            _buildWidgetCreateTask(),
          ],
        ),
      ),
    );
  }

  Widget _buildWidgetCreateTask() {
    return Container(
      padding: EdgeInsets.all(16.0),
      child: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(top: 32.0),
            child: Text(
              widget.isEdit ? 'Edit Task' : 'Create Task',
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
          SizedBox(height: 16.0),
          TextField(
            controller: controllerName,
            decoration: InputDecoration(
              labelText: 'Task Name',
              hintText: 'Enter Task Name',
            ),
          ),
          SizedBox(height: 16.0),
          TextField(
            controller: controllerDescription,
            decoration: InputDecoration(
              labelText: 'Task Description',
              hintText: 'Enter Task Description',
            ),
          ),
          SizedBox(height: 16.0),
          TextField(
            controller: controllerDate,
            readOnly: true,
            decoration: InputDecoration(
              labelText: 'Task Date',
              hintText: 'Select Date',
            ),
            onTap: () async {
              DateTime? pickedDate = await showDatePicker(
                context: context,
                initialDate: date,
                firstDate: DateTime.now(),
                lastDate: DateTime(2101),
              );
              if (pickedDate != null && pickedDate != date) {
                setState(() {
                  date = pickedDate;
                  controllerDate.text = DateFormat('yyyy-MM-dd').format(date);
                });
              }
            },
          ),
          SizedBox(height: 16.0),
          ElevatedButton(
            onPressed: isLoading ? null : _onSaveTask,
            child: Text(widget.isEdit ? 'Update Task' : 'Create Task'),
          ),
        ],
      ),
    );
  }

  void _onSaveTask() async {
    if (controllerName.text.isNotEmpty && controllerDescription.text.isNotEmpty) {
      setState(() {
        isLoading = true;
      });

      String name = controllerName.text.trim();
      String description = controllerDescription.text.trim();
      String date = controllerDate.text;

      if (widget.isEdit) {
        // Memperbarui tugas yang ada
        DocumentReference documentTask = firestore.collection('tasks').doc(widget.documentId);
        firestore.runTransaction((transaction) async {
          DocumentSnapshot task = await transaction.get(documentTask);
          if (task.exists) {
            await transaction.update(documentTask, {
              'name': name,
              'description': description,
              'date': date,
            });
            Navigator.pop(context, true);
          } else {
            _showSnackBarMessage('Task not found');
          }
        });
      } else {
        // Membuat tugas baru
        firestore.collection('tasks').add({
          'name': name,
          'description': description,
          'date': date,
        });
        Navigator.pop(context, true);
      }
    }
  }

  void _showSnackBarMessage(String message) {
    scaffoldState.currentState?.showSnackBar(SnackBar(
      content: Text(message),
    ));
  }
}

extension on ScaffoldState? {
  void showSnackBar(SnackBar snackBar) {}
}
