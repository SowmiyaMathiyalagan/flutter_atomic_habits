
import 'package:flutter/material.dart';
import 'package:flutter_atomic_habits/main.dart';
import 'package:intl/intl.dart';

import 'database_helper.dart';
import 'habit_list_screen.dart';

class HabitFormScreen extends StatefulWidget {
  const HabitFormScreen({Key? key}) : super(key: key);

  @override
  State<HabitFormScreen> createState() => _HabitFormScreenState();
}

class _HabitFormScreenState extends State<HabitFormScreen> {
  var _habitController = TextEditingController();
  var _dateController = TextEditingController();
  String selectedPriority = 'High';
  var _selectedFrequencyValue;
  var _frequencyDropdownlist = <DropdownMenuItem>[];

  @override
  void initState(){
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

    if (_pickedDate !=null) {
      setState(() {
        _dateTime = _pickedDate;
        _dateController.text = DateFormat('dd-MM-yyyy').format(_pickedDate);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('New Habit'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: <Widget>[
              TextField(
                controller: _habitController,
                decoration: InputDecoration(
                  labelText: 'Habit',
                  hintText: 'Enter New Habit',
                ),
              ),
              TextField(
                controller: _dateController,
                decoration: InputDecoration(
                  labelText: 'Date',
                  hintText: 'Pick a Date',
                  prefixIcon: SingleChildScrollView(
                    child: InkWell(
                      onTap: () {
                        _showDatePicker(context);
                      },
                      child: Icon(Icons.calendar_today),
                    ),
                  )
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
              SingleChildScrollView(
                child: Column(
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
              ),
              SizedBox(
                height: 50,
              ),
              ElevatedButton(
                onPressed: () {
                  _save();
                },
                child: Text('Save'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  _save() async {
    print('-----------> Habit: $_habitController.text');
    print('-----------> Date: $_dateController.text');
    print('-----------> Frequency: $_selectedFrequencyValue');
    print('-----------> Priority: $selectedPriority');

    Map<String, dynamic> row = {
      DatabaseHelper.columnHabit: _habitController.text,
      DatabaseHelper.columnDate: _dateController.text,
      DatabaseHelper.columnFrequency: _selectedFrequencyValue,
      DatabaseHelper.columnPriority: selectedPriority,
    };

    final result = await dbHelper.insertData(row, DatabaseHelper.habitsTable);

    if (result > 0) {
      Navigator.pop(context);
      _showSuccessSnackBar(context, 'Saved');

      setState(() {
        Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => HabitListScreen()));
      });
    }
  }

  void _showSuccessSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(new SnackBar(content: new Text(message)));
  }
}
