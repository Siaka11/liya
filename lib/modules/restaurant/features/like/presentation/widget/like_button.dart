import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../application/like_provider.dart';
import '../../domain/entities/liked_dish.dart';

class LikeButton extends ConsumerStatefulWidget {
  final LikedDish dish;
  final String userId;
  final VoidCallback? onLikeChanged;

  const LikeButton({
    Key? key,
    required this.dish,
    required this.userId,
    this.onLikeChanged,
  }) : super(key: key);

  @override
  ConsumerState<LikeButton> createState() => _LikeButtonState();
}

class _LikeButtonState extends ConsumerState<LikeButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _toggleLike() async {
    final isLiked = await ref
        .read(likeProvider(widget.userId).notifier)
        .isDishLiked(widget.dish.id);

    if (isLiked) {
      _controller.reverse();
    } else {
      _controller.forward();
    }

    await ref
        .read(likeProvider(widget.userId).notifier)
        .toggleLike(widget.dish);

    if (widget.onLikeChanged != null) {
      widget.onLikeChanged!();
    }
  }

  @override
  Widget build(BuildContext context) {
    final likeState = ref.watch(likeProvider(widget.userId));
    final isLiked = likeState.likedDishes.any((d) => d.id == widget.dish.id);

    if (isLiked && _controller.value == 0) {
      _controller.forward();
    } else if (!isLiked && _controller.value == 1) {
      _controller.reverse();
    }

    return ScaleTransition(
      scale: _scaleAnimation,
      child: IconButton(
        icon: Icon(
          isLiked ? Icons.favorite : Icons.favorite_border,
          color: isLiked ? Colors.red : Colors.grey,
        ),
        onPressed: _toggleLike,
      ),
    );
  }
}
