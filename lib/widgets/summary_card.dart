import 'package:flutter/material.dart';

class SummaryCard extends StatelessWidget {
  final String label;
  final String value;
  final Color valueColor;

  const SummaryCard({
    super.key,
    required this.label,
    required this.value,
    required this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.18),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
            style: const TextStyle(color: Color(0xFF9AC5F5), fontSize: 11),
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 3),
          Text(value,
            style: TextStyle(color: valueColor, fontSize: 13, fontWeight: FontWeight.w600),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
