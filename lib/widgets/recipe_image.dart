import 'package:flutter/material.dart';

class RecipeImage extends StatelessWidget {
  const RecipeImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.cacheWidth,
    this.fit = BoxFit.cover,
  });

  final String imageUrl;
  final double? width;
  final double? height;
  final int? cacheWidth;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    return Image.network(
      imageUrl,
      width: width,
      height: height,
      fit: fit,
      cacheWidth: cacheWidth,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;

        final expectedTotalBytes = loadingProgress.expectedTotalBytes;
        final progress = expectedTotalBytes == null
            ? null
            : loadingProgress.cumulativeBytesLoaded / expectedTotalBytes;

        return SizedBox(
          width: width,
          height: height,
          child: Center(
            child: CircularProgressIndicator(value: progress, strokeWidth: 2),
          ),
        );
      },
      errorBuilder: (context, error, stackTrace) => Image.asset(
        'assets/images/placeholder.png',
        width: width,
        height: height,
        fit: fit,
      ),
    );
  }
}
