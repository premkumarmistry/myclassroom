import 'package:flutter/material.dart';

class Attendancemanagementpage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Attendance Management Page"),
        backgroundColor: Colors.deepPurple,
        centerTitle: true,
      ),
      body: Center(
        child: Text(
          "This is Attendance Management Page",
            style: Theme.of(context).textTheme.bodyLarge
        ),
      ),
    );
  }
}
