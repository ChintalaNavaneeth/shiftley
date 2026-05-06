import 'package:flutter/material.dart';
import 'package:shiftley_frontend/core/design_system/shiftley_tokens.dart';
import 'widgets/support_sidebar.dart';
import 'views/ticket_queue_view.dart';
import 'views/agent_settings_view.dart';
import 'package:shiftley_frontend/shared/widgets/s_refreshable.dart';

enum SupportTab { overview, history, settings }

class SupportAgentScreen extends StatefulWidget {
  const SupportAgentScreen({super.key});

  @override
  State<SupportAgentScreen> createState() => _SupportAgentScreenState();
}

class _SupportAgentScreenState extends State<SupportAgentScreen> {
  SupportTab _activeTab = SupportTab.overview;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      behavior: HitTestBehavior.opaque,
      child: Scaffold(
        backgroundColor: ShiftleyTokens.background,
        appBar: _buildAppBar(),
        drawer: SupportSidebar(
          activeTab: _activeTab,
          onTabChanged: (tab) {
            setState(() => _activeTab = tab);
            Navigator.pop(context);
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
        style: ShiftleyTokens.h1.copyWith(fontSize: 20),
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

  String _getTabTitle(SupportTab tab) {
    switch (tab) {
      case SupportTab.overview: return 'Support Overview';
      case SupportTab.history: return 'Ticket History';
      case SupportTab.settings: return 'Agent Settings';
    }
  }

  Widget _buildActiveView() {
    switch (_activeTab) {
      case SupportTab.overview: return const TicketQueueView(showResolved: false);
      case SupportTab.history: return const TicketQueueView(showResolved: true);
      case SupportTab.settings: return const AgentSettingsView();
    }
  }
}
