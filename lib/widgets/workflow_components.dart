import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class PrototypeBanner extends StatelessWidget {
  const PrototypeBanner({super.key});

  @override
  Widget build(BuildContext context) => const Card(
    color: AppColors.accentSurface,
    child: Padding(
      padding: EdgeInsets.all(12),
      child: Row(
        children: [
          Icon(Icons.visibility_outlined, color: AppColors.teal),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'Design preview · no file is processed',
              style: TextStyle(
                color: AppColors.ink,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

class WorkflowStepHeader extends StatelessWidget {
  const WorkflowStepHeader({
    required this.step,
    required this.label,
    super.key,
  });

  final int step;
  final String label;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      CircleAvatar(
        radius: 16,
        backgroundColor: AppColors.accentSurface,
        foregroundColor: AppColors.teal,
        child: Text('$step'),
      ),
      const SizedBox(width: 10),
      Text('STEP $step OF 3', style: Theme.of(context).textTheme.labelMedium),
      const SizedBox(width: 10),
      Expanded(
        child: Text(label, style: Theme.of(context).textTheme.titleMedium),
      ),
    ],
  );
}
