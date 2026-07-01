import 'package:afiete/core/constants/styles.dart';
import 'package:afiete/core/ln10/settings_strings.dart';
import 'package:afiete/feature/report/presentation/cubits/report_cubit.dart';
import 'package:afiete/feature/report/presentation/widgets/report_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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
    _loadData();
  }

  Future<void> _loadData() async {
    if (!mounted) return;
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
              icon: const Icon(Icons.phonelink_setup),
            ),
            Tab(
              text: SettingsStrings.reportDoctorTitle,
              icon: const Icon(Icons.people_alt),
            ),
          ],
        ),
      ),
      body: BlocConsumer<ReportCubit, ReportState>(
        listener: (context, state) {},
        builder: (context, state) {
          if (state is ReportsDashboardLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is ReportsError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 64,
                      color: Colors.red,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      state.message,
                      style: const TextStyle(color: Colors.red),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: _loadData,
                      icon: const Icon(Icons.refresh),
                      label: Text(SettingsStrings.retry),
                    ),
                  ],
                ),
              ),
            );
          } else if (state is ReportsDashboardLoaded) {
            return RefreshIndicator(
              onRefresh: _loadData,
              child: TabBarView(
                controller: _tabController,
                children: [
                  state.appReports.isEmpty
                      ? Center(child: Text(SettingsStrings.noReports))
                      : ListView.builder(
                          padding: const EdgeInsets.all(AppStyles.padding),
                          itemCount: state.appReports.length,
                          itemBuilder: (context, index) => CustomReportCard(
                            report: state.appReports[index],
                            onTap: () => _showDetailsBottomSheet(
                              context,
                              state.appReports[index].description,
                            ),
                          ),
                        ),
                  state.userReports.isEmpty
                      ? Center(child: Text(SettingsStrings.noUserReports))
                      : ListView.builder(
                          padding: const EdgeInsets.all(AppStyles.padding),
                          itemCount: state.userReports.length,
                          itemBuilder: (context, index) => CustomReportCard(
                            report: state.userReports[index],
                            onTap: () => _showDetailsBottomSheet(
                              context,
                              state.userReports[index].description,
                            ),
                          ),
                        ),
                ],
              ),
            );
          }
          return Center(child: Text(SettingsStrings.noReports));
        },
      ),
    );
  }

  void _showDetailsBottomSheet(BuildContext context, String content) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              SettingsStrings.reportDetailsTitle,
              style: AppStyles.headingSmall,
            ),
            const SizedBox(height: 16),
            Text(content, style: AppStyles.bodyMedium),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: Text(SettingsStrings.cancel),
              ),
            )
          ],
        ),
      ),
    );
  }
}
