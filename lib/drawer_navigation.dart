
import 'package:flutter/material.dart';
import 'package:flutter_atomic_habits/main.dart';

import 'database_helper.dart';
import 'frequency_list_screen.dart';
import 'habit_by_frequency.dart';
import 'habit_list_screen.dart';


class DrawerNavigation extends StatefulWidget {
  const DrawerNavigation({Key? key}) : super(key: key);

  @override
  State<DrawerNavigation> createState() => _DrawerNavigationState();
}

class _DrawerNavigationState extends State<DrawerNavigation> {
  List<Widget> _frequencyList = <Widget>[];

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
        _frequencyList.add(InkWell(
          onTap: () {
            print('---------> Selected Category:');
            print(frequency['_id']);
            print(frequency['frequency']);

            Navigator.of(context).push(new MaterialPageRoute(
                builder: (context) =>
                    HabitByFrequency(frequency: frequency['frequency'])));
          },
          child: ListTile(
            title: SingleChildScrollView(child: Text(frequency['frequency'])),
          ),
        ));
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Drawer(
        child: ListView(
          children: [
            UserAccountsDrawerHeader(
              accountName: Text(
                'Atomic Habit',
                style: TextStyle(fontSize: 16.0),
              ),
              accountEmail: Text('Version 1.0'),
              currentAccountPicture: CircleAvatar(
                radius: 50,
                backgroundImage: AssetImage('images/atomic_habit.png'),
              ),
            ),
            ListTile(
              leading: Icon(
                Icons.home,
              ),
              title: Text('Habit List'),
              onTap: () {
                Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => HabitListScreen()));
              },
            ),
            ListTile(
              leading: Icon(
                Icons.view_list_rounded,
              ),
              title: Text('Frequency list'),
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => FrequencyListScreen()));
              },
            ),
            Divider(),
            Column(
              children: _frequencyList,
            ),
          ],
        ),
      ),
    );
  }
}
