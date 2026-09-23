import 'package:flutter/material.dart';

import '../../models/instagram_status.dart';
import '../../services/auth_service.dart';
import '../../services/instagram_service.dart';
import '../../services/limited_gallery_service.dart';
import '../../services/permission_service.dart';
import '../../services/storage_service.dart';
import '../../widgets/gallery_access_dialog.dart';
import '../../widgets/photo_limit_dialog.dart';

import '../auth/login_screen.dart';
import '../draft/draft_history_screen.dart';
import '../gallery_scan/gallery_scan_screen.dart';
import '../instagram/connect_instagram_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() =>
      _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String email = "Loading...";

  InstagramStatus instagramStatus =
      InstagramStatus.notConnected();

  bool loadingInstagram = true;

  @override
  void initState() {
    super.initState();

    loadProfile();
    loadInstagramStatus();
  }

  Future<void> loadProfile() async {
    try {
      final token =
          await StorageService.getToken();

      if (token == null) {
        setState(() {
          email = "No Token Found";
        });

        return;
      }

      final response =
          await AuthService().getProfile(token);

      setState(() {
        email = response["email"];
      });
    } catch (e) {
      setState(() {
        email = e.toString();
      });
    }
  }

  Future<void> loadInstagramStatus() async {
    try {
      final token =
          await StorageService.getToken();

      if (token == null) {
        setState(() {
          loadingInstagram = false;
        });
        return;
      }

      final result =
          await InstagramService()
              .getStatus(token);

      if (!mounted) return;

      setState(() {
        instagramStatus = result;
        loadingInstagram = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        loadingInstagram = false;
      });
    }
  }

  Future<void> logout() async {
    await StorageService.deleteToken();

    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) =>
            const LoginScreen(),
      ),
    );
  }

  Future<void> startAIAnalysis() async {
    final access =
        await showDialog<GalleryAccess>(
      context: context,
      builder: (_) =>
          const GalleryAccessDialog(),
    );

    if (access == null) return;

    if (access == GalleryAccess.deny) {
      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            "Gallery permission denied.",
          ),
        ),
      );

      return;
    }

    final granted =
        await PermissionService
            .requestGalleryPermission();

    if (!granted) {
      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            "Gallery permission is required.",
          ),
        ),
      );

      return;
    }

    if (access == GalleryAccess.full) {
      final limit =
          await showDialog<int>(
        context: context,
        builder: (_) =>
            const PhotoLimitDialog(),
      );

      if (limit == null) return;

      if (!mounted) return;

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) =>
              GalleryScanScreen(
            maxImages: limit,
          ),
        ),
      );

      return;
    }

    final images =
        await LimitedGalleryService()
            .pickImages();

    if (images.isEmpty) return;

    if (!mounted) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            GalleryScanScreen(
          maxImages: -1,
          selectedImages: images,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("InstaAI"),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: logout,
            icon: const Icon(
              Icons.logout,
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding:
            const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.stretch,
          children: [
            const CircleAvatar(
              radius: 45,
              child: Icon(
                Icons.person,
                size: 45,
              ),
            ),

            const SizedBox(height: 20),

            const Text(
              "Welcome to InstaAI",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 28,
                fontWeight:
                    FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            Text(
              email,
              textAlign: TextAlign.center,
              style:
                  const TextStyle(
                fontSize: 18,
              ),
            ),

            const SizedBox(height: 25),

            Card(
              elevation: 3,
              child: Padding(
                padding:
                    const EdgeInsets.all(
                        16),
                child: loadingInstagram
                    ? const Center(
                        child:
                            CircularProgressIndicator(),
                      )
                    : Column(
                        crossAxisAlignment:
                            CrossAxisAlignment
                                .start,
                        children: [
                          const Text(
                            "Instagram",
                            style:
                                TextStyle(
                              fontSize:
                                  20,
                              fontWeight:
                                  FontWeight
                                      .bold,
                            ),
                          ),

                          const SizedBox(
                              height:
                                  15),

                          Row(
                            children: [
                              Icon(
                                instagramStatus
                                        .connected
                                    ? Icons
                                        .check_circle
                                    : Icons
                                        .cancel,
                                color: instagramStatus
                                        .connected
                                    ? Colors
                                        .green
                                    : Colors
                                        .red,
                              ),

                              const SizedBox(
                                  width:
                                      10),

                              Text(
                                instagramStatus
                                        .connected
                                    ? "Connected"
                                    : "Not Connected",
                              ),
                            ],
                          ),

                          if (instagramStatus
                              .connected) ...[
                            const SizedBox(
                                height:
                                    10),

                            Text(
                              "@${instagramStatus.username ?? ""}",
                              style:
                                  const TextStyle(
                                fontSize:
                                    16,
                                fontWeight:
                                    FontWeight
                                        .w500,
                              ),
                            ),

                            const SizedBox(
                                height:
                                    10),

                            Row(
                              children: [
                                Icon(
                                  instagramStatus.personalizationReady
                                      ? Icons.auto_awesome
                                      : Icons.hourglass_empty,
                                  color: instagramStatus.personalizationReady
                                      ? Colors.purple
                                      : Colors.orange,
                                ),

                                const SizedBox(
                                    width:
                                        10),

                                Expanded(
                                  child:
                                      Text(
                                    instagramStatus.personalizationReady
                                        ? "Personalization Ready"
                                        : "Personalization Not Generated",
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
              ),
            ),

            const SizedBox(height: 25),
                        ElevatedButton.icon(
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        const ConnectInstagramScreen(),
                  ),
                );

                await loadInstagramStatus();
              },
              icon: const Icon(Icons.camera_alt),
              label: Text(
                instagramStatus.connected
                    ? "Manage Instagram"
                    : "Connect Instagram",
              ),
            ),

            const SizedBox(height: 15),

            ElevatedButton.icon(
              onPressed: startAIAnalysis,
              icon: const Icon(Icons.auto_awesome),
              label: const Text(
                "Analyze Gallery",
              ),
            ),

            const SizedBox(height: 15),

            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        const DraftHistoryScreen(),
                  ),
                );
              },
              icon: const Icon(Icons.history),
              label: const Text(
                "View Drafts",
              ),
            ),

            const SizedBox(height: 30),

            Card(
              color: Colors.blue.shade50,
              child: const Padding(
                padding: EdgeInsets.all(16),
                child: Row(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.tips_and_updates,
                      color: Colors.blue,
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        "Connect your Instagram account and run "
                        "\"Sync & Analyze\" to enable personalized "
                        "AI recommendations. Otherwise, InstaAI "
                        "will recommend your best gallery photos "
                        "using generic AI scoring.",
                      ),
                    ),
                  ],
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