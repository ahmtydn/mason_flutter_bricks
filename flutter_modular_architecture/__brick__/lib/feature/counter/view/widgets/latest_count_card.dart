import 'package:flutter/material.dart';

class LatestCountCard extends StatelessWidget {
  const LatestCountCard({
    required this.title,
    required this.timestamp,
    this.note,
    super.key,
  });

  final String title;
  final String timestamp;
  final String? note;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(title, style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(height: 8),
            Text(timestamp),
            if (note != null) ...[
              const SizedBox(height: 8),
              Text(note!, style: Theme.of(context).textTheme.bodyMedium),
            ],
          ],
        ),
      ),
    );
  }
}
