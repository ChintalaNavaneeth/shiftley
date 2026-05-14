import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shiftley_frontend/core/design_system/shiftley_tokens.dart';
import 'package:shiftley_frontend/core/design_system/shiftley_button.dart';
import 'package:shiftley_frontend/features/employer/data/employer_repository.dart';
import 'package:shiftley_frontend/features/employer/domain/models/employer_models.dart';
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
            Navigator.pop(context);
          },
        ),
        body: SafeArea(
          child: _buildBody(dashboardAsync),
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

  // Tabs that need BOUNDED height (use Expanded, have their own internal scroll)
  bool _isBoundedTab(EmployerTab tab) =>
      tab == EmployerTab.shifts || tab == EmployerTab.post;

  Widget _buildBody(AsyncValue<EmployerDashboardData> dashboardAsync) {
    if (_isBoundedTab(_activeTab)) {
      // Render directly in a Column > Expanded so height is bounded
      return Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(ShiftleyTokens.spaceM),
              child: _buildActiveView(dashboardAsync),
            ),
          ),
        ],
      );
    }
    // For scrollable tabs, use SRefreshable
    return SRefreshable(
      onRefresh: () async => ref.refresh(employerDashboardProvider.future),
      child: Padding(
        padding: const EdgeInsets.all(ShiftleyTokens.spaceM),
        child: _buildActiveView(dashboardAsync),
      ),
    );
  }

  Widget _buildActiveView(AsyncValue<EmployerDashboardData> dashboardAsync) {
    switch (_activeTab) {
      case EmployerTab.overview:
        return OverviewView(
          onPostGig: () => setState(() => _activeTab = EmployerTab.post),
          onGoToSubscription: () => setState(() => _activeTab = EmployerTab.subscription),
        );
      case EmployerTab.shifts:
        return ManageGigsView(
          onGoToSubscription: () => setState(() => _activeTab = EmployerTab.subscription),
        );
      case EmployerTab.post:
        return dashboardAsync.when(
          loading: () => const Center(child: CircularProgressIndicator(color: ShiftleyTokens.primaryRed)),
          error: (err, stack) => Center(child: Text('Error: $err')),
          data: (EmployerDashboardData data) {
            final bool isVerified = data.profile.verificationStatus == 'VERIFIED';
            final bool hasSubscription = data.stats.activePlan != 'NONE' && data.stats.freeGigsRemaining > 0;
            
            if (!isVerified) {
              return _buildLockScreen(
                Icons.verified_user_outlined,
                'Verification Required', 
                'Your business profile is currently under review. A verifier will visit your location shortly. Once verified, you can start posting GIGs.'
              );
            }
            if (!hasSubscription) {
              return _buildLockScreen(
                Icons.card_membership_outlined,
                'Subscription Active Required', 
                'You have either used all your gig posts or don\'t have an active plan. Please purchase a plan in the Subscription tab to continue.',
                actionLabel: 'GO TO SUBSCRIPTION',
                onAction: () => setState(() => _activeTab = EmployerTab.subscription),
              );
            }
            
            return PostGigView(
              onPublished: () => setState(() => _activeTab = EmployerTab.shifts),
            );
          },
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

  Widget _buildLockScreen(IconData icon, String title, String message, {String? actionLabel, VoidCallback? onAction}) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(ShiftleyTokens.spaceXL),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(ShiftleyTokens.spaceL),
              decoration: BoxDecoration(
                color: ShiftleyTokens.background,
                border: ShiftleyTokens.primaryBorder,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 64, color: ShiftleyTokens.primaryRed),
            ),
            const SizedBox(height: ShiftleyTokens.spaceXL),
            Text(title, style: ShiftleyTokens.h1, textAlign: TextAlign.center),
            const SizedBox(height: ShiftleyTokens.spaceM),
            Text(
              message,
              style: ShiftleyTokens.bodyLarge.copyWith(color: ShiftleyTokens.mutedText),
              textAlign: TextAlign.center,
            ),
            if (actionLabel != null) ...[
              const SizedBox(height: ShiftleyTokens.spaceXXL),
              ShiftleyButton(
                label: actionLabel,
                onPressed: onAction ?? () {},
                isFullWidth: true,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
