import 'package:flutter/material.dart';

class PhotoLimitDialog extends StatefulWidget {

  const PhotoLimitDialog({
    super.key,
  });

  @override
  State<PhotoLimitDialog> createState() =>
      _PhotoLimitDialogState();

}

class _PhotoLimitDialogState
    extends State<PhotoLimitDialog> {

  int selected = 20;

  @override
  Widget build(BuildContext context) {

    return AlertDialog(

      title: const Text(
        "Analyze Recent Photos",
      ),

      content: Column(

        mainAxisSize: MainAxisSize.min,

        children: [

          RadioListTile(

            value: 20,

            groupValue: selected,

            title: const Text(
              "20 Photos (Fast) ⭐",
            ),

            onChanged: (value) {

              setState(() {

                selected = value!;

              });

            },

          ),

          RadioListTile(

            value: 50,

            groupValue: selected,

            title: const Text(
              "50 Photos",
            ),

            onChanged: (value) {

              setState(() {

                selected = value!;

              });

            },

          ),

          RadioListTile(

            value: 100,

            groupValue: selected,

            title: const Text(
              "100 Photos",
            ),

            onChanged: (value) {

              setState(() {

                selected = value!;

              });

            },

          ),

          RadioListTile(

            value: -1,

            groupValue: selected,

            title: const Text(
              "All Photos",
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
            "Start",
          ),

        ),

      ],

    );

  }

}