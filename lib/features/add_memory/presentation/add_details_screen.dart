import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb; // To check platform
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart'; // Import the new package
import 'package:heic_to_jpg/heic_to_jpg.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';
import 'package:memories_map/data/repositories/memory_repository.dart';

class AddDetailsScreen extends ConsumerStatefulWidget {
  final LatLng location;
  const AddDetailsScreen({super.key, required this.location});

  @override
  ConsumerState<AddDetailsScreen> createState() => _AddDetailsScreenState();
}

class _AddDetailsScreenState extends ConsumerState<AddDetailsScreen> {
  final _titleController = TextEditingController();
  final _notesController = TextEditingController();
  String _displayTitle = '';
  DateTime _selectedDate = DateTime.now();
  final List<String> _tags = [];
  final List<String> _imagePaths = [];

  void _onTitleChanged() {
    setState(() {
      _displayTitle = _titleController.text;
    });
  }

  @override
  void initState() {
    super.initState();
    _titleController.addListener(_onTitleChanged);
  }

  @override
  void dispose() {
    _titleController.removeListener(_onTitleChanged);
    _titleController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  // --- REPLACED IMAGE PICKER LOGIC ---
  Future<void> _pickImages() async {
    // Use the file_picker package
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.custom,
      // Explicitly allow HEIC files on Windows
      allowedExtensions: ['jpg', 'jpeg', 'png', 'gif', 'heic'],
    );

    if (result != null) {
      final List<String> processedPaths = [];
      for (final file in result.files) {
        String? finalPath = file.path;

        // Only attempt conversion on mobile platforms
        if (finalPath != null && !kIsWeb && (Platform.isIOS || Platform.isAndroid)) {
          if (finalPath.toLowerCase().endsWith('.heic')) {
            finalPath = await HeicToJpg.convert(finalPath);
          }
        }

        if (finalPath != null) {
          processedPaths.add(finalPath);
        }
      }

      setState(() {
        _imagePaths.addAll(processedPaths);
      });
    }
  }
  // --- END OF REPLACEMENT ---

  Future<void> _selectDate(BuildContext context) async {
    // ... (This function remains unchanged)
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFFE91E63),
              onPrimary: Colors.white,
              surface: Color(0xFF2D273A),
              onSurface: Colors.white,
            ),
            dialogBackgroundColor: const Color(0xFF2D273A),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // The entire build method remains the same as before.
    // I am including it here for completeness.
    return FractionallySizedBox(
      heightFactor: 0.95,
      child: Container(
        padding: const EdgeInsets.all(24.0),
        decoration: const BoxDecoration(
          color: Color(0xFF2D273A),
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'New Memory Details',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              const SizedBox(height: 24),
              const Text('Photos', style: TextStyle(color: Colors.white70, fontSize: 16)),
              const SizedBox(height: 8),
              Container(
                height: 100,
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF3F3B4A),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: _pickImages,
                      child: Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: const Color(0xFFE91E63),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(Icons.add, color: Colors.white, size: 30),
                            Text('Add Photos', style: TextStyle(color: Colors.white, fontSize: 10)),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _imagePaths.isEmpty
                          ? Container(
                        height: 80,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF5D596B),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              _displayTitle.isEmpty ? 'Your Memory Title' : _displayTitle,
                              style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500),
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              DateFormat('MMM dd, yyyy').format(_selectedDate),
                              style: const TextStyle(color: Colors.white70, fontSize: 12),
                            ),
                          ],
                        ),
                      )
                          : ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: _imagePaths.length,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8.0),
                              child: Image.file(
                                File(_imagePaths[index]),
                                height: 80,
                                width: 80,
                                fit: BoxFit.cover,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  const Text('Title', style: TextStyle(color: Colors.white70, fontSize: 16)),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextField(
                      controller: _titleController,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: 'Trip to XXXX',
                        hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
                        filled: true,
                        fillColor: const Color(0xFF3F3B4A),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  const Text('Date', style: TextStyle(color: Colors.white70, fontSize: 16)),
                  const SizedBox(width: 20),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => _selectDate(context),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                        decoration: BoxDecoration(
                          color: const Color(0xFF3F3B4A),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              DateFormat('MMM dd, yyyy').format(_selectedDate),
                              style: const TextStyle(color: Colors.white, fontSize: 16),
                            ),
                            Icon(Icons.calendar_today, color: Colors.white.withOpacity(0.7), size: 20),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              const Text('Notes', style: TextStyle(color: Colors.white70, fontSize: 16)),
              const SizedBox(height: 8),
              TextField(
                controller: _notesController,
                maxLines: 4,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'First time seeing snow',
                  hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
                  filled: true,
                  fillColor: const Color(0xFF3F3B4A),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.all(12),
                ),
              ),
              const SizedBox(height: 24),
              const Text('Categories/Tags', style: TextStyle(color: Colors.white70, fontSize: 16)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8.0,
                runSpacing: 8.0,
                children: [
                  ..._tags.map((tag) => Chip(
                    label: Text(tag),
                    backgroundColor: const Color(0xFF8E4AAD),
                    labelStyle: const TextStyle(color: Colors.white),
                    onDeleted: () {},
                  )),
                  ActionChip(
                    avatar: Icon(Icons.add, color: Colors.white.withOpacity(0.7)),
                    label: const Text('Add New Tag'),
                    backgroundColor: const Color(0xFF3F3B4A),
                    labelStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
                    onPressed: () {},
                  ),
                ],
              ),
              const SizedBox(height: 32),
              InkWell(
                onTap: () {
                  if (_titleController.text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Please enter a title for your memory.'),
                        backgroundColor: Colors.redAccent,
                      ),
                    );
                    return;
                  }
                  final repo = ref.read(memoryRepositoryProvider);
                  repo.addMemory(
                    title: _titleController.text,
                    notes: _notesController.text,
                    date: _selectedDate,
                    latLng: widget.location,
                    photoPaths: _imagePaths,
                  );
                  Navigator.of(context).pop();
                },
                child: Container(
                  height: 55,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                    gradient: const LinearGradient(
                      colors: [Color(0xFFE91E63), Color(0xFF9C27B0)],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                  ),
                  child: const Center(
                    child: Text(
                      'Save Memory',
                      style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}