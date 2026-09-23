import 'dart:io';

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../models/draft.dart';
import '../../services/draft_service.dart';
import '../../services/publish_service.dart';
import '../../services/storage_service.dart';

class DraftDetailScreen extends StatefulWidget {
  final Draft draft;

  const DraftDetailScreen({
    super.key,
    required this.draft,
  });

  @override
  State<DraftDetailScreen> createState() =>
      _DraftDetailScreenState();
}

class _DraftDetailScreenState
    extends State<DraftDetailScreen> {
  late TextEditingController captionController;

  late TextEditingController hashtagController;

  bool saving = false;

  bool publishing = false;

  bool deleting = false;

  bool scheduling = false;

  DateTime? selectedDateTime;

  @override
  void initState() {
    super.initState();

    captionController = TextEditingController(
      text: widget.draft.caption,
    );

    hashtagController = TextEditingController(
      text: widget.draft.hashtags.join(" "),
    );
  }

  @override
  void dispose() {
    captionController.dispose();
    hashtagController.dispose();
    super.dispose();
  }

  List<String> get hashtags {
    return hashtagController.text
        .trim()
        .split(RegExp(r'\s+'))
        .where(
          (e) => e.isNotEmpty,
        )
        .toList();
  }

  Widget buildImage() {
    if (widget.draft.imagePaths.isEmpty) {
      return Container(
        height: 280,
        color: Colors.grey.shade300,
        child: const Center(
          child: Icon(
            Icons.image,
            size: 80,
          ),
        ),
      );
    }

    final image =
        widget.draft.imagePaths.first;

    if (image.startsWith("http")) {
      return ClipRRect(
        borderRadius:
            BorderRadius.circular(15),
        child: Image.network(
          image,
          height: 280,
          width: double.infinity,
          fit: BoxFit.cover,
        ),
      );
    }

    if (File(image).existsSync()) {
      return ClipRRect(
        borderRadius:
            BorderRadius.circular(15),
        child: Image.file(
          File(image),
          height: 280,
          width: double.infinity,
          fit: BoxFit.cover,
        ),
      );
    }

    return ClipRRect(
      borderRadius:
          BorderRadius.circular(15),
      child: Image.network(
        "https://instaai-production.up.railway.app/${image.replaceAll("\\", "/")}",
        height: 280,
        width: double.infinity,
        fit: BoxFit.cover,
      ),
    );
  }

  Future<void> saveChanges() async {
    setState(() {
      saving = true;
    });

    try {
      await DraftService().updateDraft(
        widget.draft.id,
        captionController.text.trim(),
        hashtags,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            "Draft updated successfully.",
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(e.toString()),
        ),
      );
    }

    if (!mounted) return;

    setState(() {
      saving = false;
    });
  }
    Future<void> publishDraft() async {
    setState(() {
      publishing = true;
    });

    try {
      final token = await StorageService.getToken();

      if (token == null) {
        throw Exception("User not logged in.");
      }

      final result =
          await PublishService().publishDraft(
        token,
        widget.draft.id,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            result["message"] ??
                "Published successfully.",
          ),
        ),
      );

      Navigator.pop(
        context,
        true,
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e.toString(),
          ),
        ),
      );
    }

    if (!mounted) return;

    setState(() {
      publishing = false;
    });
  }

  Future<void> deleteDraft() async {
    final confirm =
        await showDialog<bool>(
              context: context,
              builder: (_) => AlertDialog(
                title: const Text(
                  "Delete Draft",
                ),
                content: const Text(
                  "Delete this draft permanently?",
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(
                        context,
                        false,
                      );
                    },
                    child: const Text(
                      "Cancel",
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(
                        context,
                        true,
                      );
                    },
                    child: const Text(
                      "Delete",
                    ),
                  ),
                ],
              ),
            ) ??
            false;

    if (!confirm) return;

    setState(() {
      deleting = true;
    });

    try {
      await DraftService().deleteDraft(
        widget.draft.id,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Draft deleted successfully.",
          ),
        ),
      );

      Navigator.pop(
        context,
        true,
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e.toString(),
          ),
        ),
      );
    }

    if (!mounted) return;

    setState(() {
      deleting = false;
    });
  }

  Future<void> pickDate() async {
  final picked = await showDatePicker(
    context: context,
    initialDate: DateTime.now(),
    firstDate: DateTime.now(),
    lastDate: DateTime(2035),
  );

  if (picked == null) return;

  setState(() {
    selectedDateTime = DateTime(
      picked.year,
      picked.month,
      picked.day,
    );
  });
}

Future<void> pickTime() async {
  if (selectedDateTime == null) return;

  final picked = await showTimePicker(
    context: context,
    initialTime: TimeOfDay.now(),
  );

  if (picked == null) return;

  setState(() {
    selectedDateTime = DateTime(
      selectedDateTime!.year,
      selectedDateTime!.month,
      selectedDateTime!.day,
      picked.hour,
      picked.minute,
    );
  });
}

Future<void> scheduleDraft() async {

  if (selectedDateTime == null) {

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          "Please select date & time.",
        ),
      ),
    );

    return;
  }

  setState(() {
    scheduling = true;
  });

  try {

    await DraftService().scheduleDraft(

      draftId: widget.draft.id,

      scheduledTime: selectedDateTime!,

    );

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          "Post scheduled successfully.",
        ),
      ),
    );

    Navigator.pop(
      context,
      true,
    );

  } catch (e) {

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(e.toString()),
      ),
    );

  }

  if (!mounted) return;

  setState(() {
    scheduling = false;
  });
}

  Future<void> openInstagram() async {
  if (widget.draft.instagramPostUrl == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Instagram URL not available."),
      ),
    );
    return;
  }

  print("Instagram URL: ${widget.draft.instagramPostUrl}");

  final uri = Uri.parse(widget.draft.instagramPostUrl!);

  final launched = await launchUrl(
    uri,
    mode: LaunchMode.externalApplication,
  );

  if (!launched && mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Unable to open Instagram."),
      ),
    );
  }
}
    @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Draft Details",
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: ListView(
          children: [

            buildImage(),

            const SizedBox(height: 20),

            Text(
              widget.draft.category,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 20),

            TextField(
              controller: captionController,
              maxLines: 8,
              decoration: const InputDecoration(
                labelText: "Caption",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 20),

            TextField(
              controller: hashtagController,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: "Hashtags",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 30),

            ElevatedButton.icon(
              onPressed:
                  saving ? null : saveChanges,
              icon: saving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child:
                          CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.save),
              label: Text(
                saving
                    ? "Saving..."
                    : "Save Changes",
              ),
            ),

            const SizedBox(height: 15),

            if (widget.draft.status !=
                "Published")
              ElevatedButton.icon(
                style:
                    ElevatedButton.styleFrom(
                  backgroundColor:
                      Colors.green,
                  foregroundColor:
                      Colors.white,
                ),
                onPressed: publishing
                    ? null
                    : publishDraft,
                icon: publishing
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child:
                            CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(
                        Icons.send,
                      ),
                label: Text(
                  publishing
                      ? "Publishing..."
                      : "Post to Instagram",
                ),
              ),

              const SizedBox(height: 15),

if (widget.draft.status != "Published")
  ElevatedButton.icon(
    style: ElevatedButton.styleFrom(
      backgroundColor: Colors.orange,
      foregroundColor: Colors.white,
    ),
    onPressed: scheduling
        ? null
        : () async {

            await pickDate();

            if (selectedDateTime == null) {
              return;
            }

            await pickTime();

            if (selectedDateTime == null) {
              return;
            }

            await scheduleDraft();

          },
    icon: scheduling
        ? const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: Colors.white,
            ),
          )
        : const Icon(
            Icons.schedule,
          ),
    label: Text(
      scheduling
          ? "Scheduling..."
          : "Schedule Post",
    ),
  ),

            if (widget.draft.status ==
                    "Published" &&
                widget.draft.instagramPostUrl !=
                    null) ...[
              const SizedBox(height: 15),

              ElevatedButton.icon(
                style:
                    ElevatedButton.styleFrom(
                  backgroundColor:
                      Colors.blue,
                  foregroundColor:
                      Colors.white,
                ),
                onPressed: openInstagram,
                icon: const Icon(
                  Icons.open_in_new,
                ),
                label: const Text(
                  "View on Instagram",
                ),
              ),
            ],

            const SizedBox(height: 15),

            ElevatedButton.icon(
              style:
                  ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor:
                    Colors.white,
              ),
              onPressed: deleting
                  ? null
                  : deleteDraft,
              icon: deleting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child:
                          CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(
                      Icons.delete,
                    ),
              label: Text(
                deleting
                    ? "Deleting..."
                    : "Delete Draft",
              ),
            ),

            const SizedBox(height: 25),

            Center(
              child: Chip(
                avatar: Icon(
                  widget.draft.status ==
                          "Published"
                      ? Icons.check_circle
                      : Icons.edit_note,
                  color: widget.draft.status ==
                          "Published"
                      ? Colors.green
                      : Colors.orange,
                ),
                backgroundColor:
                    widget.draft.status ==
                            "Published"
                        ? Colors.green
                            .shade100
                        : Colors.orange
                            .shade100,
                label: Text(
                  widget.draft.status,
                  style: TextStyle(
                    fontWeight:
                        FontWeight.bold,
                    color: widget.draft.status ==
                            "Published"
                        ? Colors.green
                        : Colors.orange,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}