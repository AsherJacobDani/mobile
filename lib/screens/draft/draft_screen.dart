import 'package:flutter/material.dart';

import '../../models/draft.dart';
import '../../services/content_service.dart';
import '../../services/draft_service.dart';

class DraftScreen extends StatefulWidget {
  final Draft draft;

  const DraftScreen({
    super.key,
    required this.draft,
  });

  @override
  State<DraftScreen> createState() => _DraftScreenState();
}

class _DraftScreenState extends State<DraftScreen> {
  late TextEditingController captionController;
  late TextEditingController hashtagController;

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

  Future<void> regenerateCaption() async {
    try {
      Draft draft = await ContentService().generateCaption(
        "demo_user",
        widget.draft.imagePaths,
      );

      if (!mounted) return;

      setState(() {
        captionController.text = draft.caption;
        hashtagController.text = draft.hashtags.join(" ");
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Caption regenerated successfully.",
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Failed: $e"),
        ),
      );
    }
  }

  Future<void> saveDraft() async {
    try {
      List<String> hashtags = hashtagController.text
          .trim()
          .split(RegExp(r'\s+'))
          .where((tag) => tag.isNotEmpty)
          .toList();

      await DraftService().createDraft(
        username: "demo_user",
        category: widget.draft.category,
        imagePaths: widget.draft.imagePaths,
        caption: captionController.text.trim(),
        hashtags: hashtags,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Draft saved successfully.",
          ),
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Failed to save draft: $e",
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Generated Draft"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: ListView(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: Image.network(
                widget.draft.imagePaths.first,
                height: 280,
                width: double.infinity,
                fit: BoxFit.cover,
                loadingBuilder: (
                  context,
                  child,
                  loadingProgress,
                ) {
                  if (loadingProgress == null) {
                    return child;
                  }

                  return const SizedBox(
                    height: 280,
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  );
                },
                errorBuilder: (
                  context,
                  error,
                  stackTrace,
                ) {
                  return Container(
                    height: 280,
                    color: Colors.grey.shade300,
                    child: const Center(
                      child: Icon(
                        Icons.broken_image,
                        size: 70,
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 20),

            const Center(
              child: Chip(
                avatar: Icon(
                  Icons.auto_awesome,
                  color: Colors.blue,
                ),
                label: Text("AI Generated"),
              ),
            ),

            const SizedBox(height: 20),

            TextField(
              controller: captionController,
              maxLines: 8,
              onChanged: (_) {
                setState(() {});
              },
              decoration: const InputDecoration(
                labelText: "Caption",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 8),

            Align(
              alignment: Alignment.centerRight,
              child: Text(
                "${captionController.text.length}/2200",
                style: const TextStyle(
                  color: Colors.grey,
                ),
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

            const SizedBox(height: 25),

            OutlinedButton.icon(
              onPressed: regenerateCaption,
              icon: const Icon(Icons.refresh),
              label: const Text("Regenerate"),
            ),

            const SizedBox(height: 20),

            ElevatedButton.icon(
              onPressed: saveDraft,
              icon: const Icon(Icons.save),
              label: const Text("Save Draft"),
            ),
          ],
        ),
      ),
    );
  }
}