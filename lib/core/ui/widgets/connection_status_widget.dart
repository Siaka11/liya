import 'package:flutter/material.dart';
import '../../services/connectivity_service.dart';
import '../../services/connection_manager.dart';

/// Widget affichant le statut de connexion
class ConnectionStatusWidget extends StatefulWidget {
  final bool showWhenConnected;
  final bool showWhenDisconnected;
  final Widget? customDisconnectedWidget;
  final Widget? customConnectedWidget;

  const ConnectionStatusWidget({
    Key? key,
    this.showWhenConnected = false,
    this.showWhenDisconnected = true,
    this.customDisconnectedWidget,
    this.customConnectedWidget,
  }) : super(key: key);

  @override
  State<ConnectionStatusWidget> createState() => _ConnectionStatusWidgetState();
}

class _ConnectionStatusWidgetState extends State<ConnectionStatusWidget>
    with TickerProviderStateMixin {
  final ConnectivityService _connectivityService = ConnectivityService();
  final ConnectionManager _connectionManager = ConnectionManager();
  bool _isConnected = true;
  bool _isTesting = false;
  late AnimationController _animationController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _listenToConnectivity();
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(
      begin: 0.8,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _animationController.repeat(reverse: true);
  }

  void _listenToConnectivity() {
    _connectivityService.connectionStream.listen((isConnected) {
      if (mounted) {
        setState(() {
          _isConnected = isConnected;
        });
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
    // Ne rien afficher si connecté et showWhenConnected est false
    if (_isConnected && !widget.showWhenConnected) {
      return const SizedBox.shrink();
    }

    // Ne rien afficher si déconnecté et showWhenDisconnected est false
    if (!_isConnected && !widget.showWhenDisconnected) {
      return const SizedBox.shrink();
    }

    if (_isConnected) {
      return widget.customConnectedWidget ?? _buildConnectedWidget();
    } else {
      return widget.customDisconnectedWidget ?? _buildDisconnectedWidget();
    }
  }

  Widget _buildConnectedWidget() {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _pulseAnimation.value,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.green.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.wifi,
                  size: 16,
                  color: Colors.green[600],
                ),
                const SizedBox(width: 4),
                Text(
                  'En ligne',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.green[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDisconnectedWidget() {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _pulseAnimation.value,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.red.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.wifi_off,
                  size: 16,
                  color: Colors.red[600],
                ),
                const SizedBox(width: 4),
                Text(
                  'Hors ligne',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.red[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 8),
                // Bouton de test pour les émulateurs
                GestureDetector(
                  onTap: _isTesting ? null : _testConnectivity,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: Colors.blue.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: _isTesting
                        ? SizedBox(
                            width: 12,
                            height: 12,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.blue[600]!),
                            ),
                          )
                        : Icon(
                            Icons.refresh,
                            size: 12,
                            color: Colors.blue[600],
                          ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Tester la connectivité (utile pour les émulateurs)
  Future<void> _testConnectivity() async {
    setState(() {
      _isTesting = true;
    });

    try {
      await _connectionManager.forceConnectivityCheck();

      // Attendre un peu pour voir le résultat
      await Future.delayed(const Duration(seconds: 1));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _connectionManager.isConnected
                  ? 'Connexion détectée !'
                  : 'Aucune connexion détectée',
            ),
            backgroundColor:
                _connectionManager.isConnected ? Colors.green : Colors.red,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur de test: $e'),
            backgroundColor: Colors.orange,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isTesting = false;
        });
      }
    }
  }
}

/// Widget de statut de connexion compact pour la barre d'état
class CompactConnectionStatus extends StatelessWidget {
  const CompactConnectionStatus({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<bool>(
      stream: ConnectivityService().connectionStream,
      initialData: true,
      builder: (context, snapshot) {
        final isConnected = snapshot.data ?? true;

        return Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: isConnected ? Colors.green : Colors.red,
            shape: BoxShape.circle,
          ),
        );
      },
    );
  }
}

/// Widget de statut de connexion pour les pages
class PageConnectionStatus extends StatelessWidget {
  final Widget child;
  final bool showStatusBar;

  const PageConnectionStatus({
    Key? key,
    required this.child,
    this.showStatusBar = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (showStatusBar)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: const Color(0xFFFFF3ED),
            child: ConnectionStatusWidget(
              showWhenConnected: false,
              showWhenDisconnected: true,
            ),
          ),
        Expanded(child: child),
      ],
    );
  }
}
