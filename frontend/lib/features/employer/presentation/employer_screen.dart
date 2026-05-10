import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shiftley_frontend/core/design_system/shiftley_tokens.dart';
import 'package:shiftley_frontend/features/employer/data/employer_repository.dart';
import 'widgets/employer_sidebar.dart';
import 'package:shiftley_frontend/shared/widgets/s_refreshable.dart';
import 'views/overview_view.dart';
import 'views/manage_shifts_view.dart';
import 'views/post_shift_view.dart';
import 'views/subscription_view.dart';
import 'views/profile_view.dart';
import 'views/support_view.dart';
import 'views/faq_view.dart';
import 'views/settings_view.dart';

enum EmployerTab { overview, shifts, post, subscription, profile, support, faq, settings }

class EmployerScreen extends ConsumerStatefulWidget {
  const EmployerScreen({super.key});

  @override
  ConsumerState<EmployerScreen> createState() => _EmployerScreenState();
}

class _EmployerScreenState extends ConsumerState<EmployerScreen> {
  EmployerTab _activeTab = EmployerTab.overview;

  @override
  Widget build(BuildContext context) {
    final dashboardAsync = ref.watch(employerDashboardProvider);
    final businessName = dashboardAsync.when(
      data: (data) => data.profile.businessName,
      loading: () => null,
      error: (err, stack) => null,
    );

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      behavior: HitTestBehavior.opaque,
      child: Scaffold(
        backgroundColor: ShiftleyTokens.background,
        appBar: _buildAppBar(businessName),
        drawer: EmployerSidebar(
          activeTab: _activeTab,
          onTabChanged: (tab) {
            setState(() => _activeTab = tab);
            Navigator.pop(context); // Close drawer on selection
          },
        ),
        body: SafeArea(
          child: SRefreshable(
            onRefresh: () async {
              // Refresh dashboard data
              return ref.refresh(employerDashboardProvider.future);
            },
            child: Padding(
              padding: const EdgeInsets.all(ShiftleyTokens.spaceM),
              child: _buildActiveView(),
            ),
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(String? businessName) {
    return AppBar(
      backgroundColor: ShiftleyTokens.paperWhite,
      elevation: 0,
      iconTheme: const IconThemeData(color: ShiftleyTokens.inkBlack),
      title: Text(
        _getTabTitle(_activeTab, businessName),
        style: ShiftleyTokens.h1.copyWith(fontSize: ShiftleyTokens.h1.fontSize! * 0.8),
        overflow: TextOverflow.ellipsis,
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.notifications_none),
          onPressed: () {},
        ),
        const SizedBox(width: ShiftleyTokens.spaceM),
      ],
      bottom: const PreferredSize(
        preferredSize: Size.fromHeight(2),
        child: Divider(height: 2, thickness: 2, color: ShiftleyTokens.inkBlack),
      ),
    );
  }

  String _getTabTitle(EmployerTab tab, String? businessName) {
    switch (tab) {
      case EmployerTab.overview:
        return businessName ?? 'Dashboard';
      case EmployerTab.shifts:
        return 'Manage GIGS';
      case EmployerTab.post:
        return 'Post a GIG';
      case EmployerTab.subscription:
        return 'Subscription';
      case EmployerTab.profile:
        return 'Business Profile';
      case EmployerTab.support:
        return 'Customer Support';
      case EmployerTab.faq:
        return 'Help & FAQ';
      case EmployerTab.settings:
        return 'Business Settings';
    }
  }

  Widget _buildActiveView() {
    switch (_activeTab) {
      case EmployerTab.overview:
        return const OverviewView();
      case EmployerTab.shifts:
        return const ManageGigsView();
      case EmployerTab.post:
        return PostGigView(
          onPublished: () => setState(() => _activeTab = EmployerTab.shifts),
        );
      case EmployerTab.subscription:
        return const SubscriptionView();
      case EmployerTab.profile:
        return const ProfileView();
      case EmployerTab.support:
        return const SupportView();
      case EmployerTab.faq:
        return const FAQView();
      case EmployerTab.settings:
        return const SettingsView();
    }
  }
}
