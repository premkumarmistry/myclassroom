import 'package:flutter/material.dart';

class FeedbackPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Feedback Management Page"),
        backgroundColor: Colors.deepPurple,
        centerTitle: true,
      ),
      body: Center(
        child: Text(
          "This is Feedback Management Page",
            style: Theme.of(context).textTheme.bodyLarge
        ),
      ),
    );
  }
}
