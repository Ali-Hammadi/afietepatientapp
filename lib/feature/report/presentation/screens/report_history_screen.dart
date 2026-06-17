import 'package:afiete/core/constants/settings_strings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/styles.dart';
import '../cubits/report_cubit.dart';
import '../widgets/report_card.dart';

class ReportHistoryScreen extends StatefulWidget {
  const ReportHistoryScreen({super.key});

  @override
  State<ReportHistoryScreen> createState() => _ReportHistoryScreenState();
}

class _ReportHistoryScreenState extends State<ReportHistoryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    context.read<ReportCubit>().loadReportsDashboard();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(SettingsStrings.reportIssueTitle),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(
                text: SettingsStrings.reportIssueTitle,
                icon: Icon(Icons.phonelink_setup)),
            Tab(
                text: SettingsStrings.reportDoctorTitle,
                icon: Icon(Icons.people_alt)),
          ],
        ),
      ),
      body: BlocBuilder<ReportCubit, ReportState>(
        builder: (context, state) {
          if (state is ReportsDashboardLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is ReportsError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(state.message,
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center),
              ),
            );
          } else if (state is ReportsDashboardLoaded) {
            return TabBarView(
              controller: _tabController,
              children: [
                // التاب الأول: بلاغات التطبيق التقنية والاقتراحات
                state.appReports.isEmpty
                    ? const Center(child: Text("لا توجد بلاغات تقنية سابقة."))
                    : ListView.builder(
                        padding: const EdgeInsets.all(AppStyles.padding),
                        itemCount: state.appReports.length =
                            state.appReports.length,
                        itemBuilder: (context, index) => CustomReportCard(
                          report: state.appReports[index],
                          onTap: () => _showDetailsBottomSheet(
                              context, state.appReports[index].content),
                        ),
                      ),

                // التاب الثاني: بلاغات سلوكية ضد مستخدمين آخرين بينهما جلسة
                state.userReports.isEmpty
                    ? const Center(
                        child: Text("لم تقم بتقديم أي شكوى سلوكية سابقة."))
                    : ListView.builder(
                        padding: const EdgeInsets.all(AppStyles.padding),
                        itemCount: state.userReports.length,
                        itemBuilder: (context, index) => CustomReportCard(
                          report: state.userReports[index],
                          onTap: () => _showDetailsBottomSheet(
                              context, state.userReports[index].content),
                        ),
                      ),
              ],
            );
          }
          return Center(child: Text(SettingsStrings.reportWillBeReviewed));
        },
      ),
    );
  }

  void _showDetailsBottomSheet(BuildContext context, String content) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(SettingsStrings.reportDetailsTitle,
                style: AppStyles.headingSmall),
            const SizedBox(height: 16),
            Text(content, style: AppStyles.bodyMedium),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(SettingsStrings.cancel)),
            )
          ],
        ),
      ),
    );
  }
}
