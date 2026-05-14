import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import '../services/supabase_service.dart';
import '../core/app_colors.dart';
import '../core/app_strings.dart';

class UploadSongScreen extends StatefulWidget {
  const UploadSongScreen({super.key});

  @override
  State<UploadSongScreen> createState() => _UploadSongScreenState();
}

class _UploadSongScreenState extends State<UploadSongScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _artistController = TextEditingController();
  final _albumController = TextEditingController();

  String _selectedCategory = MusicCategories.pop;

  Uint8List? _coverBytes;
  String? _coverFileName;
  Uint8List? _audioBytes;
  String? _audioFileName;
  bool _isUploading = false;

  Future<void> _pickAudio() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['mp3', 'wav', 'm4a', 'aac', 'flac'],
        withData: true, // Force loading bytes — works on all platforms
      );

      if (result != null) {
        final file = result.files.single;
        if (file.bytes != null) {
          setState(() {
            _audioBytes = file.bytes;
            _audioFileName = file.name;
          });
        } else {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Error: Could not read the file. Try a different file.',
              ),
            ),
          );
        }
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error picking file: $e')));
    }
  }

  Future<void> _pickCover() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      final bytes = await pickedFile.readAsBytes();
      setState(() {
        _coverBytes = bytes;
        _coverFileName = pickedFile.name;
      });
    }
  }

  Future<void> _uploadSong() async {
    if (!_formKey.currentState!.validate()) return;
    if (_audioBytes == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select an audio file')),
      );
      return;
    }

    setState(() => _isUploading = true);

    try {
      await SupabaseService.instance.publishSong(
        title: _titleController.text.trim(),
        artist: _artistController.text.trim(),
        album: _albumController.text.trim(),
        category: _selectedCategory,
        audioBytes: _audioBytes!,
        audioFileName: _audioFileName!,
        coverBytes: _coverBytes,
        coverFileName: _coverFileName,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Song uploaded successfully! Restart the app to see it.',
          ),
        ),
      );

      // Clear form
      _titleController.clear();
      _artistController.clear();
      _albumController.clear();
      setState(() {
        _audioBytes = null;
        _audioFileName = null;
        _coverBytes = null;
        _coverFileName = null;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Upload failed: $e')));
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _artistController.dispose();
    _albumController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackground,
      appBar: AppBar(
        title: const Text('Upload New Song'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: kPrimary),
      ),
      body: _isUploading
          ? const Center(child: CircularProgressIndicator(color: kPrimary))
          : Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 560),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Cover Picker
                    GestureDetector(
                      onTap: _pickCover,
                      child: Container(
                        height: 200,
                        decoration: BoxDecoration(
                          color: kSurface,
                          borderRadius: BorderRadius.circular(16),
                          image: _coverBytes != null
                              ? DecorationImage(
                                  image: MemoryImage(_coverBytes!),
                                  fit: BoxFit.cover,
                                )
                              : null,
                        ),
                        child: _coverBytes == null
                            ? const Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.add_photo_alternate,
                                    color: kOnSurfaceVariant,
                                    size: 48,
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    'Tap to add Cover Image',
                                    style: TextStyle(color: kOnSurfaceVariant),
                                  ),
                                ],
                              )
                            : null,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Audio Picker
                    ElevatedButton.icon(
                      onPressed: _pickAudio,
                      icon: Icon(
                        Icons.audiotrack,
                        color: _audioBytes != null
                            ? Colors.black
                            : Colors.white,
                      ),
                      label: Text(
                        _audioBytes != null
                            ? _audioFileName ?? 'Audio Selected'
                            : 'Select MP3 File',
                        style: const TextStyle(color: Colors.black),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _audioBytes != null
                            ? Colors.green
                            : kSurfaceContainerHighest,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Text Fields
                    _buildTextField(
                      'Title',
                      _titleController,
                      Icons.music_note,
                    ),
                    const SizedBox(height: 16),
                    _buildTextField('Artist', _artistController, Icons.person),
                    const SizedBox(height: 16),
                    _buildTextField(
                      'Album (Optional)',
                      _albumController,
                      Icons.album,
                      required: false,
                    ),
                    const SizedBox(height: 16),
                    _buildCategoryDropdown(),
                    const SizedBox(height: 32),

                    // Submit
                    ElevatedButton(
                      onPressed: _uploadSong,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kPrimary,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Upload Song',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    ],
                ),
              ),
            ),
          ),
        ),
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller,
    IconData icon, {
    bool required = true,
  }) {
    return TextFormField(
      controller: controller,
      style: const TextStyle(color: Colors.black),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: kOnSurfaceVariant),
        prefixIcon: Icon(icon, color: kOnSurfaceVariant),
        filled: true,
        fillColor: kSurfaceContainerLow,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
      validator: required
          ? (value) {
              if (value == null || value.trim().isEmpty) {
                return '$label is required';
              }
              return null;
            }
          : null,
    );
  }

  Widget _buildCategoryDropdown() {
    // Filter out 'All' since you can't upload a song to 'All' category
    final categories = MusicCategories.all_categories
        .where((c) => c != MusicCategories.all)
        .toList();

    return DropdownButtonFormField<String>(
      value: _selectedCategory,
      dropdownColor: kSurfaceContainerHighest,
      style: const TextStyle(color: Colors.black),
      decoration: InputDecoration(
        labelText: 'Category',
        labelStyle: const TextStyle(color: kOnSurfaceVariant),
        prefixIcon: const Icon(Icons.category, color: kOnSurfaceVariant),
        filled: true,
        fillColor: kSurfaceContainerLow,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
      items: categories.map((String category) {
        return DropdownMenuItem(value: category, child: Text(category));
      }).toList(),
      onChanged: (String? newValue) {
        if (newValue != null) {
          setState(() {
            _selectedCategory = newValue;
          });
        }
      },
    );
  }
}
