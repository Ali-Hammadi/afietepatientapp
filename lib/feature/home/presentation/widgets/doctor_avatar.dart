import 'package:afietepatientapp/core/assets/icon_image_links.dart';
import 'package:afietepatientapp/core/constants/styles.dart';
import 'package:flutter/material.dart';

class CustomDoctorAvatar extends StatelessWidget {
  final String imageUrl;

  const CustomDoctorAvatar({super.key, required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    final hasNetworkImage = imageUrl.trim().startsWith('http');

    return ClipRRect(
      borderRadius: BorderRadius.circular(AppStyles.borderRadius),
      child: SizedBox(
        height: 90,
        width: 90,
        child: hasNetworkImage
            ? Image.network(
                imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    Image.asset(ImageLinks.man1, fit: BoxFit.cover),
              )
            : Image.asset(ImageLinks.man1, fit: BoxFit.cover),
      ),
    );
  }
}
