import 'package:afietepatientapp/core/assets/icon_image_links.dart';
import 'package:afietepatientapp/core/constants/styles.dart';
import 'package:flutter/material.dart';

class CustomDoctorProfileImage extends StatelessWidget {
  final double height;
  final String? imageUrl;
  final String imagePath;

  const CustomDoctorProfileImage({
    super.key,
    required this.height,
    this.imageUrl,
    this.imagePath = ImageLinks.man1,
  });

  @override
  Widget build(BuildContext context) {
    final bool hasNetwork =
        imageUrl != null && imageUrl!.trim().startsWith('http');

    return Padding(
      padding: const EdgeInsets.all(AppStyles.padding / 3),
      child: ClipRRect(
        borderRadius: BorderRadius.all(
          Radius.circular(AppStyles.borderRadius),
        ),
        child: SizedBox(
          height: height,
          width: height,
          child: hasNetwork
              ? Image.network(
                  imageUrl!,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                      Image.asset(imagePath, fit: BoxFit.cover),
                )
              : Image.asset(imagePath, fit: BoxFit.cover),
        ),
      ),
    );
  }
}
