import 'package:flutter/material.dart';
import '../../services/gallery_service.dart';

import '../../services/recommendation_service.dart';
import '../../models/recommendation.dart';
import '../recommendation/recommendation_screen.dart';
import '../../services/upload_service.dart';
import '../../models/gallery_media.dart';
import '../../services/storage_service.dart';

class GalleryScanScreen extends StatefulWidget {

  final int maxImages;

  final List<String>? selectedImages;

  const GalleryScanScreen({

    super.key,

    required this.maxImages,

    this.selectedImages,

  });
  @override
  State<GalleryScanScreen> createState() =>
      _GalleryScanScreenState();

}

class _GalleryScanScreenState
    extends State<GalleryScanScreen> {
        

     double progress = 0;

     String currentStep =
      "Preparing...";

     int currentFile = 0;

     int totalFiles = 0;
    int imageCount = 0;

    int videoCount = 0;
    List<Recommendation> recommendations = [];

  @override
  void initState() {
    super.initState();
    Future.delayed(
    const Duration(milliseconds: 300),
    () {
      startScan();
    },
   );
  }
  
  Future<void> startScan() async {

   setState(() {

    currentStep = "Loading Gallery";

   });
   imageCount = 0;
   videoCount = 0;
   currentFile = 0;
   progress = 0;
   recommendations.clear();

   List<String> imagePaths = [];

if (widget.selectedImages != null) {

  imagePaths = widget.selectedImages!;

  totalFiles = imagePaths.length;

} else {

  final media =
      await GalleryService().loadMedia(
    widget.maxImages,
  );

  imagePaths = media
      .where((e) => !e.isVideo)
      .map((e) => e.path)
      .toList();

  totalFiles = imagePaths.length;

}

videoCount = 0;

    for (int i = 0; i < imagePaths.length; i++) {

  await Future.delayed(
    const Duration(milliseconds: 15),
  );

  if (!mounted) return;

  setState(() {

    currentFile = i + 1;

    progress = (i + 1) / imagePaths.length;

    currentStep =
        "Reading ${imagePaths[i].split('/').last}";

  });

}
    setState(() {
  currentStep = "Uploading Images";
});

try {

  final uploadedImages =
      await UploadService().uploadImages(
    imagePaths,
  );

  print("Uploaded Images: ${uploadedImages.length}");

  setState(() {
    currentStep = "Running AI Recommendation";
  });
  final token = await StorageService.getToken();

  if (token == null) {
  throw Exception("User not logged in.");
  }

  recommendations =
      await RecommendationService()
          .recommendImages(
    token,        
    uploadedImages,
  );

  print("Recommendations: ${recommendations.length}");

  if (!mounted) return;

  setState(() {
    progress = 1;
    currentStep = "Gallery Analysis Complete";
  });

} catch (e, stack) {

  print("================================");
  print("ERROR DURING RECOMMENDATION");
  print(e);
  print(stack);
  print("================================");

}
  }
  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: const Text(
          "AI Gallery Scanner",
        ),
      ),

      body: Padding(

       padding: const EdgeInsets.all(20),

       child: Center(

        child: Column(

        mainAxisAlignment:
          MainAxisAlignment.center,

      children: [

        const Icon(
          Icons.auto_awesome,
          size: 90,
          color: Colors.blue,
        ),

        const SizedBox(height: 20),

        const Text(

          "Analyzing Your Gallery",

          style: TextStyle(

            fontSize: 28,

            fontWeight:
                FontWeight.bold,

          ),

        ),

        const SizedBox(height: 40),

        LinearProgressIndicator(
          value: progress,
          minHeight: 10,
        ),

        const SizedBox(height: 20),

        Text(

          "${(progress * 100).toInt()}%",

          style: const TextStyle(
            fontSize: 24,
          ),

        ),

        const SizedBox(height: 30),

        Column(
         children: [

          Text(
           currentStep,
           style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
           ),
          ),

          const SizedBox(height: 25),

           Row(
            children: [

             Icon(
              progress >= 0.20
              ? Icons.check_circle
              : Icons.radio_button_unchecked,
              color: progress >= 0.20
              ? Colors.green
              : Colors.grey,
             ),

             const SizedBox(width: 10),

             const Text(
              "Reading Gallery",
              style: TextStyle(fontSize: 16),
             ),

            ],
           ),

           const SizedBox(height: 12),

           Row(
            children: [

              Icon(
              progress >= 0.40
              ? Icons.check_circle
              : Icons.radio_button_unchecked,
              color: progress >= 0.40
              ? Colors.green
              : Colors.grey,
              ),

              const SizedBox(width: 10),

              const Text(
               "Loading Images",
               style: TextStyle(fontSize: 16),
              ),

            ],
           ),

           const SizedBox(height: 12),

           Row(
            children: [

             Icon(
              progress >= 0.70
              ? Icons.check_circle
              : Icons.hourglass_top,
              color: progress >= 0.70
              ? Colors.green
              : Colors.orange,
             ),

             const SizedBox(width: 10),

             const Text(
              "Extracting Metadata",
              style: TextStyle(fontSize: 16),
             ),

            ],
           ),

           const SizedBox(height: 12),

           Row(
            children: [

             Icon(
              progress >= 1
              ? Icons.check_circle
              : Icons.hourglass_top,
              color: progress >= 1
              ? Colors.green
              : Colors.orange,
             ),

             const SizedBox(width: 10),

             const Text(
              "Preparing AI Analysis",
              style: TextStyle(fontSize: 16),
             ),

            ],
           ),

         ],
        ),

        const SizedBox(height: 20),

        Text(

          "$currentFile / $totalFiles Files",

          style: const TextStyle(
            fontSize: 16,
          ),

        ),
        const SizedBox(height: 40),

        if (progress == 1)

         ElevatedButton(

         onPressed: () {

          Navigator.push(

           context,

            MaterialPageRoute(

             builder: (_) => RecommendationScreen(

              recommendations:

                 recommendations,

             ),

            ),

          );
  
         },

         child: const Text(
          "Continue",
         ),

        ),

      ],

    ),

   ),

   ),
  );
 }
}