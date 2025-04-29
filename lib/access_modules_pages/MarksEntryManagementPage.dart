import 'package:flutter/material.dart';

class Marksentrymanagementpage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("MarksEntry Management Page"),
        backgroundColor: Colors.deepPurple,
        centerTitle: true,
      ),
      body: Center(
        child:  Text("This is MarksEntry Management Page", style: Theme.of(context).textTheme.bodyLarge

        ),

        ),

    );
  }
}
