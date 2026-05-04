import 'package:flutter/material.dart';
import 'package:shiftley_frontend/core/design_system/shiftley_tokens.dart';
import 'widgets/employer_sidebar.dart';
import 'views/overview_view.dart';
import 'views/manage_shifts_view.dart';
import 'views/post_shift_view.dart';
import 'views/subscription_view.dart';
import 'views/profile_view.dart';

enum EmployerTab { overview, shifts, post, subscription, profile }

class EmployerScreen extends StatefulWidget {
  const EmployerScreen({super.key});

  @override
  State<EmployerScreen> createState() => _EmployerScreenState();
}

class _EmployerScreenState extends State<EmployerScreen> {
  EmployerTab _activeTab = EmployerTab.overview;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ShiftleyTokens.background,
      resizeToAvoidBottomInset: false,
      appBar: _buildAppBar(),
      drawer: EmployerSidebar(
        activeTab: _activeTab,
        onTabChanged: (tab) {
          setState(() => _activeTab = tab);
          Navigator.pop(context); // Close drawer on selection
        },
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(ShiftleyTokens.spaceM),
          child: _buildActiveView(),
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

  String _getTabTitle(EmployerTab tab) {
    switch (tab) {
      case EmployerTab.overview:
        return 'Taj Banjara';
      case EmployerTab.shifts:
        return 'Manage GIGS';
      case EmployerTab.post:
        return 'Post a GIG';
      case EmployerTab.subscription:
        return 'Subscription';
      case EmployerTab.profile:
        return 'Business Profile';
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
    }
  }
}
