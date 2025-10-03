import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart'; // Make sure you have `intl` in your pubspec.yaml
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

  // State for the live-updating text
  String _displayTitle = '';
  DateTime _selectedDate = DateTime.now();
  final List<String> _tags = []; // Start with an empty list of tags

  // This listener updates the UI whenever the title text changes
  void _onTitleChanged() {
    setState(() {
      _displayTitle = _titleController.text;
    });
  }

  @override
  void initState() {
    super.initState();
    // Attach the listener to the controller
    _titleController.addListener(_onTitleChanged);
  }

  @override
  void dispose() {
    // Clean up the listener and controllers to prevent memory leaks
    _titleController.removeListener(_onTitleChanged);
    _titleController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  // Function to show the date picker
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(), // User can't select a future date
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
              // Header Row without extra text
              const Text(
                'New Memory Details',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              const SizedBox(height: 24),

              // Photos Section
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
                    // Add Photos Button
                    Container(
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
                          Text(
                            'Add Photos',
                            style: TextStyle(color: Colors.white, fontSize: 10),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Live-updating Photo Placeholder
                    Expanded(
                      child: Container(
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
                            // This Text widget updates live
                            Text(
                              _displayTitle.isEmpty ? 'Your Memory Title' : _displayTitle,
                              style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500),
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            // This Text widget also updates live
                            Text(
                              DateFormat('MMM dd, yyyy').format(_selectedDate),
                              style: const TextStyle(color: Colors.white70, fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Title Section
              Row(
                children: [
                  const Text('Title', style: TextStyle(color: Colors.white70, fontSize: 16)),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextField(
                      controller: _titleController,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: 'Trip to XXXX', // Updated placeholder
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
                  // Dropdown arrow is removed
                ],
              ),
              const SizedBox(height: 24),

              // Date Section
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

              // Notes Section
              const Text('Notes', style: TextStyle(color: Colors.white70, fontSize: 16)),
              const SizedBox(height: 8),
              TextField(
                controller: _notesController,
                maxLines: 4,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'First time seeing snow', // Updated placeholder
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

              // Categories/Tags Section
              const Text('Categories/Tags', style: TextStyle(color: Colors.white70, fontSize: 16)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8.0,
                runSpacing: 8.0,
                children: [
                  // Tags will be added here dynamically later
                  ..._tags.map((tag) => Chip(
                    label: Text(tag),
                    backgroundColor: const Color(0xFF8E44AD),
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

              // Save Button
              InkWell(
                onTap: () {
                  // Basic validation: ensure the title is not empty
                  if (_titleController.text.isEmpty) {
                    // Show a snackbar error message
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Please enter a title for your memory.'),
                        backgroundColor: Colors.redAccent,
                      ),
                    );
                    return; // Stop the function
                  }

                  // Read the repository using the Riverpod ref
                  final repo = ref.read(memoryRepositoryProvider);

                  // Call the updated addMemory method with all the data
                  repo.addMemory(
                    title: _titleController.text,
                    notes: _notesController.text,
                    date: _selectedDate,
                    latLng: widget.location,
                  );

                  // Close the bottom sheet after saving
                  Navigator.of(context).pop();
                },
                child: Container(
                  // ... the rest of the button UI remains the same
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