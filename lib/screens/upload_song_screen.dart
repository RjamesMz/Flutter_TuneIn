import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import '../services/supabase_service.dart';
import '../core/app_colors.dart';
import '../core/app_strings.dart';
import '../core/responsive_helper.dart';
import '../providers/music_provider.dart';

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
        withData: true,
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
            const SnackBar(content: Text('Error: Could not read the file.')),
          );
        }
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error picking file: $e')),
      );
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

    final songTitle = _titleController.text.trim();
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
        const SnackBar(content: Text('Song uploaded successfully!')),
      );
      try {
        context.read<MusicProvider>().addSongAddedNotification('Added song: "$songTitle"');
      } catch (_) {}
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Upload failed: $e')),
      );
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
      body: ResponsiveWrapper(
        child: _isUploading
            ? const Center(child: CircularProgressIndicator(color: kPrimary))
            : Column(
              children: [
                // ── Gradient Header ───────────────────────────────────────────
                Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    gradient: kSoulGradient,
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(28),
                      bottomRight: Radius.circular(28),
                    ),
                  ),
                  padding: const EdgeInsets.fromLTRB(16, 44, 16, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Back button row
                      Align(
                        alignment: Alignment.centerLeft,
                        child: IconButton(
                          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: kOnPrimary),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ),
                      Image.asset(
                        'assets/image/logo/TuneIn_Logo.png',
                        height: 60,
                        fit: BoxFit.contain,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'TuneIn',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: kOnPrimary.withValues(alpha: 0.7),
                          letterSpacing: 3,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Upload Song',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: kOnPrimary,
                        ),
                      ),
                    ],
                  ),
                ),

                // ── Form ─────────────────────────────────────────────────────
                Expanded(
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 560),
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(20),
                        child: Form(
                          key: _formKey,
                          child: Container(
                            decoration: BoxDecoration(
                              color: kSurface,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: kOutlineVariant, width: 1.5),
                              boxShadow: [
                                BoxShadow(
                                  color: kPrimary.withValues(alpha: 0.07),
                                  blurRadius: 16,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                // Cover Picker
                                GestureDetector(
                                  onTap: _pickCover,
                                  child: Container(
                                    height: 180,
                                    decoration: BoxDecoration(
                                      color: kSurfaceContainerLow,
                                      borderRadius: BorderRadius.circular(14),
                                      border: Border.all(color: kOutlineVariant),
                                      image: _coverBytes != null
                                          ? DecorationImage(
                                              image: MemoryImage(_coverBytes!),
                                              fit: BoxFit.cover,
                                            )
                                          : null,
                                    ),
                                    child: _coverBytes == null
                                        ? Column(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Icon(Icons.add_photo_alternate_rounded,
                                                  color: kPrimary.withValues(alpha: 0.6), size: 44),
                                              const SizedBox(height: 8),
                                              Text(
                                                'Tap to add Cover Image',
                                                style: GoogleFonts.beVietnamPro(
                                                  color: kOnSurfaceVariant,
                                                  fontSize: 13,
                                                ),
                                              ),
                                            ],
                                          )
                                        : null,
                                  ),
                                ),
                                const SizedBox(height: 16),

                                // Audio Picker
                                ElevatedButton.icon(
                                  onPressed: _pickAudio,
                                  icon: Icon(
                                    Icons.audiotrack_rounded,
                                    color: _audioBytes != null ? Colors.white : kOnSurfaceVariant,
                                  ),
                                  label: Text(
                                    _audioBytes != null
                                        ? _audioFileName ?? 'Audio Selected'
                                        : 'Select Audio File',
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: _audioBytes != null ? Colors.white : kOnSurface,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: _audioBytes != null
                                        ? const Color(0xFF2E7D32)
                                        : kSurfaceContainerHighest,
                                    padding: const EdgeInsets.symmetric(vertical: 14),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      side: BorderSide(color: kOutlineVariant),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 16),

                                // Text Fields
                                _buildTextField('Title', _titleController, Icons.music_note_rounded),
                                const SizedBox(height: 12),
                                _buildTextField('Artist', _artistController, Icons.person_rounded),
                                const SizedBox(height: 12),
                                _buildTextField('Album (Optional)', _albumController, Icons.album_rounded, required: false),
                                const SizedBox(height: 12),
                                _buildCategoryDropdown(),
                                const SizedBox(height: 20),

                                // Submit
                                ElevatedButton(
                                  onPressed: _uploadSong,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: kPrimary,
                                    foregroundColor: kOnPrimary,
                                    padding: const EdgeInsets.symmetric(vertical: 16),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                  ),
                                  child: Text(
                                    'Upload Song',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      color: kOnPrimary,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
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
      style: TextStyle(color: kOnSurface, fontFamily: GoogleFonts.beVietnamPro().fontFamily),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: kOnSurfaceVariant),
        prefixIcon: Icon(icon, color: kPrimary, size: 20),
        filled: true,
        fillColor: kSurfaceContainerLow,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: kOutlineVariant),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: kOutlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: kPrimary, width: 1.5),
        ),
      ),
      validator: required
          ? (value) {
              if (value == null || value.trim().isEmpty) return '$label is required';
              return null;
            }
          : null,
    );
  }

  Widget _buildCategoryDropdown() {
    final categories = MusicCategories.all_categories
        .where((c) => c != MusicCategories.all)
        .toList();

    return DropdownButtonFormField<String>(
      value: _selectedCategory,
      dropdownColor: kSurface,
      style: TextStyle(color: kOnSurface, fontFamily: GoogleFonts.beVietnamPro().fontFamily),
      decoration: InputDecoration(
        labelText: 'Category',
        labelStyle: const TextStyle(color: kOnSurfaceVariant),
        prefixIcon: const Icon(Icons.category_rounded, color: kPrimary, size: 20),
        filled: true,
        fillColor: kSurfaceContainerLow,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: kOutlineVariant),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: kOutlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: kPrimary, width: 1.5),
        ),
      ),
      items: categories.map((String category) {
        return DropdownMenuItem(value: category, child: Text(category));
      }).toList(),
      onChanged: (String? newValue) {
        if (newValue != null) setState(() => _selectedCategory = newValue);
      },
    );
  }
}
