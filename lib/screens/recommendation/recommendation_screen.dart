import 'package:flutter/material.dart';

import '../../models/recommendation.dart';
import '../../models/draft.dart';

import '../../services/content_service.dart';

import '../draft/draft_screen.dart';

class RecommendationScreen extends StatefulWidget {
  final List<Recommendation> recommendations;

  const RecommendationScreen({
    super.key,
    required this.recommendations,
  });

  @override
  State<RecommendationScreen> createState() =>
      _RecommendationScreenState();
}

class _RecommendationScreenState
    extends State<RecommendationScreen> {
  List<Recommendation> selectedImages = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Selected ${selectedImages.length}",
        ),
      ),

      body: ListView.builder(
        itemCount: widget.recommendations.length,

        itemBuilder: (context, index) {
          final image =
              widget.recommendations[index];
              print("IMAGE URL: ${image.imagePath}");

          final isSelected =
              selectedImages.contains(image);

          return GestureDetector(
            onTap: () {
              setState(() {
                // Single selection
                selectedImages.clear();
                selectedImages.add(image);
              });
            },

            child: Card(
              margin: const EdgeInsets.all(10),

              color: isSelected
                  ? Colors.blue.shade100
                  : Colors.white,

              elevation: isSelected ? 8 : 2,

              child: ListTile(
                leading: ClipRRect(
                  borderRadius:
                      BorderRadius.circular(8),

                  child: Image.network(
                    image.imagePath,

                    width: 70,

                    height: 70,

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
                        width: 70,
                        height: 70,
                        child: Center(
                          child:
                              CircularProgressIndicator(),
                        ),
                      );
                    },

                    errorBuilder: (
                      context,
                      error,
                      stackTrace,
                    ) {
                      return Container(
                        width: 70,
                        height: 70,
                        color: Colors.grey.shade300,
                        child: const Icon(
                          Icons.broken_image,
                          size: 40,
                        ),
                      );
                    },
                  ),
                ),

                title: Text(
                  image.category,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),

                subtitle: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,

                  children: [
                    const SizedBox(height: 6),

                    Text(
                      "Score : ${image.score}",
                    ),

                    Text(
                      "Grade : ${image.grade}",
                    ),

                    Text(
                      "Confidence : ${(image.confidence * 100).toStringAsFixed(0)}%",
                    ),
                  ],
                ),

                trailing: isSelected
                    ? const CircleAvatar(
                        radius: 12,
                        backgroundColor:
                            Colors.green,
                        child: Icon(
                          Icons.check,
                          size: 15,
                          color: Colors.white,
                        ),
                      )
                    : null,
              ),
            ),
          );
        },
      ),

      floatingActionButton:
          selectedImages.isEmpty
              ? null
              : FloatingActionButton.extended(
                  onPressed: () async {
                    Draft draft =
                        await ContentService()
                            .generateCaption(
                      "demo_user",
                      [
                        selectedImages
                            .first
                            .imagePath,
                      ],
                    );

                    if (!mounted) return;

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            DraftScreen(
                          draft: draft,
                        ),
                      ),
                    );
                  },
                  icon: const Icon(
                    Icons.auto_awesome,
                  ),
                  label: const Text(
                    "Generate Caption",
                  ),
                ),
    );
  }
}