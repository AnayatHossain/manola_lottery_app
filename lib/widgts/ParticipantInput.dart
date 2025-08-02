import 'package:flutter/material.dart';
class ParticipantInput extends StatelessWidget {
  final TextEditingController nameController;
  final VoidCallback onImportCSV;
  final VoidCallback onAddParticipant;
  final Color themeColor;

  const ParticipantInput({
    super.key,
    required this.nameController,
    required this.onImportCSV,
    required this.onAddParticipant,
    required this.themeColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            blurRadius: 8,
            color: Colors.black12,
            offset: Offset(0, 4),
          )
        ],
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: onImportCSV,
            icon: Icon(Icons.upload_file_rounded),
            color: themeColor,
            tooltip: 'Import CSV',
          ),
          Expanded(
            child: TextField(
              controller: nameController,
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
            onPressed: onAddParticipant,
            style: ElevatedButton.styleFrom(
              backgroundColor: themeColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
            child: const Text(
              'Add',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}