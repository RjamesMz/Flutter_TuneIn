/// File: lib/screens/admin_screen/category_management_screen.dart
/// Role: Screen where administrators define new genre categories (with custom colors)
/// and delete unused genres from the database.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/app_colors.dart';
import '../../core/responsive_helper.dart';
import '../../providers/music_provider.dart';
import '../../providers/admin_provider.dart';

/// Screen widget for managing the database's available song genres.
class CategoryManagementScreen extends StatefulWidget {
  /// Constructs a [CategoryManagementScreen] instance.
  ///
  /// [key] An optional key used for identifying the widget in the element tree.
  const CategoryManagementScreen({super.key});

  @override
  State<CategoryManagementScreen> createState() =>
      _CategoryManagementScreenState();
}

/// State controller for managing inputs and updates in [CategoryManagementScreen].
class _CategoryManagementScreenState extends State<CategoryManagementScreen> {
  final _nameController = TextEditingController();
  Color _selectedColor = const Color(0xFF3B6B8A);

  final List<Color> _presetColors = [
    const Color(0xFF9D3756),
    const Color(0xFF7C3F8A),
    const Color(0xFF3B6B8A),
    const Color(0xFF4A6741),
    const Color(0xFF8A4A3B),
    const Color(0xFF5C4A8A),
    const Color(0xFFE67E22),
    const Color(0xFF16A085),
    const Color(0xFF2980B9),
    const Color(0xFF8E44AD),
    const Color(0xFF2C3E50),
  ];

  /// Converts a [Color] instance to a hex string code.
  ///
  /// [color] The target color instance to read.
  String _colorToHex(Color color) {
    // Converts Flutter Color integers to database-compatible hex format strings.
    return '#${color.value.toRadixString(16).padLeft(8, '0').substring(2).toUpperCase()}';
  }

  /// Triggers a write command to register the new category name and color.
  void _addCategory() {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;

    final hex = _colorToHex(_selectedColor);
    final music = context.read<MusicProvider>();
    context.read<AdminProvider>().addCategory(music, name, hex);
    _nameController.clear();
    FocusScope.of(context).unfocus();
  }

  /// Displays a validation dialog box requesting delete consent.
  ///
  /// [name] The name of the category to remove.
  void _confirmDelete(String name) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Category'),
        content: Text('Are you sure you want to delete "$name"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final music = context.read<MusicProvider>();
              context.read<AdminProvider>().deleteCategory(music, name);
              Navigator.pop(ctx);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  /// Disposes controllers on widget destroy.
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  /// Builds the screen layout containing the category creation card and the existing genres list.
  ///
  /// [context] The widget build context.
  Widget build(BuildContext context) {
    final music = context.watch<MusicProvider>();
    final categories = music.categories;

    return Scaffold(
      backgroundColor: kBackground,
      appBar: AppBar(
        title: Text(
          'Manage Categories',
          style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(gradient: kSoulGradient),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        titleTextStyle: const TextStyle(color: Colors.white, fontSize: 20),
      ),
      body: ResponsiveWrapper(
        child: Column(
          children: [
            // Add Category Section
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Container(
                decoration: BoxDecoration(
                  color: kSurface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: kOutlineVariant),
                ),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextField(
                      controller: _nameController,
                      style: const TextStyle(color: kOnSurface),
                      decoration: InputDecoration(
                        hintText: 'Category Name',
                        hintStyle: const TextStyle(color: kOnSurfaceVariant),
                        filled: true,
                        fillColor: kSurfaceContainerLow,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: kOutlineVariant),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Pick a Color',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: _presetColors.map((color) {
                        final isSelected = _selectedColor == color;
                        return GestureDetector(
                          onTap: () => setState(() => _selectedColor = color),
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: color,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: isSelected
                                    ? kPrimary
                                    : Colors.transparent,
                                width: 3,
                              ),
                              boxShadow: isSelected
                                  ? [
                                      BoxShadow(
                                        color: color.withAlpha(100),
                                        blurRadius: 8,
                                      ),
                                    ]
                                  : null,
                            ),
                            child: isSelected
                                ? const Icon(
                                    Icons.check,
                                    color: Colors.white,
                                    size: 20,
                                  )
                                : null,
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _addCategory,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kPrimary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: const Text(
                        'Add Category',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const Divider(),

            // Category List
            Expanded(
              child: categories.isEmpty
                  ? const Center(child: Text('No categories found.'))
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 8,
                      ),
                      itemCount: categories.length,
                      itemBuilder: (context, index) {
                        final cat = categories[index];
                        final name = cat['name']!;
                        final colorHex = cat['color']!;

                        // Formulates a Color instance from database hex value strings.
                        final color = Color(
                          int.parse(colorHex.replaceFirst('#', '0xFF')),
                        );

                        return Card(
                          margin: const EdgeInsets.only(bottom: 10),
                          elevation: 0,
                          color: kSurface,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                            side: BorderSide(color: kOutlineVariant),
                          ),
                          child: ListTile(
                            leading: Container(
                              width: 24,
                              height: 24,
                              decoration: BoxDecoration(
                                color: color,
                                shape: BoxShape.circle,
                              ),
                            ),
                            title: Text(
                              name,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: kOnSurface,
                              ),
                            ),
                            trailing: IconButton(
                              icon: const Icon(
                                Icons.delete_outline_rounded,
                                color: Colors.redAccent,
                              ),
                              onPressed: () => _confirmDelete(name),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
