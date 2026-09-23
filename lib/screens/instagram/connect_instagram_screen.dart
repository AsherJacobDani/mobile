import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../models/instagram_profile.dart';
import '../../models/instagram_status.dart';
import '../../services/instagram_service.dart';
import '../../services/storage_service.dart';

class ConnectInstagramScreen extends StatefulWidget {
  const ConnectInstagramScreen({super.key});

  @override
  State<ConnectInstagramScreen> createState() =>
      _ConnectInstagramScreenState();
}

class _ConnectInstagramScreenState
    extends State<ConnectInstagramScreen>
    with WidgetsBindingObserver {
  bool loading = true;
  bool personalizationLoading = false;

  InstagramStatus status = InstagramStatus.notConnected();
  InstagramProfile? profile;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    loadStatus();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      loadStatus();
    }
  }

  Future<void> loadStatus() async {
    try {
      final token = await StorageService.getToken();

      if (token == null) {
        setState(() {
          loading = false;
        });
        return;
      }

      final service = InstagramService();

      final result = await service.getStatus(token);

      InstagramProfile? loadedProfile;

      if (result.connected) {
        loadedProfile = await service.getProfile(token);
      }

      if (!mounted) return;

      setState(() {
        status = result;
        profile = loadedProfile;
        loading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        loading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error: $e"),
        ),
      );
    }
  }

  Future<void> connectInstagram() async {
    try {
      final token = await StorageService.getToken();

      if (token == null) {
        throw Exception("Please login first.");
      }

      final loginUrl =
          await InstagramService().getLoginUrl(token);

      final launched = await launchUrl(
        Uri.parse(loginUrl),
        mode: LaunchMode.externalApplication,
      );

      if (!launched) {
        throw Exception("Could not open Instagram login.");
      }
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error: $e"),
        ),
      );
    }
  }

  Future<void> disconnectInstagram() async {
    try {
      final token = await StorageService.getToken();

      if (token == null) return;

      await InstagramService().disconnect(token);

      setState(() {
        status = InstagramStatus.notConnected();
        profile = null;
      });

      await loadStatus();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Instagram disconnected successfully.",
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error: $e"),
        ),
      );
    }
  }

  Future<void> syncAndAnalyze() async {
    try {
      final token = await StorageService.getToken();

      if (token == null) return;

      setState(() {
        personalizationLoading = true;
      });

      final service = InstagramService();

      await service.preparePersonalization(token);

      await loadStatus();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Personalization generated successfully.",
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error: $e"),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          personalizationLoading = false;
        });
      }
    }
  }

  String getLastUpdated() {
  if (status.lastUpdated == null) {
    return "Never";
  }

  return DateFormat(
    "dd MMM yyyy • hh:mm a",
  ).format(
    status.lastUpdated!.toLocal(),
  );
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Instagram Management"),
        centerTitle: true,
      ),
      body: loading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : RefreshIndicator(
              onRefresh: loadStatus,
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  const Icon(
                    Icons.camera_alt,
                    size: 64,
                    color: Colors.purple,
                  ),

                  const SizedBox(height: 16),

                  Card(
                    child: ListTile(
                      leading: Icon(
                        status.connected
                            ? Icons.check_circle
                            : Icons.cancel,
                        color: status.connected
                            ? Colors.green
                            : Colors.red,
                      ),
                      title: Text(
                        status.connected
                            ? "Connected"
                            : "Not Connected",
                      ),
                      subtitle: Text(
                        status.connected
                            ? (status.username ?? "")
                            : "No Instagram account linked",
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  if (status.connected && profile != null)
                    Card(
                      child: Padding(
                        padding:
                            const EdgeInsets.all(12),
                        child: Column(
                          children: [
                            const CircleAvatar(
                              radius: 32,
                              child: Icon(
                                Icons.person,
                                size: 32,
                              ),
                            ),

                            const SizedBox(height: 10),

                            Text(
                              profile!.username,
                              style:
                                  const TextStyle(
                                fontSize: 18,
                                fontWeight:
                                    FontWeight.bold,
                              ),
                            ),

                            Text(
                              profile!.accountType,
                            ),

                            const SizedBox(height: 10),

                            const Divider(height:12),

                            Row(
                              mainAxisAlignment:
                                  MainAxisAlignment
                                      .spaceAround,
                              children: [
                                Column(
                                  children: [
                                    Text(
                                      profile!
                                          .followers
                                          .toString(),
                                      style:
                                          const TextStyle(
                                        fontWeight:
                                            FontWeight
                                                .bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                    const Text(
                                      "Followers",
                                    ),
                                  ],
                                ),
                                Column(
                                  children: [
                                    Text(
                                      profile!
                                          .following
                                          .toString(),
                                      style:
                                          const TextStyle(
                                        fontWeight:
                                            FontWeight
                                                .bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                    const Text(
                                      "Following",
                                    ),
                                  ],
                                ),
                                Column(
                                  children: [
                                    Text(
                                      profile!.posts
                                          .toString(),
                                      style:
                                          const TextStyle(
                                        fontWeight:
                                            FontWeight
                                                .bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                    const Text(
                                      "Posts",
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),

                  const SizedBox(height: 16),

                  if (status.connected)
                    Card(
                      child: Padding(
                        padding:
                            const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment
                                  .start,
                          children: [
                            const Text(
                              "Personalization",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight:
                                    FontWeight.bold,
                              ),
                            ),

                            const SizedBox(
                                height: 16),

                            Row(
                              children: [
                                Icon(
                                  status
                                          .personalizationReady
                                      ? Icons
                                          .check_circle
                                      : Icons.cancel,
                                  color: status
                                          .personalizationReady
                                      ? Colors.green
                                      : Colors.orange,
                                ),

                                const SizedBox(
                                    width: 10),

                                Text(
                                  status
                                          .personalizationReady
                                      ? "Ready"
                                      : "Not Generated",
                                  style:
                                      const TextStyle(
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(
                                height: 12),

                            Text(
                              "Last Updated: ${getLastUpdated()}",
                            ),
                          ],
                        ),
                      ),
                    ),

                  const SizedBox(height: 24),

                  if (status.connected)
                    ElevatedButton.icon(
                      icon: personalizationLoading
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child:
                                  CircularProgressIndicator(
                                strokeWidth: 2,
                                color:
                                    Colors.white,
                              ),
                            )
                          : const Icon(
                              Icons.auto_awesome,
                            ),
                      label: Text(
                        personalizationLoading
                            ? "Generating..."
                            : "Sync & Analyze",
                      ),
                      onPressed:
                          personalizationLoading
                              ? null
                              : syncAndAnalyze,
                    ),


                  const SizedBox(height: 12),

                  ElevatedButton.icon(
                    icon: const Icon(
                      Icons.login,
                    ),
                    label: Text(
                      status.connected
                          ? "Reconnect Instagram"
                          : "Connect Instagram",
                    ),
                    onPressed: connectInstagram,
                  ),

                  const SizedBox(height: 12),

                  if (status.connected)
                    OutlinedButton.icon(
                      icon: const Icon(
                        Icons.logout,
                      ),
                      label:
                          const Text("Disconnect"),
                      onPressed:
                          disconnectInstagram,
                    ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
    );
  }
}