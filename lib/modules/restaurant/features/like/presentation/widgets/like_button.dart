import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:liya/core/providers.dart';
import 'package:liya/modules/restaurant/features/like/application/like_provider.dart';
import 'package:liya/modules/restaurant/features/like/domain/entities/liked_dish.dart';
import 'package:confetti/confetti.dart';
import 'dart:math' as math;

class LikeButton extends ConsumerStatefulWidget {
  final String dishId;
  final String userId;
  final String name;
  final String price;
  final String imageUrl;
  final String description;
  final bool sodas;

  const LikeButton({
    Key? key,
    required this.dishId,
    required this.userId,
    required this.name,
    required this.price,
    required this.imageUrl,
    required this.description,
    required this.sodas,
  }) : super(key: key);

  @override
  ConsumerState<LikeButton> createState() => _LikeButtonState();
}

class _LikeButtonState extends ConsumerState<LikeButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _scaleAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    );
    _confettiController =
        ConfettiController(duration: const Duration(milliseconds: 800));
  }

  @override
  void dispose() {
    _controller.dispose();
    _confettiController.dispose();
    super.dispose();
  }

  Future<void> _onLikePressed(bool isLiked, void Function() toggle) async {
    if (!isLiked) {
      await _controller.forward();
      _confettiController.play();
      await Future.delayed(const Duration(milliseconds: 200));
      await _controller.reverse();
    }
    toggle();
  }

  Path _starPath(Size size) {
    double w = size.width;
    double h = size.height;
    final path = Path();
    double cx = w / 2, cy = h / 2, r = w / 2;
    for (int i = 0; i < 5; i++) {
      double angle = (math.pi * 2 * i) / 5 - math.pi / 2;
      double x = cx + r * math.cos(angle);
      double y = cy + r * math.sin(angle);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
      angle += math.pi / 5;
      x = cx + r * 0.5 * math.cos(angle);
      y = cy + r * 0.5 * math.sin(angle);
      path.lineTo(x, y);
    }
    path.close();
    return path;
  }

  @override
  Widget build(BuildContext context) {
    final isLikedAsync = ref.watch(
        isDishLikedProvider((dishId: widget.dishId, userId: widget.userId)));
    final notifier = ref.read(likeProvider(widget.userId).notifier);

    return isLikedAsync.when(
      loading: () => Icon(Icons.favorite_border, color: Colors.grey, size: 24),
      error: (e, _) => Icon(Icons.error, color: Colors.red, size: 24),
      data: (isLiked) {
        return Stack(
          alignment: Alignment.center,
          children: [
            ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              shouldLoop: false,
              emissionFrequency: 0.7,
              numberOfParticles: 20,
              maxBlastForce: 20,
              minBlastForce: 10,
              gravity: 0.2,
              colors: const [
                Colors.redAccent,
                Colors.orange,
                Colors.pink,
                Colors.yellow,
                Colors.purple,
                Colors.blue,
                Colors.green,
              ],
              createParticlePath: _starPath,
            ),
            GestureDetector(
              onTap: () async {
                final dish = LikedDish(
                  id: widget.dishId,
                  restaurantId: widget.dishId,
                  userId: widget.userId,
                  name: widget.name,
                  price: double.parse(widget.price),
                  imageUrl: widget.imageUrl,
                  description: widget.description,
                  sodas: widget.sodas,
                  rating: 0.0,
                  likedAt: DateTime.now(),
                );
                await _onLikePressed(isLiked, () async {
                  await notifier.toggleLike(dish);
                  ref.invalidate(isDishLikedProvider(
                      (dishId: widget.dishId, userId: widget.userId)));
                  ref.invalidate(getLikedDishesProvider(widget.userId));
                });
              },
              child: AnimatedBuilder(
                animation: _scaleAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: isLiked ? 1.3 * _scaleAnimation.value + 0.7 : 1.0,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: isLiked
                            ? [
                                BoxShadow(
                                  color: Colors.redAccent.withOpacity(0.4),
                                  blurRadius: 16,
                                  spreadRadius: 2,
                                ),
                              ]
                            : [],
                      ),
                      child: Icon(
                        isLiked ? Icons.favorite : Icons.favorite_border,
                        color: isLiked ? Colors.redAccent : Colors.grey,
                        size: 30,
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}
