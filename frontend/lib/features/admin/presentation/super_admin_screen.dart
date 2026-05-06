import 'package:flutter/material.dart';
import 'package:shiftley_frontend/core/design_system/shiftley_tokens.dart';
import 'widgets/admin_sidebar.dart';
import 'package:shiftley_frontend/shared/widgets/s_refreshable.dart';
import 'views/overview_view.dart';
import 'views/user_management_view.dart';
import 'views/config_view.dart';
import 'views/dispute_view.dart';
import 'views/analytics_view.dart';
import 'views/taxonomy_view.dart';
import 'views/settings_view.dart';

class SuperAdminScreen extends StatefulWidget {
  const SuperAdminScreen({super.key});

  @override
  State<SuperAdminScreen> createState() => _SuperAdminScreenState();
}

class _SuperAdminScreenState extends State<SuperAdminScreen> {
  AdminTab _activeTab = AdminTab.overview;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      behavior: HitTestBehavior.opaque,
      child: Scaffold(
        backgroundColor: ShiftleyTokens.background,
        appBar: _buildAppBar(),
        drawer: AdminSidebar(
          activeTab: _activeTab,
          onTabChanged: (tab) {
            setState(() => _activeTab = tab);
            Navigator.pop(context); // Close drawer on selection
          },
        ),
        body: SafeArea(
          child: SRefreshable(
            onRefresh: () async {
              await Future.delayed(const Duration(seconds: 1));
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

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: ShiftleyTokens.paperWhite,
      elevation: 0,
      iconTheme: const IconThemeData(color: ShiftleyTokens.inkBlack),
      title: Text(
        _getTabTitle(_activeTab),
        style: ShiftleyTokens.h1,
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

  String _getTabTitle(AdminTab tab) {
    switch (tab) {
      case AdminTab.overview:
        return 'Overview';
      case AdminTab.users:
        return 'Users';
      case AdminTab.config:
        return 'Config';
      case AdminTab.taxonomy:
        return 'Taxonomy';
      case AdminTab.disputes:
        return 'Disputes';
      case AdminTab.analytics:
        return 'Insights';
      case AdminTab.settings:
        return 'System Settings';
    }
  }

  Widget _buildActiveView() {
    switch (_activeTab) {
      case AdminTab.overview:
        return const OverviewView();
      case AdminTab.users:
        return const UserManagementView();
      case AdminTab.config:
        return const ConfigView();
      case AdminTab.taxonomy:
        return const TaxonomyView();
      case AdminTab.disputes:
        return const DisputeView();
      case AdminTab.analytics:
        return const AnalyticsView();
      case AdminTab.settings:
        return const SettingsView();
    }
  }
}

