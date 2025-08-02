import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../widgts/ParticipantInput.dart';
import '../widgts/ParticipantList.dart';
import '../widgts/PickWinnerButton.dart';
import '../widgts/winner_dialog.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _nameController = TextEditingController();
  final Color themeColor = const Color(0xFFec0a86);

  List<Map<String, String>> _participants = []; // List of {id, name}
  final List<String> _winners = [];
  int _winnerCount = 3; // default number of winners

  @override
  void initState() {
    super.initState();
    _initFirebase();
  }

  Future<void> _initFirebase() async {
    // Sign in anonymously
    await FirebaseAuth.instance.signInAnonymously();

    // Listen for participants changes
    FirebaseFirestore.instance
        .collection('participants')
        .snapshots()
        .listen((snapshot) {
      final List<Map<String, String>> names = snapshot.docs.map((doc) {
        return {
          'id': doc.id,
          'name': doc['name'] as String,
        };
      }).toList();

      setState(() {
        _participants = names;
      });
    });

    // Load winner count setting from Firestore (persisted)
    FirebaseFirestore.instance
        .collection('settings')
        .doc('lottery')
        .snapshots()
        .listen((doc) {
      if (doc.exists) {
        final data = doc.data()!;
        final count = data['winnerCount'];
        if (count is int && count > 0) {
          setState(() {
            _winnerCount = count;
          });
        }
      }
    });
  }

  void _pickWinners() {
    if (_participants.length < _winnerCount) return;
    final random = Random();
    final picked = <String>{};

    while (picked.length < _winnerCount) {
      picked.add(_participants[random.nextInt(_participants.length)]['name']!);
    }

    setState(() {
      _winners
        ..clear()
        ..addAll(picked);
    });

    showWinnersDialog(context, _winners);
  }

  void _addParticipant() {
    final name = _nameController.text.trim();
    final isDuplicate = _participants.any((p) => p['name'] == name);

    if (name.isNotEmpty && !isDuplicate) {
      _nameController.clear();
      _addParticipantToFirebase(name);
    }
  }

  Future<void> _addParticipantToFirebase(String name) async {
    await FirebaseFirestore.instance.collection('participants').add({'name': name});
  }

  Future<void> _importCSV() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['csv'],
    );

    if (result != null && result.files.single.path != null) {
      final file = File(result.files.single.path!);
      final bytes = await file.readAsBytes();
      final content = utf8.decode(bytes);

      final lines = const LineSplitter().convert(content);
      for (var line in lines) {
        final name = line.trim();
        final isDuplicate = _participants.any((p) => p['name'] == name);

        if (name.isNotEmpty && !isDuplicate) {
          await _addParticipantToFirebase(name);
        }
      }
    }
  }

  void _showEditParticipantDialog(int index) {
    final current = _participants[index];
    final controller = TextEditingController(text: current['name']);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Participant'),
          content: TextField(controller: controller),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final newName = controller.text.trim();
                final isDuplicate = _participants.any((p) => p['name'] == newName);

                if (newName.isNotEmpty && !isDuplicate) {
                  await FirebaseFirestore.instance
                      .collection('participants')
                      .doc(current['id'])
                      .update({'name': newName});
                }
                Navigator.pop(context);
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void _deleteParticipant(int index) async {
    final docId = _participants[index]['id'];
    await FirebaseFirestore.instance.collection('participants').doc(docId).delete();
  }

  void _showSettingsBottomSheet() {
    final TextEditingController controller =
    TextEditingController(text: _winnerCount.toString());

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Set Number of Winners',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: controller,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Number of Winners',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  final input = int.tryParse(controller.text.trim());
                  if (input != null && input > 0 && input <= _participants.length) {
                    setState(() {
                      _winnerCount = input;
                    });
                    // Save to Firestore
                    await FirebaseFirestore.instance
                        .collection('settings')
                        .doc('lottery')
                        .set({'winnerCount': input});
                    Navigator.pop(context);
                  }
                },
                child: const Text('Save'),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      appBar: AppBar(
        backgroundColor: themeColor,
        foregroundColor: Colors.white,
        title: const Text(
          'Manola Lottery App',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            onPressed: _showSettingsBottomSheet,
            icon: const Icon(Icons.settings),
          ),
        ],
        centerTitle: true,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            ParticipantInput(
              nameController: _nameController,
              onImportCSV: _importCSV,
              onAddParticipant: _addParticipant,
              themeColor: themeColor,
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ParticipantList(
                participants: _participants.map((e) => e['name']!).toList(),
                themeColor: themeColor,
                onEdit: _showEditParticipantDialog,
                onDelete: _deleteParticipant,
              ),
            ),
            const SizedBox(height: 20),
            PickWinnerButton(
              onPickWinners: _pickWinners,
              themeColor: themeColor,
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
