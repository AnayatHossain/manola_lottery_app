import 'package:flutter/material.dart';
import 'dart:math';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:manola_lottery_app/winner_dialog.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _nameController = TextEditingController();
  final List<String> _participants = [];
  final List<String> _winners = [];

  void _pickWinners() {
    if (_participants.length < 3) return;
    final random = Random();
    final picked = <String>{};
    while (picked.length < 3) {
      picked.add(_participants[random.nextInt(_participants.length)]);
    }
    setState(() {
      _winners
        ..clear()
        ..addAll(picked);
    });

    showWinnersDialog(context, _winners); // ✅ Correct call
  }

  void _addParticipant() {
    final name = _nameController.text.trim();
    if (name.isNotEmpty && !_participants.contains(name)) {
      setState(() {
        _participants.add(name);
        _nameController.clear();
      });
    }
  }

  Future<void> _importCSV() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['csv'],
    );
    if (result != null && result.files.single.path != null) {
      final file = File(result.files.single.path!);
      final lines = await file.readAsLines();
      setState(() {
        for (var line in lines) {
          final name = line.trim();
          if (name.isNotEmpty && !_participants.contains(name)) {
            _participants.add(name);
          }
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeColor = const Color(0xFFec0a86);
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      appBar: AppBar(
        backgroundColor: themeColor,
        foregroundColor: Colors.white,
        title: const Text('Manola Lottery App', style: TextStyle(fontWeight: FontWeight.bold),),

        centerTitle: true,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    blurRadius: 8,
                    color: Colors.black12,
                    offset: Offset(0, 4),
                  )
                ],
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      IconButton(
                        onPressed: _importCSV,
                        icon: const Icon(Icons.upload_file_rounded),
                        color: themeColor,
                        tooltip: 'Import CSV',
                      ),
                      Expanded(
                        child: TextField(
                          controller: _nameController,
                          decoration: InputDecoration(
                            labelText: 'Enter participant name',
                            filled: true,
                            fillColor: Colors.grey[100],
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: _addParticipant,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: themeColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        ),
                        child: const Text('Add', style: TextStyle(color: Colors.white),),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: _participants.isEmpty
                  ? const Center(child: Text("No participants yet."))
                  : ListView.separated(
                itemCount: _participants.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  return Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          blurRadius: 4,
                          color: Colors.black12,
                          offset: Offset(0, 2),
                        )
                      ],
                    ),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: themeColor.withOpacity(0.2),
                        child: Text(
                          '${index + 1}',
                          style: TextStyle(color: themeColor, fontWeight: FontWeight.bold),
                        ),
                      ),
                      title: Text(
                        _participants[index],
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _pickWinners,
              icon: const Icon(Icons.star),
              label: const Text('Pick Winners'),
              style: ElevatedButton.styleFrom(
                backgroundColor: themeColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
