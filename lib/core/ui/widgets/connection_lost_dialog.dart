import 'dart:async';
import 'package:flutter/material.dart';
import '../../services/connectivity_service.dart';

/// Dialog affiché lors de la perte de connexion
class ConnectionLostDialog extends StatefulWidget {
  final String? title;
  final String? message;
  final VoidCallback? onRetry;
  final VoidCallback? onSaveOffline;
  final bool showProgress;

  const ConnectionLostDialog({
    Key? key,
    this.title,
    this.message,
    this.onRetry,
    this.onSaveOffline,
    this.showProgress = true,
  }) : super(key: key);

  @override
  State<ConnectionLostDialog> createState() => _ConnectionLostDialogState();
}

class _ConnectionLostDialogState extends State<ConnectionLostDialog>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  bool _isRetrying = false;
  double _progress = 0.0;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _startConnectionCheck();
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    ));

    _animationController.forward();
  }

  void _startConnectionCheck() {
    // Écouter les changements de connexion
    ConnectivityService().connectionStream.listen((isConnected) {
      if (isConnected && mounted) {
        _onConnectionRestored();
      }
    });
  }

  void _onConnectionRestored() {
    setState(() {
      _isRetrying = true;
    });

    // Animation de progression
    _animateProgress();

    // Fermer le dialog après un délai
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        Navigator.of(context).pop(true); // true = connexion rétablie
      }
    });
  }

  void _animateProgress() {
    const steps = 100;
    const stepDuration = Duration(milliseconds: 20);

    Timer.periodic(stepDuration, (timer) {
      if (mounted) {
        setState(() {
          _progress += 1.0 / steps;
        });

        if (_progress >= 1.0) {
          timer.cancel();
        }
      } else {
        timer.cancel();
      }
    });
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
        return FadeTransition(
          opacity: _fadeAnimation,
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFFFFF3ED),
                      Color(0xFFFFE5D9),
                    ],
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Icône
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.wifi_off_rounded,
                        size: 40,
                        color: Color(0xFFF24E1E),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Titre
                    Text(
                      widget.title ?? 'Connexion Internet Perdue',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2D2D2D),
                      ),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 12),

                    // Message
                    Text(
                      widget.message ??
                          'Votre connexion internet a été interrompue.\nVos données sont sauvegardées localement.',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF666666),
                        height: 1.4,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 24),

                    // Progression de reconnexion
                    if (widget.showProgress && _isRetrying) ...[
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            const Text(
                              'Reconnexion en cours...',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF2D2D2D),
                              ),
                            ),
                            const SizedBox(height: 12),
                            LinearProgressIndicator(
                              value: _progress,
                              backgroundColor: Colors.grey.withOpacity(0.2),
                              valueColor: const AlwaysStoppedAnimation<Color>(
                                Color(0xFFF24E1E),
                              ),
                              minHeight: 6,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '${(_progress * 100).toInt()}%',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFF666666),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],

                    // Boutons d'action
                    if (!_isRetrying) ...[
                      Row(
                        children: [
                          // Bouton Réessayer
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () {
                                widget.onRetry?.call();
                                Navigator.of(context).pop(false);
                              },
                              icon: const Icon(Icons.refresh, size: 18),
                              label: const Text('Réessayer'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFF24E1E),
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                padding:
                                    const EdgeInsets.symmetric(vertical: 12),
                              ),
                            ),
                          ),

                          const SizedBox(width: 12),

                          // Bouton Sauvegarder
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () {
                                widget.onSaveOffline?.call();
                                Navigator.of(context).pop(false);
                              },
                              icon: const Icon(Icons.save, size: 18),
                              label: const Text('Sauvegarder'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: const Color(0xFFF24E1E),
                                side:
                                    const BorderSide(color: Color(0xFFF24E1E)),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                padding:
                                    const EdgeInsets.symmetric(vertical: 12),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Fonction utilitaire pour afficher le dialog
Future<bool?> showConnectionLostDialog(
  BuildContext context, {
  String? title,
  String? message,
  VoidCallback? onRetry,
  VoidCallback? onSaveOffline,
  bool showProgress = true,
}) {
  return showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (context) => ConnectionLostDialog(
      title: title,
      message: message,
      onRetry: onRetry,
      onSaveOffline: onSaveOffline,
      showProgress: showProgress,
    ),
  );
}
