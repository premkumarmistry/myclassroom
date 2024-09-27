import 'package:flutter/material.dart';
import 'package:parikshamadadkendra/be_co_sem1.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final drop_stream = ["Diploma", "Bachelors"];
  final drop_branch = [
    "Computer Engg",
    "Chemical Engg",
    "Mechanical Engg",
    "Civil Engg"
  ];

  final drop_semester = [
    "Semester 1",
    "Semester 2",
    "Semester 3",
    "Semester 4",
    "Semester 5",
    "Semester 6",
    "Semester 7",
    "Semester 8"
  ];

  String? selected_semester = "Semester 1";
  String? selected_branch = "Computer Engg";
  String? selected_stream = "Diploma";

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Flutter App",
      home: Scaffold(
        appBar: AppBar(
          title: const Text(
            "Pariksha Madad Kendra",
            style: TextStyle(color: Colors.blue),
          ),
        ),
        body: Builder(
          builder: (BuildContext context) {
            return SingleChildScrollView(
              child: Center(
                child: SizedBox(
                  child: Column(
                    children: [
                      const SizedBox(height: 100),
                      SizedBox(
                        width: 250,
                        child: DropdownButtonFormField(
                          value: selected_stream,
                          items: drop_stream.map((e) {
                            return DropdownMenuItem(
                              value: e,
                              child: Text(e),
                            );
                          }).toList(),
                          onChanged: (val) {
                            setState(() {
                              selected_stream = val;
                            });
                          },
                          dropdownColor: Colors.white,
                          decoration: const InputDecoration(
                            labelText: "Select your Stream",
                            border: OutlineInputBorder(),
                          ),
                          icon: const Icon(
                            Icons.arrow_drop_down_circle,
                            color: Colors.deepPurple,
                          ),
                        ),
                      ),
                      const SizedBox(height: 25),
                      SizedBox(
                        width: 250,
                        child: DropdownButtonFormField(
                          value: selected_branch,
                          items: drop_branch.map((w) {
                            return DropdownMenuItem(
                              value: w,
                              child: Text(w),
                            );
                          }).toList(),
                          onChanged: (w) {
                            setState(() {
                              selected_branch = w;
                            });
                          },
                          dropdownColor: Colors.white,
                          decoration: const InputDecoration(
                            labelText: "Select your Branch",
                            border: OutlineInputBorder(),
                          ),
                          icon: const Icon(
                            Icons.arrow_drop_down_circle,
                            color: Colors.deepPurple,
                          ),
                        ),
                      ),
                      const SizedBox(height: 25),
                      SizedBox(
                        width: 250,
                        child: DropdownButtonFormField(
                          value: selected_semester,
                          items: drop_semester.map((q) {
                            return DropdownMenuItem(
                              value: q,
                              child: Text(q),
                            );
                          }).toList(),
                          onChanged: (q) {
                            setState(() {
                              selected_semester = q;
                            });
                          },
                          dropdownColor: Colors.white,
                          decoration: const InputDecoration(
                            labelText: "Select your Semester",
                            border: OutlineInputBorder(),
                          ),
                          icon: const Icon(
                            Icons.arrow_drop_down_circle,
                            color: Colors.deepPurple,
                          ),
                        ),
                      ),
                      const SizedBox(height: 25),
                      TextButton(
                        onPressed: () {
                          print("Hello");
                          if (selected_stream == "Bachelors" &&
                              selected_semester == "Semester 5" &&
                              selected_branch == "Computer Engg") {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => DetailsPage()),
                            );
                          } else {
                            print("Maa chuda");
                          }

                        },
                        style: TextButton.styleFrom(
                          backgroundColor: Colors.white,
                          padding: EdgeInsets.all(16), // Add some padding
                          shape: RoundedRectangleBorder(
                            side: BorderSide(color: Colors.black, width: 2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text("Submit"),
                      ),
                      const SizedBox(height: 100),
                    /*  GestureDetector(
                        onTap: () {
                          if (selected_stream == "Bachelors" &&
                              selected_semester == "Semester 5" &&
                              selected_branch == "Computer Engg") {
                            print("Success");
                          } else {
                            print("Maa chuda");
                          }
                        },
                        child: Text(
                          "Semester 1",
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),*/
                      const SizedBox(height: 20),
                     /* Container(
                        width: 400,
                        child: Table(
                          textDirection: TextDirection.rtl,
                          defaultVerticalAlignment: TableCellVerticalAlignment.bottom,
                          border: TableBorder.all(width: 2.0, color: Colors.black),
                          children: [
                            TableRow(children: [
                              Text(" Contents", textScaleFactor: 1.5),
                              Text(" Subject Name", textScaleFactor: 1.5),
                              Text(" Sr no.", textScaleFactor: 1.5),
                            ]),
                            TableRow(children: [
                              Text(" N/A", textScaleFactor: 1.5),
                              Text(" Introduction to \n java", textScaleFactor: 1.5),
                              Text(" 1.", textScaleFactor: 1.5),
                            ]),
                            TableRow(children: [
                              Text(" N/A", textScaleFactor: 1.5),
                              Text(" Python \n Programming", textScaleFactor: 1.5),
                              Text(" 2.", textScaleFactor: 1.5),
                            ]),
                            TableRow(children: [
                              Text(" N/A", textScaleFactor: 1.5),
                              Text(" Data \n Mining", textScaleFactor: 1.5),
                              Text(" 3.", textScaleFactor: 1.5),
                            ]),
                          ],
                        ),
                      ),*/
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
