// ignore_for_file: unnecessary_underscores

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/app_colors.dart';
import '../../core/responsive_helper.dart';
import '../../providers/music_provider.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Notifications',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: kOnPrimary,
            letterSpacing: 0.3,
          ),
        ),
        backgroundColor: Colors.transparent,
        flexibleSpace: Container(
          decoration: const BoxDecoration(gradient: kSoulGradient),
        ),
        elevation: 0,
        iconTheme: const IconThemeData(color: kOnPrimary),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline, color: kOnPrimary),
            onPressed: () => context.read<MusicProvider>().clearSongNotifications(),
          )
        ],
      ),
      body: ResponsiveWrapper(
        child: RefreshIndicator(
          onRefresh: () => context.read<MusicProvider>().fetchSongs(forceRefresh: true),
          color: kPrimary,
          backgroundColor: kSurface,
          child: Consumer<MusicProvider>(builder: (context, music, child) {
            final notes = music.songNotifications;
            if (notes.isEmpty) {
              return SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Container(
                  height: MediaQuery.of(context).size.height * 0.7,
                  alignment: Alignment.center,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        'assets/image/logo/TuneIn_Logo.png',
                        height: 80,
                        fit: BoxFit.contain,
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'No song notifications yet',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: kOnSurface,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Song activity will appear here',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: kOnSurfaceVariant,
                            ),
                      ),
                    ],
                  ),
                ),
              );
            }
            return ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(12),
              itemCount: notes.length,
              separatorBuilder: (_, __) => const Divider(),
              itemBuilder: (context, index) {
                final n = notes[index];
                final icon = n.type == AppNotificationType.songDeleted
                    ? Icons.delete_outline_rounded
                    : Icons.add_circle_outline_rounded;
                return ListTile(
                  title: Text(n.message),
                  subtitle: Text(TimeOfDay.fromDateTime(n.time).format(context)),
                  leading: Icon(
                    icon,
                    color: n.type == AppNotificationType.songDeleted
                        ? Colors.redAccent
                        : Colors.green,
                  ),
                );
              },
            );
          }),
        ),
      ),
    );
  }
}
