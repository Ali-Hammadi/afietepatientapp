import 'package:afiete/core/assets/icon_image_links.dart';
import 'package:afiete/core/constants/styles.dart';
import 'package:afiete/feature/doctors/domain/entities/doctor_entity.dart';
import 'package:flutter/material.dart';

class CustomDoctorProfileImage extends StatelessWidget {
  final double height;
  final DoctorEntity? doctor;
  final String imagePath;

  const CustomDoctorProfileImage({
    super.key,
    required this.height,
    this.doctor,
    this.imagePath = ImageLinks.man1,
  });

  @override
  Widget build(BuildContext context) {
    final bool hasNetwork = doctor != null &&
        doctor!.imageUrl != null &&
        doctor!.imageUrl!.trim().startsWith('http');

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
                  doctor!.imageUrl!,
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
