// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class CompilerDesign extends StatelessWidget {
  // Google Drive Links
  final String chapter1PdfLink =
      'https://drive.google.com/file/d/1fEU9ZeWQ3olfMqb4Re5PlbVlmUmAXQvT/view?usp=sharing';
  final String chapter1PptLink =
      'https://docs.google.com/presentation/d/1NcHCgq3jfo_427hxGx_IZ80o_uq4pEfJ/edit?usp=sharing';
  final String chapter2PdfLink =
      'https://drive.google.com/file/d/1v6toq-Lc2bz5oKudN9Sn_I80tbzB65eW/view?usp=sharing';
  final String chapter2PptLink =
      'https://drive.google.com/file/d/your_chapter2_ppt_link';
  final String chapter3PdfLink =
      'https://drive.google.com/file/d/your_chapter3_pdf_link';
  final String chapter3PptLink =
      'https://drive.google.com/file/d/your_chapter3_ppt_link';
  final String chapter4PdfLink =
      'https://drive.google.com/file/d/your_chapter4_pdf_link';
  final String chapter4PptLink =
      'https://drive.google.com/file/d/your_chapter4_ppt_link';

  // Previous year papers links
  final String javaBasicsPaperLink =
      'https://drive.google.com/file/d/your_java_basics_paper_link';
  final String oopPaperLink =
      'https://drive.google.com/file/d/your_oop_paper_link';

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Compiler Design",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Colors.grey,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Syllabus Section
              Text(
                "Syllabus: Compiler Design",
                style: TextStyle(
                    fontSize: isTablet ? 24 : 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.deepOrange),
              ),
              const SizedBox(height: 20),

              // Download button for Syllabus
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Download Syllabus",
                      style: TextStyle(fontSize: isTablet ? 20 : 16)),
                  IconButton(
                    icon: Icon(Icons.download),
                    onPressed: () {
                      // Implement syllabus download functionality here
                    },
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Chapter-wise Materials Section
              Text(
                "Chapter-wise Materials",
                style: TextStyle(
                    fontSize: isTablet ? 22 : 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),

              Center(
                child: Container(
                  padding: const EdgeInsets.all(8.0),
                  width: double.infinity,
                  child: Table(
                    border: TableBorder.all(width: 2.0, color: Colors.black),
                    columnWidths: {
                      0: FlexColumnWidth(2), // Adjusted for flexible width
                      1: FlexColumnWidth(1), // Adjusted for PDF
                      2: FlexColumnWidth(1), // Adjusted for PPT
                    },
                    children: [
                      _buildTableRow(
                        "Chapter",
                        "PDF",
                        "PPT",
                      ),
                      _buildTableRowWithLinks(
                          context, "Chapter 1: Overview of the Compiler and its Structure", chapter1PdfLink, chapter1PptLink),
                      _buildTableRowWithLinks(
                          context, "Chapter 2: Lexical Analysis", chapter2PdfLink, chapter2PptLink),
                      _buildTableRowWithLinks(
                          context, "Chapter 3: Syntax Analysis", chapter3PdfLink, chapter3PptLink),
                      _buildTableRowWithLinks(
                          context, "Chapter 4: Intermediate-Code Generation ", chapter4PdfLink, chapter4PptLink),

                      _buildTableRowWithLinks(
                          context, "Chapter 5: Code Generation and Optimization", chapter3PdfLink, chapter3PptLink),
                      _buildTableRowWithLinks(
                          context, "Chapter 6: Instruction-Level Parallelism ", chapter4PdfLink, chapter4PptLink),


                    ],
                  ),
                ),
              ),

              // Previous Year Question Papers Section
              const SizedBox(height: 20),
              Text(
                "Previous Year Question Papers",
                style: TextStyle(
                    fontSize: isTablet ? 22 : 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Center(
                child: Container(
                  padding: const EdgeInsets.all(8.0),
                  width: double.infinity,
                  child: Table(
                    border: TableBorder.all(width: 2.0, color: Colors.black),
                    columnWidths: {
                      0: FlexColumnWidth(2),
                      1: FlexColumnWidth(1),
                    },
                    children: [
                      _buildTableRowWithLinks(context, "Unit Test 1", javaBasicsPaperLink),
                      _buildTableRowWithLinks(context, "Unit Test 2", oopPaperLink),
                      _buildTableRowWithLinks(context, "Unit Test 3", javaBasicsPaperLink),
                      _buildTableRowWithLinks(context, "End Sem Paper", oopPaperLink),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Function to build rows with download links for both PDF and PPT
  TableRow _buildTableRowWithLinks(
      BuildContext context, String chapter, String pdfLink,
      [String? pptLink]) {
    return TableRow(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(chapter,
              textAlign: TextAlign.center, style: TextStyle(fontSize: 16)),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: IconButton(
            icon: Icon(Icons.download),
            onPressed: () => _launchURL(pdfLink),
          ),
        ),
        if (pptLink != null)
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: IconButton(
              icon: Icon(Icons.download),
              onPressed: () => _launchURL(pptLink),
            ),
          ),
      ],
    );
  }

  // Function to launch the URL
  Future<void> _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(
        url,
        forceWebView: true,
        enableJavaScript: true,
      );
    } else {
      // Show error message to the user
      print('Could not launch $url');
    }
  }

  // Function to build table row for headers
  TableRow _buildTableRow(String col1, String col2,
      [String? col3, bool isHeader = false]) {
    return TableRow(
      decoration: isHeader ? BoxDecoration(color: Colors.grey.shade300) : null,
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            col1,
            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: isHeader ? 18 : 16,
                fontWeight: isHeader ? FontWeight.bold : FontWeight.normal),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            col2,
            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: isHeader ? 18 : 16,
                fontWeight: isHeader ? FontWeight.bold : FontWeight.normal),
          ),
        ),
        if (col3 != null)
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              col3,
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: isHeader ? 18 : 16,
                  fontWeight: isHeader ? FontWeight.bold : FontWeight.normal),
            ),
          ),
      ],
    );
  }
}
