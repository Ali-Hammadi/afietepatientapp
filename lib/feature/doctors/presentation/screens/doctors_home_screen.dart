import 'package:afiete/core/constants/settings_strings.dart';
import 'package:afiete/core/constants/styles.dart';
import 'package:afiete/feature/doctors/presentation/cubits/doctors_cubit.dart';
import 'package:afiete/feature/doctors/presentation/widgets/doctor_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class DoctorsHomeScreen extends StatefulWidget {
  const DoctorsHomeScreen({super.key});

  @override
  State<DoctorsHomeScreen> createState() => _DoctorsHomeScreenState();
}

class _DoctorsHomeScreenState extends State<DoctorsHomeScreen> {
  int? selectedSpecialtyId; // تعديل: تتبع التخصص عبر الـ ID بدلاً من النص
  String searchQuery = '';
  late TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    // جلب البيانات الأولية (التخصصات + الأطباء) عند فتح الشاشة
    context.read<DoctorsCubit>().initializeData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _selectSpecialty(int? specialtyId) {
    setState(() {
      selectedSpecialtyId = specialtyId;
    });

    if (specialtyId == null) {
      // إذا اختار "الكل" (null)، نطلب جلب كل الأطباء
      context.read<DoctorsCubit>().loadAllDoctors();
    } else {
      // تمرير الـ ID المباشر إلى الـ Cubit للفلترة في الباك اند
      context.read<DoctorsCubit>().loadDoctorsBySpecialty(specialtyId);
    }
  }

  List<dynamic> _filterDoctors(List<dynamic> doctors) {
    if (searchQuery.isEmpty) {
      return doctors;
    }

    final query = _normalizeSearchText(searchQuery);
    return doctors.where((doctor) {
      final name = _normalizeSearchText(doctor.name ?? '');
      final specialization = _normalizeSearchText(doctor.specialization ?? '');
      final localizedSpecialization = _normalizeSearchText(
        SettingsStrings.specialtyLabel(doctor.specialization ?? ''),
      );
      return name.contains(query) ||
          specialization.contains(query) ||
          localizedSpecialization.contains(query);
    }).toList();
  }

  String _normalizeSearchText(String text) {
    return text
        .toLowerCase()
        .replaceAll(RegExp(r'[\s\p{P}\p{S}]+', unicode: true), '')
        .replaceAll(RegExp(r'[^\p{L}\p{N}]+', unicode: true), '');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Column(
        children: [
          _buildSearchField(theme: theme),
          const Divider(),
          _buildSpecialtyChipsSection(),
          Expanded(
            child: BlocBuilder<DoctorsCubit, DoctorsState>(
              builder: _buildDoctorsState,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchField({required ThemeData theme}) {
    return Padding(
      padding: const EdgeInsets.all(AppStyles.padding),
      child: TextField(
        controller: _searchController,
        onChanged: (value) {
          setState(() {
            searchQuery = value;
          });
        },
        decoration: InputDecoration(
          hintText: SettingsStrings.searchExpertsHint,
          prefixIcon: const Icon(Icons.search),
          suffixIcon: searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    setState(() {
                      searchQuery = '';
                    });
                  },
                )
              : null,
          filled: true,
          fillColor: theme.cardColor,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppStyles.borderRadius),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: AppStyles.padding,
            vertical: AppStyles.padding / 2,
          ),
        ),
      ),
    );
  }

  Widget _buildSpecialtyChipsSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppStyles.padding,
        vertical: AppStyles.padding / 2,
      ),
      child: SizedBox(
        height: 45, // تحديد ارتفاع ثابت ومناسب للـ Chips لمنع مشاكل الـ Layout
        child: BlocBuilder<DoctorsCubit, DoctorsState>(
          builder: (context, state) {
            return ListView(
              scrollDirection: Axis.horizontal,
              children: _buildSpecialtyChips(state),
            );
          },
        ),
      ),
    );
  }

  Widget _buildDoctorsState(BuildContext context, DoctorsState state) {
    if (state is DoctorsLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state is DoctorsError) {
      return Center(child: Text(state.message));
    }

    if (state is DoctorsLoaded) {
      final filteredDoctors = _filterDoctors(state.doctors);

      if (filteredDoctors.isEmpty) {
        return Center(
          child: Text(
            searchQuery.isNotEmpty
                ? SettingsStrings.noDoctorsMatchSearch
                : SettingsStrings.noDoctorsFound,
          ),
        );
      }

      return ListView.builder(
        itemCount: filteredDoctors.length,
        padding: const EdgeInsets.only(bottom: AppStyles.padding),
        itemBuilder: (context, index) {
          return CustomDoctorCard(doctor: filteredDoctors[index]);
        },
      );
    }

    return const SizedBox.shrink();
  }

  List<Widget> _buildSpecialtyChips(DoctorsState state) {
    final List<Widget> chips = [];

    // 1. إضافة زر "الكل" الافتراضي دائماً في البداية
    final isAllSelected = selectedSpecialtyId == null;
    chips.add(
      SpecialtyChip(
        label: SettingsStrings.seeAll,
        isSelected: isAllSelected,
        onSelected: () => _selectSpecialty(null),
      ),
    );

    // 2. بناء بقية الأزرار ديناميكياً إذا تم تحميل التخصصات بنجاح من السيرفر
    if (state is DoctorsLoaded) {
      for (final specialty in state.specialties) {
        final isSelected = selectedSpecialtyId == specialty.id;
        chips.add(
          SpecialtyChip(
            label: specialty.name, // النص الظاهر لليوزر (مثل: الاكتئاب، القلق)
            isSelected: isSelected,
            onSelected: () =>
                _selectSpecialty(specialty.id), // التعامل الخلفي بالـ ID
          ),
        );
      }
    }

    return chips;
  }
}

class SpecialtyChip extends StatelessWidget {
  const SpecialtyChip({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onSelected,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onSelected;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppStyles.padding * 0.25),
      child: GestureDetector(
        onTap: isSelected ? null : onSelected,
        child: Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: AppStyles.padding),
          decoration: BoxDecoration(
            border: Border.all(color: colorScheme.primary, width: 1.5),
            borderRadius: BorderRadius.circular(AppStyles.borderRadius),
            color: isSelected
                ? colorScheme.primary
                : colorScheme.primaryContainer
                    .withAlpha(90), // تعديل متوافق مع نسخ فلاتر الحديثة
          ),
          child: Text(
            label,
            style: AppStyles.bodyMedium.copyWith(
              color: isSelected
                  ? colorScheme.onPrimary
                  : colorScheme.onSurfaceVariant,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }
}
