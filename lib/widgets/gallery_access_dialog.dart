import 'package:flutter/material.dart';

enum GalleryAccess {
  full,
  limited,
  deny,
}

class GalleryAccessDialog extends StatefulWidget {
  const GalleryAccessDialog({super.key});

  @override
  State<GalleryAccessDialog> createState() =>
      _GalleryAccessDialogState();
}

class _GalleryAccessDialogState
    extends State<GalleryAccessDialog> {

  GalleryAccess selected =
      GalleryAccess.full;

  @override
  Widget build(BuildContext context) {

    return AlertDialog(

      title: const Text(
        "Gallery Access",
      ),

      content: Column(

        mainAxisSize: MainAxisSize.min,

        children: [

          RadioListTile(

            value: GalleryAccess.full,

            groupValue: selected,

            title: const Text(
              "Full Gallery Access",
            ),

            subtitle: const Text(
              "AI can analyze your newest photos.",
            ),

            onChanged: (value) {

              setState(() {

                selected = value!;

              });

            },

          ),

          RadioListTile(

            value: GalleryAccess.limited,

            groupValue: selected,

            title: const Text(
              "Limited Access",
            ),

            subtitle: const Text(
              "Choose specific photos only.",
            ),

            onChanged: (value) {

              setState(() {

                selected = value!;

              });

            },

          ),

          RadioListTile(

            value: GalleryAccess.deny,

            groupValue: selected,

            title: const Text(
              "Don't Allow",
            ),

            onChanged: (value) {

              setState(() {

                selected = value!;

              });

            },

          ),

        ],

      ),

      actions: [

        TextButton(

          onPressed: () {

            Navigator.pop(context);

          },

          child: const Text(
            "Cancel",
          ),

        ),

        ElevatedButton(

          onPressed: () {

            Navigator.pop(
              context,
              selected,
            );

          },

          child: const Text(
            "Continue",
          ),

        ),

      ],

    );

  }

}