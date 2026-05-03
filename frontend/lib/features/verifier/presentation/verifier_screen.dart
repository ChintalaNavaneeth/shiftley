import 'package:flutter/material.dart';
import 'package:shiftley_frontend/core/design_system/shiftley_tokens.dart';

class VerifierScreen extends StatefulWidget {
  const VerifierScreen({super.key});

  @override
  State<VerifierScreen> createState() => _VerifierScreenState();
}

class _VerifierScreenState extends State<VerifierScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ShiftleyTokens.background,
      appBar: AppBar(
        title: const Text('Verifier Dashboard', style: ShiftleyTokens.h2),
        backgroundColor: ShiftleyTokens.paperWhite,
        elevation: 0,
        centerTitle: false,
        iconTheme: const IconThemeData(color: ShiftleyTokens.inkBlack), // Ensure hamburger is black
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.refresh)),
        ],
      ),
      drawer: _buildDrawer(), // Hamburger Menu
      body: Column(
        children: [
          _buildStatusTabs(),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(ShiftleyTokens.spaceM),
              children: [
                _buildQueueItem(
                  name: 'Taj Banjara',
                  type: 'Employer',
                  details: 'Physical Visit Required',
                  status: 'Pending',
                  icon: Icons.business_outlined,
                ),
                _buildQueueItem(
                  name: 'Suresh Kumar',
                  type: 'Professional',
                  details: 'Aadhaar Review',
                  status: 'Pending',
                  icon: Icons.person_outline,
                ),
                _buildQueueItem(
                  name: 'Zomato Kitchen',
                  type: 'Employer',
                  details: 'Physical Visit Required',
                  status: 'In Progress',
                  icon: Icons.business_outlined,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      backgroundColor: ShiftleyTokens.paperWhite,
      child: Column(
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(color: ShiftleyTokens.inkBlack),
            child: Center(
              child: Text(
                'Shiftley.',
                style: TextStyle(
                  fontFamily: 'Figtree',
                  fontSize: 32,
                  fontWeight: FontWeight.w900,
                  color: ShiftleyTokens.paperWhite,
                ),
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.queue_outlined),
            title: const Text('Verification Queue'),
            onTap: () => Navigator.pop(context),
          ),
          ListTile(
            leading: const Icon(Icons.history_outlined),
            title: const Text('Verification History'),
            onTap: () => Navigator.pop(context),
          ),
          const Spacer(),
          ListTile(
            leading: const Icon(Icons.logout, color: ShiftleyTokens.primaryRed),
            title: const Text('Logout', style: TextStyle(color: ShiftleyTokens.primaryRed)),
            onTap: () => Navigator.pop(context),
          ),
          const SizedBox(height: ShiftleyTokens.spaceL),
        ],
      ),
    );
  }

  Widget _buildStatusTabs() {
    return Container(
      width: double.infinity,
      color: ShiftleyTokens.paperWhite,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal, // Prevents horizontal overflow
        padding: const EdgeInsets.symmetric(horizontal: ShiftleyTokens.spaceM),
        child: Row(
          children: [
            _buildTab('Pending (12)', true),
            _buildTab('In Progress (3)', false),
            _buildTab('Completed (45)', false),
          ],
        ),
      ),
    );
  }

  Widget _buildTab(String label, bool isActive) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: ShiftleyTokens.spaceM, vertical: ShiftleyTokens.spaceM),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: isActive ? ShiftleyTokens.primaryRed : Colors.transparent,
            width: 2,
          ),
        ),
      ),
      child: Text(
        label,
        style: ShiftleyTokens.bodyMedium.copyWith(
          color: isActive ? ShiftleyTokens.inkBlack : ShiftleyTokens.mutedText,
          fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }

  Widget _buildQueueItem({
    required String name,
    required String type,
    required String details,
    required String status,
    required IconData icon,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isMobile = constraints.maxWidth < 450;

        return Container(
          margin: const EdgeInsets.only(bottom: ShiftleyTokens.spaceM),
          padding: const EdgeInsets.all(ShiftleyTokens.spaceM),
          decoration: BoxDecoration(
            color: ShiftleyTokens.paperWhite,
            border: ShiftleyTokens.primaryBorder,
            borderRadius: BorderRadius.circular(ShiftleyTokens.borderRadiusVal),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(ShiftleyTokens.spaceS),
                    decoration: const BoxDecoration(
                      color: ShiftleyTokens.secondaryCyan,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(icon, color: ShiftleyTokens.inkBlack, size: 20),
                  ),
                  const SizedBox(width: ShiftleyTokens.spaceM),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: ShiftleyTokens.bodyLarge,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                        Text(
                          '$type • $details',
                          style: ShiftleyTokens.caption,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ],
                    ),
                  ),
                  if (!isMobile) ...[
                    const SizedBox(width: ShiftleyTokens.spaceM),
                    _buildVerifyButton(),
                  ],
                ],
              ),
              if (isMobile) ...[
                const SizedBox(height: ShiftleyTokens.spaceM),
                SizedBox(
                  width: double.infinity,
                  child: _buildVerifyButton(),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildVerifyButton() {
    return ElevatedButton(
      onPressed: () {
        // Open Verification Flow
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: ShiftleyTokens.inkBlack,
        foregroundColor: ShiftleyTokens.paperWhite,
        padding: const EdgeInsets.symmetric(horizontal: ShiftleyTokens.spaceM),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(ShiftleyTokens.borderRadiusVal),
        ),
      ),
      child: const Text('Verify'),
    );
  }
}
