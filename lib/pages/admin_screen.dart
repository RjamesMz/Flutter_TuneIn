import 'package:flutter/material.dart';
import 'package:tunely/pages/upload_song_screen.dart';
import '../services/auth_service.dart';
import '../core/app_colors.dart';
class AdminScreen extends StatelessWidget {
  const AdminScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackground,
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        backgroundColor: kSurface,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: kPrimary),
            onPressed: () {
              AuthService.instance.logout();
              Navigator.pushNamedAndRemoveUntil(
                context,
                '/login',
                (route) => false,
              );
            },
          ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.admin_panel_settings, size: 80, color: kPrimary),
                const SizedBox(height: 24),
                Text(
                  'Welcome, Admin!',
                  style: Theme.of(context).textTheme.headlineMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  'You can upload new songs to the Tunely platform directly from here.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: kOnSurfaceVariant),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 48),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const UploadSongScreen()),
                    );
                  },
                  icon: const Icon(Icons.upload, color: Colors.white),
                  label: const Text(
                    'Upload New Song',
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kPrimary,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
