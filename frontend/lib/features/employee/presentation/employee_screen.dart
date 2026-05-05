import 'package:flutter/material.dart';
import 'package:shiftley_frontend/core/design_system/shiftley_tokens.dart';
import 'widgets/employee_sidebar.dart';
import 'views/overview_view.dart';
import 'views/explore_gigs_view.dart';
import 'views/my_gigs_view.dart';
import 'views/transactions_view.dart';
import 'views/profile_view.dart';
import 'views/support_view.dart';

enum EmployeeTab { overview, explore, myGigs, transactions, profile, support }

class EmployeeScreen extends StatefulWidget {
  const EmployeeScreen({super.key});

  @override
  State<EmployeeScreen> createState() => _EmployeeScreenState();
}

class _EmployeeScreenState extends State<EmployeeScreen> {
  EmployeeTab _activeTab = EmployeeTab.overview;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      behavior: HitTestBehavior.opaque,
      child: Scaffold(
        backgroundColor: ShiftleyTokens.background,
        appBar: _buildAppBar(),
        drawer: EmployeeSidebar(
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

  String _getTabTitle(EmployeeTab tab) {
    switch (tab) {
      case EmployeeTab.overview:
        return 'Professional Dashboard';
      case EmployeeTab.explore:
        return 'Explore Gigs';
      case EmployeeTab.myGigs:
        return 'My Shifts';
      case EmployeeTab.transactions:
        return 'Transactions';
      case EmployeeTab.profile:
        return 'My Profile';
      case EmployeeTab.support:
        return 'Support Hub';
    }
  }

  Widget _buildActiveView() {
    switch (_activeTab) {
      case EmployeeTab.overview:
        return const OverviewView();
      case EmployeeTab.explore:
        return const ExploreGigsView();
      case EmployeeTab.myGigs:
        return const MyGigsView();
      case EmployeeTab.transactions:
        return const TransactionsView();
      case EmployeeTab.profile:
        return const ProfileView();
      case EmployeeTab.support:
        return const SupportView();
    }
  }
}
