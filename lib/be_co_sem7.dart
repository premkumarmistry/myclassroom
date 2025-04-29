import 'package:flutter/material.dart';
import 'package:parikshamadadkendra/be_computer/be_co_sem1_subjects/programming_in_c++.dart';
import 'package:parikshamadadkendra/be_computer/be_co_sem7_subjects/compiler_design.dart';
import 'package:parikshamadadkendra/be_computer/be_co_sem7_subjects/machine_learning.dart';

class BeCoSem7 extends StatelessWidget {
  final String? stream;
  final String? branch;
  final String? semester;

  const BeCoSem7({Key? key, this.stream, this.branch, this.semester})
      : super(key: key);

  // Method to navigate to the subject detail page
  void _navigateToSubject(BuildContext context, String subjectName) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SubjectDetailPage(subjectName: subjectName),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Subject Details",
          style: TextStyle(fontWeight: FontWeight.bold,color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Colors.grey,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              textAlign: TextAlign.center,
              "BE Computer Engineering - Semester 1",
              style: TextStyle(

                fontSize: isTablet ? 24 : 20,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: Table(
                textDirection: TextDirection.ltr,
                defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                border: TableBorder.all(
                  width: 2.5,
                  color: Colors.grey.shade400,
                ),
                columnWidths: {
                  0: FixedColumnWidth(100), // Width for Sr No
                  1: FlexColumnWidth(2), // Auto width for Subject Name
                  2: FixedColumnWidth(100), // Auto width for Contents
                },
                children: [
                  _buildTableHeader(),
                  _buildTableRow(
                    context,
                    "1.",
                    "Machine Learning",
                    "View Details",
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => MachineLearning()),
                    ),
                  ),
                  _buildTableRow(
                    context,
                    "2.",
                    "Compiler Design",
                    "View Details",
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => CompilerDesign()),
                    ),
                  ),
                  _buildTableRow(
                    context,
                    "3.",
                    "Computer Vision",
                    "View Details",
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => ProgrammingInCPlusPlus()),
                    ),
                  ),
                  _buildTableRow(
                    context,
                    "4.",
                    "Software Testing Quality Assurance",
                    "View Details",
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => ProgrammingInCPlusPlus()),
                    ),
                  ),

                  _buildTableRow(
                    context,
                    "5.",
                    "Cyber Forensics and Cyber Laws",
                    "View Details",
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => ProgrammingInCPlusPlus()),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  TableRow _buildTableHeader() {
    return TableRow(
      decoration: BoxDecoration(color: Colors.grey.shade300),
      children: const [
        Padding(
          padding: EdgeInsets.all(12.0),
          child: Text(
            "Sr no",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.all(12.0),
          child: Text(
            "Subject Name",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.all(12.0),
          child: Text(
            "Contents",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
        ),
      ],
    );
  }

  TableRow _buildTableRow(
      BuildContext context,
      String srNo,
      String subjectName,
      String content,
      {VoidCallback? onTap}
      ) {
    return TableRow(
      decoration: BoxDecoration(
        color: Colors.white,
      ),
      children: [
        Padding(
          padding: const EdgeInsets.all(12.0),
          child: Text(
            srNo,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16),
          ),
        ),
        GestureDetector(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Text(
              subjectName,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.black,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(12.0),
          child: Text(
            content,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16, color: Colors.blue),
          ),
        ),
      ],
    );
  }
}

// Placeholder Subject Detail Page
class SubjectDetailPage extends StatelessWidget {
  final String subjectName;

  const SubjectDetailPage({Key? key, required this.subjectName}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(subjectName),
        backgroundColor: Colors.deepOrange,
      ),
      body: Center(
        child: Text(
          "Details for $subjectName",
          style: const TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
