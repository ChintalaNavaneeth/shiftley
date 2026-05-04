import 'package:flutter/material.dart';
import 'package:shiftley_frontend/core/design_system/shiftley_tokens.dart';

class ProfileView extends StatelessWidget {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Manage your business profile and account details.', style: ShiftleyTokens.bodyMedium),
          const SizedBox(height: ShiftleyTokens.spaceXL),

          _buildProfileHeader(),
          const SizedBox(height: ShiftleyTokens.spaceXL),

          _buildDetailSection('Business Information', [
            _buildDetailItem('Legal Business Name', 'Taj Banjara Pvt Ltd'),
            _buildDetailItem('Trade Name', 'Taj Banjara'),
            _buildDetailItem('Business Type', 'Hospitality / Hotel'),
            _buildDetailItem('GST Number', '36AAAAA0000A1Z5'),
            _buildDetailItem('PAN Number', 'AAAAA0000A'),
          ]),
          
          const SizedBox(height: ShiftleyTokens.spaceXL),

          _buildDetailSection('Contact Information', [
            _buildDetailItem('Primary Contact', 'Rajesh Gupta'),
            _buildDetailItem('Designation', 'General Manager'),
            _buildDetailItem('Email', 'admin@tajbanjara.com'),
            _buildDetailItem('Phone', '+91 98765 43210'),
          ]),

          const SizedBox(height: ShiftleyTokens.spaceXL),

          _buildDetailSection('Operational Address', [
            _buildDetailItem('Address Line 1', 'Road No. 1, Banjara Hills'),
            _buildDetailItem('City', 'Hyderabad'),
            _buildDetailItem('State', 'Telangana'),
            _buildDetailItem('PIN Code', '500034'),
          ]),

          const SizedBox(height: ShiftleyTokens.spaceXL),

          _buildDetailSection('Bank Details', [
            _buildDetailItem('Account Holder', 'Taj Banjara Pvt Ltd'),
            _buildDetailItem('Bank Name', 'ICICI Bank'),
            _buildDetailItem('Account Number', '0011223344556677'),
            _buildDetailItem('IFSC Code', 'ICIC0000011'),
          ]),

          const SizedBox(height: ShiftleyTokens.spaceXL),

          _buildDetailSection('Uploaded Documents', [
            _buildDocumentItem('GST Certificate', 'gst_cert_36a.pdf'),
            _buildDocumentItem('PAN Card Copy', 'pan_card_taj.jpg'),
            _buildDocumentItem('FSSAI License', 'fssai_882.pdf'),
            _buildDocumentItem('Address Proof', 'utility_bill.pdf'),
          ]),

          const SizedBox(height: ShiftleyTokens.spaceXXL),
        ],
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Container(
      padding: const EdgeInsets.all(ShiftleyTokens.spaceL),
      decoration: BoxDecoration(
        color: ShiftleyTokens.paperWhite,
        border: ShiftleyTokens.primaryBorder,
        borderRadius: BorderRadius.circular(ShiftleyTokens.borderRadiusVal),
      ),
      child: Row(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: ShiftleyTokens.secondaryCyan,
              border: ShiftleyTokens.primaryBorder,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.business, size: 40, color: ShiftleyTokens.inkBlack),
          ),
          const SizedBox(width: ShiftleyTokens.spaceL),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Taj Banjara', style: ShiftleyTokens.h1),
                Text('Verified Employer', style: ShiftleyTokens.caption.copyWith(color: Colors.green, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text('Member since April 2024', style: ShiftleyTokens.caption),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailSection(String title, List<Widget> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: ShiftleyTokens.h2.copyWith(color: ShiftleyTokens.primaryRed)),
        const SizedBox(height: ShiftleyTokens.spaceM),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(ShiftleyTokens.spaceM),
          decoration: BoxDecoration(
            color: ShiftleyTokens.paperWhite,
            border: ShiftleyTokens.primaryBorder,
            borderRadius: BorderRadius.circular(ShiftleyTokens.borderRadiusVal),
          ),
          child: Column(children: items),
        ),
      ],
    );
  }

  Widget _buildDetailItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(flex: 2, child: Text(label, style: ShiftleyTokens.caption.copyWith(fontWeight: FontWeight.bold))),
          Expanded(flex: 3, child: Text(value, style: ShiftleyTokens.bodyMedium)),
        ],
      ),
    );
  }

  Widget _buildDocumentItem(String label, String fileName) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          const Icon(Icons.description_outlined, size: 20, color: ShiftleyTokens.mutedText),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: ShiftleyTokens.bodyMedium.copyWith(fontWeight: FontWeight.bold)),
                Text(fileName, style: ShiftleyTokens.caption),
              ],
            ),
          ),
          TextButton(
            onPressed: () {},
            child: const Text('VIEW', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.blue)),
          ),
        ],
      ),
    );
  }
}
