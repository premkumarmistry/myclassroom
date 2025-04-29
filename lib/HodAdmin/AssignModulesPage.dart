import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

class AssignModulesPage extends StatefulWidget {
  @override
  _AssignModulesPageState createState() => _AssignModulesPageState();
}

class _AssignModulesPageState extends State<AssignModulesPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String? _selectedProfessorName;
  String? _selectedProfessorId;  // Store Firestore auto-ID
  String? _selectedModule;
  List<Map<String, String>> _professors = []; // Store both name & ID
  List<String> _modules = [];
  bool _isLoading = false;
  bool _isError = false;
  String? _hodDepartment;

  @override
  void initState() {
    super.initState();
    _fetchHodDepartment();
  }

  Future<void> _fetchHodDepartment() async {
    User? user = _auth.currentUser;
    if (user != null) {
      DocumentSnapshot hodDoc = await _firestore.collection("hods").doc(user.uid).get();
      setState(() {
        _hodDepartment = hodDoc["department"];
      });
      _fetchProfessors();
      _fetchModules();
    }
  }

  Future<void> _fetchProfessors() async {
    if (_hodDepartment == null) return;
    setState(() {
      _isLoading = true;
      _isError = false;
    });
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('teachers')
          .where("isVerified", isEqualTo: true)
          .where("department", isEqualTo: _hodDepartment)
          .get();

      setState(() {
        _professors = snapshot.docs
            .map((doc) => {"id": doc.id, "name": doc["name"] as String})
            .toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _isError = true;
      });
    }
  }

  Future<void> _fetchModules() async {
    setState(() {
      _isLoading = true;
      _isError = false;
    });
    try {
      QuerySnapshot snapshot = await _firestore.collection('modules').get();
      setState(() {
        _modules = snapshot.docs.map((doc) => doc["name"] as String).toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _isError = true;
      });
    }
  }

  Future<void> _assignModule() async {
    if (_selectedProfessorId != null && _selectedModule != null) {
      bool? shouldAssign = await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text("Assign Module"),
          content: Text("Are you sure you want to assign $_selectedModule to $_selectedProfessorName?"),
          actions: [
            TextButton(onPressed: () => Navigator.of(context).pop(false), child: Text("Cancel")),
            TextButton(onPressed: () => Navigator.of(context).pop(true), child: Text("Confirm")),
          ],
        ),
      );
      if (shouldAssign == true) {
        try {
          await _firestore.collection('teachers').doc(_selectedProfessorId).update({
            "modules": FieldValue.arrayUnion([_selectedModule]),
          });

          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text("Module Assigned Successfully!")));
        } catch (e) {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text("Failed to assign module: $e")));
        }
      }
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Please select both professor and module")));
    }
  }

  void _showBottomSheet({
    required String title,
    required List<String> items,
    required Function(String) onSelected,
  }) {
    showMaterialModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: EdgeInsets.all(16),
        height: 300,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Expanded(
              child: ListView.builder(
                itemCount: items.length,
                itemBuilder: (context, index) => ListTile(
                  title: Text(items[index]),
                  onTap: () {
                    onSelected(items[index]);
                    Navigator.pop(context);
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showProfessorBottomSheet() {
    showMaterialModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: EdgeInsets.all(16),
        height: 300,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Select Professor", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Expanded(
              child: ListView.builder(
                itemCount: _professors.length,
                itemBuilder: (context, index) {
                  final professor = _professors[index];
                  return ListTile(
                    title: Text(professor["name"]!),
                    onTap: () {
                      setState(() {
                        _selectedProfessorName = professor["name"];
                        _selectedProfessorId = professor["id"];
                      });
                      Navigator.pop(context);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Assign Modules"),
        backgroundColor: Colors.deepPurple,
        centerTitle: true,
        foregroundColor: Colors.white,
      ),
      backgroundColor: Colors.deepPurple.shade900,
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: _isLoading
            ? Center(child: CircularProgressIndicator(color: Colors.white))
            : _isError
            ? Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error, color: Colors.red, size: 40),
              SizedBox(height: 10),
              Text("Error loading data, try again later",
                  style: TextStyle(color: Colors.white)),
              ElevatedButton(
                onPressed: _fetchProfessors,
                child: Text("Retry"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.deepPurple,
                ),
              ),
            ],
          ),
        )
            : Column(
          children: [
            Card(
              color: Colors.white.withOpacity(0.9),
              elevation: 8,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              child: ListTile(
                title: Text(
                  _selectedProfessorName ?? "Select Professor",
                  style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                ),
                trailing: Icon(Icons.arrow_drop_down, color: Colors.deepPurple),
                onTap: _showProfessorBottomSheet,
              ),
            ),
            SizedBox(height: 16),
            Card(
              color: Colors.white.withOpacity(0.9),
              elevation: 8,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              child: ListTile(
                title: Text(
                  _selectedModule ?? "Select Module",
                  style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                ),
                trailing: Icon(Icons.arrow_drop_down, color: Colors.deepPurple),
                onTap: () => _showBottomSheet(
                  title: "Select Module",
                  items: _modules,
                  onSelected: (value) {
                    setState(() => _selectedModule = value);
                  },
                ),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _assignModule,
              child:
              Text("Assign Module", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.deepPurple,
                minimumSize: Size(double.infinity, 50),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                elevation: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
