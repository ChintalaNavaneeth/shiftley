import 'package:flutter/material.dart';
import 'package:shiftley_frontend/core/design_system/shiftley_tokens.dart';
import 'package:shiftley_frontend/core/design_system/shiftley_button.dart';

class AnalyticsView extends StatefulWidget {
  const AnalyticsView({super.key});

  @override
  State<AnalyticsView> createState() => _AnalyticsViewState();
}

class _AnalyticsViewState extends State<AnalyticsView> {
  // Reduced font size by 15%
  double get _tableFontSizeSmall => (ShiftleyTokens.bodyMedium.fontSize ?? 14.0) * 0.85;
  double get _tableFontSizeLarge => (ShiftleyTokens.bodyLarge.fontSize ?? 16.0) * 0.85;
  double get _tableFontSizeHeader => 12.0 * 0.85;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Top Header & Actions ─────────────────────────────────────
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Statistics', style: ShiftleyTokens.h2),
            _buildDownloadDropdown(),
          ],
        ),
        const SizedBox(height: ShiftleyTokens.spaceXL),

        // ── System Summary Table ─────────────────────────────────────
        Text('System Overview', style: ShiftleyTokens.bodyLarge.copyWith(fontSize: _tableFontSizeLarge)),
        const SizedBox(height: ShiftleyTokens.spaceM),
        _buildSystemTable(),

        const SizedBox(height: ShiftleyTokens.spaceXL),

        // ── Financial Summary Table ──────────────────────────────────
        Text('Financial Summary', style: ShiftleyTokens.bodyLarge.copyWith(fontSize: _tableFontSizeLarge)),
        const SizedBox(height: ShiftleyTokens.spaceM),
        _buildFinancialTable(),

        const SizedBox(height: ShiftleyTokens.spaceXXL),

        // ── Charts & Breakdown ───────────────────────────────────────
        LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth < 800) {
              return Column(
                children: [
                  _buildChartCard(
                    title: 'Income vs Expenditure',
                    subtitle: 'Monthly overview of cash flow',
                    child: const _FinancialChart(),
                  ),
                  const SizedBox(height: ShiftleyTokens.spaceL),
                  _buildChartCard(
                    title: 'Expenditure Breakdown',
                    subtitle: 'Top spending categories',
                    child: _buildBreakdownList(),
                  ),
                ],
              );
            }
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 2,
                  child: _buildChartCard(
                    title: 'Income vs Expenditure',
                    subtitle: 'Monthly overview of cash flow',
                    child: const _FinancialChart(),
                  ),
                ),
                const SizedBox(width: ShiftleyTokens.spaceL),
                Expanded(
                  flex: 1,
                  child: _buildChartCard(
                    title: 'Expenditure Breakdown',
                    subtitle: 'Top spending categories',
                    child: _buildBreakdownList(),
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildSystemTable() {
    return Column(
      children: [
        _buildTableHeader(),
        _buildTableRow('Active Professionals', '1,248', '+54 today', true),
        _buildTableRow('Active Gigs', '342', '-12% yesterday', false),
        _buildTableRow('Verified Businesses', '128', '+2 this week', true),
      ],
    );
  }

  Widget _buildFinancialTable() {
    return Column(
      children: [
        _buildTableHeader(),
        _buildTableRow('Gross Income', '₹ 12,45,200', '+12.5%', true),
        _buildTableRow('Total Expenditure', '₹ 2,15,400', '+4.2%', false),
        _buildTableRow('Tax Deductions', '₹ 45,200', '+1.1%', false),
        const Divider(color: ShiftleyTokens.inkBlack, thickness: 1.0, height: 1),
        Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            children: [
              Expanded(
                flex: 3, 
                child: Text('ENTIRE TOTAL (NET)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: _tableFontSizeSmall)),
              ),
              _vDivider(),
              Expanded(
                flex: 2, 
                child: Padding(
                  padding: const EdgeInsets.only(left: 12),
                  child: Text('₹ 10,29,800', style: TextStyle(fontWeight: FontWeight.bold, fontSize: _tableFontSizeLarge, color: ShiftleyTokens.primaryRed)),
                ),
              ),
              _vDivider(),
              Expanded(
                flex: 2, 
                child: Padding(
                  padding: const EdgeInsets.only(left: 12),
                  child: Text('+18.3%', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: _tableFontSizeSmall)),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTableHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: const BoxDecoration(
        border: Border(
          top: BorderSide(color: ShiftleyTokens.background, width: 1.0),
          bottom: BorderSide(color: ShiftleyTokens.inkBlack, width: 1.5),
        ),
      ),
      child: Row(
        children: [
          Expanded(flex: 3, child: Text('METRIC', style: TextStyle(fontWeight: FontWeight.bold, fontSize: _tableFontSizeHeader))),
          _vDivider(),
          Expanded(flex: 2, child: Padding(padding: const EdgeInsets.only(left: 12), child: Text('VALUE', style: TextStyle(fontWeight: FontWeight.bold, fontSize: _tableFontSizeHeader)))),
          _vDivider(),
          Expanded(flex: 2, child: Padding(padding: const EdgeInsets.only(left: 12), child: Text('TREND', style: TextStyle(fontWeight: FontWeight.bold, fontSize: _tableFontSizeHeader)))),
        ],
      ),
    );
  }

  Widget _buildTableRow(String label, String value, String trend, bool isPositive) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: ShiftleyTokens.background, width: 1.0)),
      ),
      child: Row(
        children: [
          Expanded(flex: 3, child: Text(label, style: ShiftleyTokens.bodyMedium.copyWith(fontSize: _tableFontSizeSmall))),
          _vDivider(),
          Expanded(
            flex: 2, 
            child: Padding(
              padding: const EdgeInsets.only(left: 12),
              child: Text(value, style: ShiftleyTokens.bodyLarge.copyWith(fontWeight: FontWeight.bold, fontSize: _tableFontSizeSmall)),
            )
          ),
          _vDivider(),
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.only(left: 12),
              child: Text(
                trend,
                style: TextStyle(
                  color: isPositive ? Colors.green : ShiftleyTokens.primaryRed,
                  fontWeight: FontWeight.bold,
                  fontSize: _tableFontSizeSmall,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _vDivider() {
    return Container(
      width: 1,
      height: 24,
      color: ShiftleyTokens.background,
    );
  }

  Widget _buildDownloadDropdown() {
    return PopupMenuButton<String>(
      onSelected: (value) {},
      color: ShiftleyTokens.paperWhite,
      elevation: 4,
      offset: const Offset(0, 50),
      itemBuilder: (context) => [
        const PopupMenuItem(
          value: 'pdf',
          child: ListTile(
            leading: Icon(Icons.picture_as_pdf_outlined, size: 20),
            title: Text('Export as PDF', style: ShiftleyTokens.bodyMedium),
          ),
        ),
        const PopupMenuItem(
          value: 'excel',
          child: ListTile(
            leading: Icon(Icons.table_view_outlined, size: 20),
            title: Text('Export as Excel', style: ShiftleyTokens.bodyMedium),
          ),
        ),
      ],
      child: IgnorePointer(
        child: ShiftleyButton(
          label: 'Download Report',
          icon: Icons.download_outlined,
          onPressed: () {},
          isPrimary: false,
          size: ShiftleyButtonSize.medium,
        ),
      ),
    );
  }

  Widget _buildChartCard({required String title, required String subtitle, required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(ShiftleyTokens.spaceL),
      decoration: BoxDecoration(
        color: ShiftleyTokens.paperWhite,
        border: ShiftleyTokens.primaryBorder,
        borderRadius: BorderRadius.circular(ShiftleyTokens.borderRadiusVal),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: ShiftleyTokens.h2),
          Text(subtitle, style: ShiftleyTokens.caption),
          const SizedBox(height: ShiftleyTokens.spaceXL),
          SizedBox(height: 300, child: child),
        ],
      ),
    );
  }

  Widget _buildBreakdownList() {
    final categories = [
      {'label': 'Razorpay Fees', 'amount': '₹ 85,000', 'color': ShiftleyTokens.primaryRed},
      {'label': 'Server Costs', 'amount': '₹ 42,000', 'color': ShiftleyTokens.inkBlack},
      {'label': 'Marketing', 'amount': '₹ 65,400', 'color': ShiftleyTokens.utilityGrey},
      {'label': 'Support Ops', 'amount': '₹ 23,000', 'color': ShiftleyTokens.secondaryCyan},
    ];

    return Column(
      children: [
        Expanded(
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: categories.length,
            separatorBuilder: (_, __) => const SizedBox(height: ShiftleyTokens.spaceM),
            itemBuilder: (context, index) {
              final item = categories[index];
              return Row(
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(color: item['color'] as Color, shape: BoxShape.circle),
                  ),
                  const SizedBox(width: ShiftleyTokens.spaceM),
                  Expanded(child: Text(item['label'] as String, style: ShiftleyTokens.bodyMedium)),
                  Text(item['amount'] as String, style: ShiftleyTokens.bodyLarge),
                ],
              );
            },
          ),
        ),
        const Divider(height: ShiftleyTokens.spaceXL),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: const [
            Text('TOTAL', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            Text('₹ 2,15,400', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: ShiftleyTokens.primaryRed)),
          ],
        ),
      ],
    );
  }
}

class _FinancialChart extends StatelessWidget {
  const _FinancialChart();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(painter: _ChartPainter(), size: Size.infinite);
  }
}

class _ChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    const leftPadding = 40.0;
    const bottomPadding = 30.0;
    const topPadding = 20.0;
    final chartWidth = size.width - leftPadding;
    final chartHeight = size.height - bottomPadding - topPadding;
    final incomePaint = Paint()..color = ShiftleyTokens.primaryRed..style = PaintingStyle.stroke..strokeWidth = 3.0..strokeCap = StrokeCap.round;
    final expenditurePaint = Paint()..color = ShiftleyTokens.inkBlack..style = PaintingStyle.stroke..strokeWidth = 3.0..strokeCap = StrokeCap.round;
    final gridPaint = Paint()..color = ShiftleyTokens.utilityGrey.withOpacity(0.1)..strokeWidth = 1.0;
    for (int i = 0; i <= 5; i++) {
      final y = topPadding + chartHeight * (1 - i / 5);
      canvas.drawLine(Offset(leftPadding, y), Offset(size.width, y), gridPaint);
      _drawText(canvas, '${i * 200}k', Offset(5, y - 7), fontSize: 10);
    }
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul'];
    final stepX = chartWidth / (months.length - 1);
    for (int i = 0; i < months.length; i++) {
      final x = leftPadding + i * stepX;
      _drawText(canvas, months[i], Offset(x - 10, size.height - 20), fontSize: 10);
    }
    _drawPath(canvas, Offset(leftPadding, topPadding), Size(chartWidth, chartHeight), [0.2, 0.4, 0.3, 0.7, 0.5, 0.8, 0.9], incomePaint);
    _drawPath(canvas, Offset(leftPadding, topPadding), Size(chartWidth, chartHeight), [0.1, 0.2, 0.15, 0.3, 0.25, 0.35, 0.3], expenditurePaint);
    _drawLegend(canvas, Offset(leftPadding, 0));
  }
  void _drawLegend(Canvas canvas, Offset offset) {
    _drawLegendItem(canvas, offset, ShiftleyTokens.primaryRed, 'Income');
    _drawLegendItem(canvas, offset + const Offset(80, 0), ShiftleyTokens.inkBlack, 'Expenditure');
  }
  void _drawLegendItem(Canvas canvas, Offset offset, Color color, String label) {
    canvas.drawCircle(offset + const Offset(5, 5), 4, Paint()..color = color);
    _drawText(canvas, label, offset + const Offset(15, 0), fontSize: 12, fontWeight: FontWeight.bold);
  }
  void _drawText(Canvas canvas, String text, Offset offset, {double fontSize = 12, FontWeight fontWeight = FontWeight.normal}) {
    final tp = TextPainter(text: TextSpan(text: text, style: TextStyle(color: ShiftleyTokens.mutedText, fontSize: fontSize, fontWeight: fontWeight, fontFamily: 'Figtree')), textDirection: TextDirection.ltr)..layout();
    tp.paint(canvas, offset);
  }
  void _drawPath(Canvas canvas, Offset origin, Size size, List<double> points, Paint paint) {
    final path = Path();
    final stepX = size.width / (points.length - 1);
    for (int i = 0; i < points.length; i++) {
      final x = origin.dx + i * stepX;
      final y = origin.dy + size.height * (1 - points[i]);
      if (i == 0) path.moveTo(x, y); else path.lineTo(x, y);
    }
    canvas.drawPath(path, paint);
    final dotPaint = Paint()..color = paint.color;
    for (int i = 0; i < points.length; i++) {
      final x = origin.dx + i * stepX;
      final y = origin.dy + size.height * (1 - points[i]);
      canvas.drawCircle(Offset(x, y), 4, dotPaint);
      canvas.drawCircle(Offset(x, y), 2, Paint()..color = Colors.white);
    }
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
