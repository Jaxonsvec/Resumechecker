import 'package:flutter/material.dart';

enum FeedbackKind { loading, empty, error, success }

/// A consistent, accessible presentation for common asynchronous UI states.
class FeedbackState extends StatelessWidget {
  const FeedbackState({
    required this.kind,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
    super.key,
  });

  const FeedbackState.loading({
    required String title,
    required String message,
    Key? key,
  }) : this(
         kind: FeedbackKind.loading,
         title: title,
         message: message,
         key: key,
       );

  const FeedbackState.empty({
    required String title,
    required String message,
    String? actionLabel,
    VoidCallback? onAction,
    Key? key,
  }) : this(
         kind: FeedbackKind.empty,
         title: title,
         message: message,
         actionLabel: actionLabel,
         onAction: onAction,
         key: key,
       );

  const FeedbackState.error({
    required String title,
    required String message,
    String? actionLabel,
    VoidCallback? onAction,
    Key? key,
  }) : this(
         kind: FeedbackKind.error,
         title: title,
         message: message,
         actionLabel: actionLabel,
         onAction: onAction,
         key: key,
       );

  const FeedbackState.success({
    required String title,
    required String message,
    String? actionLabel,
    VoidCallback? onAction,
    Key? key,
  }) : this(
         kind: FeedbackKind.success,
         title: title,
         message: message,
         actionLabel: actionLabel,
         onAction: onAction,
         key: key,
       );

  final FeedbackKind kind;
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final isLoading = kind == FeedbackKind.loading;
    final icon = switch (kind) {
      FeedbackKind.loading => null,
      FeedbackKind.empty => Icons.inbox_outlined,
      FeedbackKind.error => Icons.error_outline,
      FeedbackKind.success => Icons.check_circle_outline,
    };
    final color = switch (kind) {
      FeedbackKind.loading ||
      FeedbackKind.empty => Theme.of(context).colorScheme.primary,
      FeedbackKind.error => Theme.of(context).colorScheme.error,
      FeedbackKind.success => const Color(0xFF287A50),
    };

    return Semantics(
      liveRegion: true,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isLoading)
            CircularProgressIndicator(color: color, semanticsLabel: title)
          else
            Icon(icon, size: 44, color: color),
          const SizedBox(height: 16),
          Text(
            title,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            message,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          if (actionLabel != null && onAction != null) ...[
            const SizedBox(height: 20),
            OutlinedButton(onPressed: onAction, child: Text(actionLabel!)),
          ],
        ],
      ),
    );
  }
}
