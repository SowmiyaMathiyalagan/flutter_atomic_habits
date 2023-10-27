import 'package:flutter/material.dart';
import 'package:flutter_atomic_habits/habit_list_screen.dart';
import 'package:intl/intl.dart';

import 'database_helper.dart';
import 'habit_model.dart';
import 'main.dart';

class EditHabitFormScreen extends StatefulWidget {
  const EditHabitFormScreen({Key? key}) : super(key: key);

  @override
  State<EditHabitFormScreen> createState() => _EditHabitFormScreenState();
}

class _EditHabitFormScreenState extends State<EditHabitFormScreen> {
  var _habitController = TextEditingController();
  var _dateController = TextEditingController();
  String selectedPriority = 'High';
  var _selectedFrequencyValue;
  var _frequencyDropdownlist = <DropdownMenuItem>[];

  //Edit only
  bool firstTimeFlag = false;
  int _selectedId = 0;

  @override
  void initState() {
    super.initState();
    getAllFrequency();
  }

  getAllFrequency() async {
    var frequencies =
        await dbHelper.queryAllRows(DatabaseHelper.frequencyTable);

    frequencies.forEach((frequency) {
      setState(() {
        _frequencyDropdownlist.add(
          DropdownMenuItem(
            child: Text(frequency['frequency']),
            value: frequency['frequency'],
          ),
        );
      });
    });
  }

  DateTime _dateTime = DateTime.now();

  _showDatePicker(BuildContext context) async {
    var _pickedDate = await showDatePicker(
        context: context,
        initialDate: _dateTime,
        firstDate: DateTime(2000),
        lastDate: DateTime(2050));

    if (_pickedDate != null) {
      setState(() {
        _dateTime = _pickedDate;
        _dateController.text = DateFormat('dd-MM-yyyy').format(_pickedDate);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    //Edit only
    if (firstTimeFlag == false) {
      print('--------> Once execute');

      firstTimeFlag = true;
      final habit = ModalRoute.of(context)!.settings.arguments as HabitModel;

      print('--------> Received Data:');
      print(habit.id);
      print(habit.habit);
      print(habit.date);
      print(habit.frequency);
      print(habit.priority);

      _selectedId = habit.id!;
      _habitController.text = habit.habit;
      _dateController.text = habit.date;
      _selectedFrequencyValue = habit.frequency;

      //Radio Button
      if (habit.priority == 'High') {
        selectedPriority = 'High';
      } else {
        selectedPriority = 'Low';
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Habit'),
        actions: [
          PopupMenuButton(
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 1,
                child: Text('Delete'),
              ),
            ],
            elevation: 2,
            onSelected: (value) {
              if (value == 1) {
                _deleteFormDialog(context);
              }
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            SingleChildScrollView(
              child: TextField(
                controller: _habitController,
                decoration: InputDecoration(
                  labelText: 'Habit',
                  hintText: 'Enter New Habit',
                ),
              ),
            ),
            SingleChildScrollView(
              child: TextField(
                controller: _dateController,
                decoration: InputDecoration(
                    labelText: 'Date',
                    hintText: 'Pick a Date',
                    prefixIcon: InkWell(
                      onTap: () {
                        _showDatePicker(context);
                      },
                      child: Icon(Icons.calendar_today),
                    )),
              ),
            ),
            DropdownButtonFormField(
              value: _selectedFrequencyValue,
              items: _frequencyDropdownlist,
              hint: Text('Frequency'),
              onChanged: (value) {
                setState(() {
                  _selectedFrequencyValue = value;
                  print(_selectedFrequencyValue);
                });
              },
            ),
            SizedBox(
              height: 20,
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SingleChildScrollView(
                  child: Text(
                    'Priority',
                    style: TextStyle(
                      fontSize: 17,
                    ),
                  ),
                ),
                RadioListTile(
                  title: Text('High'),
                  value: 'High',
                  groupValue: selectedPriority,
                  onChanged: (value) {
                    setState(() {
                      selectedPriority = value as String;
                    });
                  },
                ),
                RadioListTile(
                  title: Text('Low'),
                  value: 'Low',
                  groupValue: selectedPriority,
                  onChanged: (value) {
                    setState(() {
                      selectedPriority = value as String;
                    });
                  },
                ),
              ],
            ),
            SizedBox(
              height: 50,
            ),
            ElevatedButton(
              onPressed: () {
                _update();
              },
              child: Text('Update'),
            ),
          ],
        ),
      ),
    );
  }

  _update() async {
    //Id for Edit only
    print('-----------> Id: $_selectedId');
    print('-----------> Habit: $_habitController.text');
    print('-----------> Date: $_dateController.text');
    print('-----------> Frequency: $_selectedFrequencyValue');
    print('-----------> Priority: $selectedPriority');

    Map<String, dynamic> row = {
      //Id for Edit only
      DatabaseHelper.columnId: _selectedId,
      DatabaseHelper.columnHabit: _habitController.text,
      DatabaseHelper.columnDate: _dateController.text,
      DatabaseHelper.columnFrequency: _selectedFrequencyValue,
      DatabaseHelper.columnPriority: selectedPriority,
    };

    final result = await dbHelper.updateData(row, DatabaseHelper.habitsTable);

    debugPrint('-----------> Updated Row Id: $result');

    if (result > 0) {
      Navigator.pop(context);
      _showSuccessSnackBar(context, 'Updated');

      setState(() {
        Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => HabitListScreen()));
      });
    }
  }

  _deleteFormDialog(BuildContext context) {
    return showDialog(
        context: context,
        barrierDismissible: true,
        builder: (param) {
          return AlertDialog(
            actions: <Widget>[
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () async {
                  final result = await dbHelper.deleteData(
                      _selectedId, DatabaseHelper.habitsTable);

                  debugPrint('--------> Deleted Row Id: $result');

                  if (result > 0) {
                    _showSuccessSnackBar(context, 'Deleted');
                    Navigator.pop(context);
                    Navigator.of(context).pushReplacement(MaterialPageRoute(
                        builder: (context) => HabitListScreen()));
                  }
                },
                child: Text('Delete'),
              ),
            ],
            title: Text('Are you want to delete this?'),
          );
        });
  }

  void _showSuccessSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(new SnackBar(content: new Text(message)));
  }
}
