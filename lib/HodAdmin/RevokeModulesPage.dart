import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

class RevokeModulesPage extends StatefulWidget {
  @override
  _RevokeModulesPageState createState() => _RevokeModulesPageState();
}

class _RevokeModulesPageState extends State<RevokeModulesPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String? _selectedProfessor;
  String? _selectedModule;
  List<String> _professors = [];
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
        _professors = snapshot.docs.map((doc) => doc["name"] as String).toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _isError = true;
      });
    }
  }

  Future<void> _fetchModulesForProfessor(String professorName) async {
    setState(() {
      _isLoading = true;
      _isError = false;
    });
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('teachers')
          .where("name", isEqualTo: professorName)
          .where("department", isEqualTo: _hodDepartment)
          .get();
      if (snapshot.docs.isNotEmpty) {
        List<dynamic> assignedModules = snapshot.docs.first["modules"] ?? [];
        setState(() {
          _modules = assignedModules.cast<String>().toSet().toList();
          _selectedModule = null;
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _isError = true;
      });
    }
  }

  Future<void> _revokeModule() async {
    if (_selectedProfessor != null && _selectedModule != null) {
      bool? shouldRevoke = await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text("Revoke Module"),
          content: Text("Are you sure you want to revoke $_selectedModule from $_selectedProfessor?"),
          actions: [
            TextButton(onPressed: () => Navigator.of(context).pop(false), child: Text("Cancel")),
            TextButton(onPressed: () => Navigator.of(context).pop(true), child: Text("Confirm")),
          ],
        ),
      );
      if (shouldRevoke == true) {
        try {
          QuerySnapshot snapshot = await _firestore
              .collection('teachers')
              .where("name", isEqualTo: _selectedProfessor)
              .where("department", isEqualTo: _hodDepartment)
              .get();
          if (snapshot.docs.isNotEmpty) {
            await _firestore.collection('teachers').doc(snapshot.docs.first.id).update({
              "modules": FieldValue.arrayRemove([_selectedModule]),
            });
          }
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text("Module Revoked Successfully!")));
          _fetchModulesForProfessor(_selectedProfessor!);
        } catch (e) {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text("Failed to revoke module: $e")));
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Revoke Modules"),
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
                  _selectedProfessor ?? "Select Professor",
                  style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                ),
                trailing: Icon(Icons.arrow_drop_down, color: Colors.deepPurple),
                onTap: () => _showBottomSheet(
                  title: "Select Professor",
                  items: _professors,
                  onSelected: (value) {
                    setState(() => _selectedProfessor = value);
                    _fetchModulesForProfessor(value);
                  },
                ),
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
              onPressed: _revokeModule,
              child:
              Text("Revoke Module", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
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
