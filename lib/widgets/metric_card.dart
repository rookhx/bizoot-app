import 'package:flutter/material.dart';

import 'premium_metric_card.dart';

class MetricCard extends StatelessWidget {
  final String label;
  final String value;
  final String? hint;
  final bool emphasize;
  final IconData icon;
  final Widget? trailing;

  const MetricCard({
    super.key,
    required this.label,
    required this.value,
    this.hint,
    this.emphasize = false,
    this.icon = Icons.auto_graph_outlined,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return PremiumMetricCard(
      label: label,
      value: value,
      hint: hint,
      emphasize: emphasize,
      icon: icon,
      trailing: trailing,
    );
  }
}
