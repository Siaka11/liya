import 'package:flutter/material.dart';
import 'dart:io';

/// Widget personnalisé pour afficher des images avec une orientation fixe
/// Résout les problèmes d'orientation sur certains appareils Android
class OrientationFixedImage extends StatelessWidget {
  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final Widget? errorWidget;
  final Widget? placeholder;

  const OrientationFixedImage({
    Key? key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.errorWidget,
    this.placeholder,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Image.network(
      imageUrl,
      width: width,
      height: height,
      fit: fit,
      // Forcer l'orientation sur Android
      frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
        if (wasSynchronouslyLoaded) return child;
        return AnimatedOpacity(
          opacity: frame == null ? 0 : 1,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
          child: child,
        );
      },
      errorBuilder: (context, error, stackTrace) {
        return errorWidget ??
            Container(
              color: Colors.grey[300],
              child: Icon(
                Icons.error,
                size: 50,
                color: Colors.grey[600],
              ),
            );
      },
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return placeholder ??
            Container(
              color: Colors.grey[200],
              child: Center(
                child: CircularProgressIndicator(
                  value: loadingProgress.expectedTotalBytes != null
                      ? loadingProgress.cumulativeBytesLoaded /
                          loadingProgress.expectedTotalBytes!
                      : null,
                ),
              ),
            );
      },
      // Propriétés pour éviter les problèmes d'orientation
      alignment: Alignment.center,
      repeat: ImageRepeat.noRepeat,
      centerSlice: null,
      matchTextDirection: false,
      gaplessPlayback: true,
      filterQuality: FilterQuality.medium,
    );
  }
}

/// Widget pour les images de fond avec overlay
class BackgroundImageWithOverlay extends StatelessWidget {
  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final Color overlayColor;
  final double overlayOpacity;
  final Widget? errorWidget;

  const BackgroundImageWithOverlay({
    Key? key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.overlayColor = Colors.black,
    this.overlayOpacity = 0.3,
    this.errorWidget,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Image de fond
        Positioned.fill(
          child: ClipRect(
            child: OrientationFixedImage(
              imageUrl: imageUrl,
              width: width,
              height: height,
              fit: fit,
              errorWidget: errorWidget,
            ),
          ),
        ),
        // Overlay
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              color: overlayColor.withOpacity(overlayOpacity),
            ),
          ),
        ),
      ],
    );
  }
}
