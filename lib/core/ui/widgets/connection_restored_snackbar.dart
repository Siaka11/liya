import 'package:flutter/material.dart';

/// SnackBar affiché lors de la reconnexion
class ConnectionRestoredSnackBar extends StatefulWidget {
  final String? message;
  final VoidCallback? onAction;
  final String? actionLabel;

  const ConnectionRestoredSnackBar({
    Key? key,
    this.message,
    this.onAction,
    this.actionLabel,
  }) : super(key: key);

  @override
  State<ConnectionRestoredSnackBar> createState() =>
      _ConnectionRestoredSnackBarState();
}

class _ConnectionRestoredSnackBarState extends State<ConnectionRestoredSnackBar>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _slideAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _slideAnimation.value * 100),
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.green.withOpacity(0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
                border: Border.all(
                  color: Colors.green.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  // Icône de succès
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check_circle,
                      color: Colors.green,
                      size: 24,
                    ),
                  ),

                  const SizedBox(width: 12),

                  // Message
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'Connexion Rétablie !',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2D2D2D),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          widget.message ?? 'Internet disponible',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF666666),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Bouton d'action
                  if (widget.onAction != null && widget.actionLabel != null)
                    TextButton(
                      onPressed: widget.onAction,
                      child: Text(
                        widget.actionLabel!,
                        style: const TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Fonction utilitaire pour afficher le SnackBar
void showConnectionRestoredSnackBar(
  BuildContext context, {
  String? message,
  VoidCallback? onAction,
  String? actionLabel,
  Duration duration = const Duration(seconds: 3),
}) {
  final overlay = Overlay.of(context);
  late OverlayEntry overlayEntry;

  overlayEntry = OverlayEntry(
    builder: (context) => Positioned(
      top: MediaQuery.of(context).padding.top + 10,
      left: 0,
      right: 0,
      child: ConnectionRestoredSnackBar(
        message: message,
        onAction: onAction,
        actionLabel: actionLabel,
      ),
    ),
  );

  overlay.insert(overlayEntry);

  // Supprimer automatiquement après la durée spécifiée
  Future.delayed(duration, () {
    overlayEntry.remove();
  });
}
