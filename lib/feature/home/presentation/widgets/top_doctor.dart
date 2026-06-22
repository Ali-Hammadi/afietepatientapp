import 'package:afiete/core/constants/styles.dart';
import 'package:afiete/core/constants/settings_strings.dart';
import 'package:afiete/core/di/injection_container.dart';
import 'package:afiete/core/routes/app_route.dart';
import 'package:afiete/feature/doctors/domain/entites/doctor_entity.dart';
import 'package:afiete/feature/doctors/presentation/cubits/doctors_cubit.dart';
import 'package:afiete/feature/home/presentation/widgets/doctor_avatar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CustomTopDoctorsWidget extends StatefulWidget {
  final int? specialtyId;
  final List<DoctorEntity>?
      customDoctors; // 🔥 إضافة مصفوفة خارجية للأطباء القادمين من الفحص

  const CustomTopDoctorsWidget({
    super.key,
    this.specialtyId,
    this.customDoctors,
  });

  @override
  State<CustomTopDoctorsWidget> createState() => _CustomTopDoctorsWidgetState();
}

class _CustomTopDoctorsWidgetState extends State<CustomTopDoctorsWidget> {
  late final DoctorsCubit _doctorsCubit;

  @override
  void initState() {
    super.initState();
    _doctorsCubit = sl<DoctorsCubit>();
    // لا نطلب البيانات من السيرفر إذا كان لدينا أطباء جاهزون من نتيجة الفحص
    if (widget.customDoctors == null) {
      _loadDoctors(widget.specialtyId);
    }
  }

  @override
  void didUpdateWidget(CustomTopDoctorsWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.customDoctors == null &&
        oldWidget.specialtyId != widget.specialtyId) {
      _loadDoctors(widget.specialtyId);
    }
  }

  void _loadDoctors(int? specialtyId) {
    if (specialtyId != null) {
      _doctorsCubit.loadDoctorsBySpecialty(specialtyId);
    } else {
      _doctorsCubit.loadAllDoctors();
    }
  }

  @override
  void dispose() {
    _doctorsCubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 💡 إذا تم تمرير أطباء جاهزون من نتيجة الفحص، نعرضهم مباشرة دون الدخول في ممرات الـ Cubit
    if (widget.customDoctors != null) {
      return _buildDoctorsListView(widget.customDoctors!);
    }

    return BlocProvider.value(
      value: _doctorsCubit,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppStyles.padding),
        child: BlocBuilder<DoctorsCubit, DoctorsState>(
          builder: (context, state) {
            if (state is DoctorsLoading) {
              return const SizedBox(
                height: 180,
                child: Center(child: CircularProgressIndicator()),
              );
            }

            if (state is DoctorsError) {
              return SizedBox(
                height: 180,
                child: Center(child: Text(state.message)),
              );
            }

            if (state is DoctorsLoaded) {
              return _buildDoctorsListView(state.doctors);
            }

            return const SizedBox(
              height: 180,
              child: Center(child: CircularProgressIndicator()),
            );
          },
        ),
      ),
    );
  }

  // دالة مجمعة لبناء القائمة الأفقية لمنع تكرار الكود (DRY Principle)
  Widget _buildDoctorsListView(List<DoctorEntity> doctorsList) {
    final topDoctors = doctorsList.take(8).toList();

    if (topDoctors.isEmpty) {
      return SizedBox(
        height: 180,
        child: Center(
          child: Text(SettingsStrings.noDoctorsAvailable),
        ),
      );
    }

    return SizedBox(
      height: 200,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: topDoctors.length,
        padding:
            const EdgeInsets.symmetric(horizontal: AppStyles.padding * 0.5),
        itemBuilder: (context, index) {
          return CustomTopDoctorCard(doctor: topDoctors[index]);
        },
      ),
    );
  }
}

class CustomTopDoctorCard extends StatelessWidget {
  final DoctorEntity doctor;
  const CustomTopDoctorCard({super.key, required this.doctor});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(
          context,
          MyRoutes.doctorInfoScreen,
          arguments: doctor,
        );
      },
      child: Padding(
        padding:
            const EdgeInsets.symmetric(horizontal: AppStyles.padding * 0.5),
        child: Container(
          width: 130,
          padding: const EdgeInsets.all(AppStyles.padding * 0.75),
          decoration: BoxDecoration(
            border: Border.all(
                color: colorScheme.primary.withAlpha(80), width: 1.2),
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(AppStyles.borderRadius),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CustomDoctorAvatar(imageUrl: doctor.imageUrl),
              const SizedBox(height: 10),
              Text(
                doctor.name ?? '',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style:
                    AppStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                SettingsStrings.specialtyLabel(doctor.specialization),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: AppStyles.bodySmall
                    .copyWith(color: colorScheme.onSurfaceVariant),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
