import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:shiftley_frontend/core/design_system/shiftley_tokens.dart';
import 'package:shiftley_frontend/core/design_system/shiftley_button.dart';
import '../../domain/admin_models.dart';
import '../providers/admin_providers.dart';

class AnalyticsView extends ConsumerWidget {
  const AnalyticsView({super.key});

  // Reduced font size by another 10% (cumulative ~25%)
  double get _tableFontSizeSmall => (ShiftleyTokens.bodyMedium.fontSize ?? 14.0) * 0.76;
  double get _tableFontSizeHeader => 12.0 * 0.76;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final overviewAsync = ref.watch(analyticsOverviewProvider);
    final financialsAsync = ref.watch(financialMetricsProvider);
    final liquidityAsync = ref.watch(liquidityProvider);
    final healthAsync = ref.watch(platformHealthProvider);
    final pnlAsync = ref.watch(pnlProvider(DateFormat('yyyy-MM').format(DateTime.now())));

    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: ShiftleyTokens.spaceXXL),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Top Header & Actions ─────────────────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              _buildDownloadDropdown(),
            ],
          ),
          const SizedBox(height: ShiftleyTokens.spaceM),

          // ── Metrics Grid ─────────────────────────────────────────────
          LayoutBuilder(
            builder: (context, constraints) {
              return GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: constraints.maxWidth > 800 ? 4 : 2,
                crossAxisSpacing: ShiftleyTokens.spaceM,
                mainAxisSpacing: ShiftleyTokens.spaceM,
                childAspectRatio: 2.5,
                children: [
                  _buildMetricCard('TOTAL REVENUE', financialsAsync.when(
                    data: (m) => '₹ ${((m.subscriptionRevenuePaise + m.fineRevenuePaise) / 100).toStringAsFixed(0)}',
                    loading: () => '...',
                    error: (e, s) => 'Error',
                  ), Icons.payments_outlined, ShiftleyTokens.secondaryCyan),
                  _buildMetricCard('ACTIVE GIGS', overviewAsync.when(
                    data: (o) => o.totalGigs.toString(),
                    loading: () => '...',
                    error: (e, s) => 'Error',
                  ), Icons.work_outline, ShiftleyTokens.paperWhite),
                  _buildMetricCard('FILL RATE', liquidityAsync.when(
                    data: (l) => '${l.fillRate.toStringAsFixed(1)}%',
                    loading: () => '...',
                    error: (e, s) => 'Error',
                  ), Icons.analytics_outlined, ShiftleyTokens.paperWhite),
                  _buildMetricCard('NO-SHOW RATE', healthAsync.when(
                    data: (h) => '${h.noShowRate.toStringAsFixed(1)}%',
                    loading: () => '...',
                    error: (e, s) => 'Error',
                  ), Icons.warning_amber_outlined, ShiftleyTokens.primaryRed.withAlpha(26)),
                ],
              );
            },
          ),

          const SizedBox(height: ShiftleyTokens.spaceXXL),

          // ── Detailed Tables (Stacked) ────────────────────────────────
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('System Overview', style: ShiftleyTokens.bodyLarge.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: ShiftleyTokens.spaceM),
              overviewAsync.when(
                data: (overview) => _buildSystemTable(overview),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, stack) => Center(child: Text('Error: $err')),
              ),
              const SizedBox(height: ShiftleyTokens.spaceXXL),
              Text('Financial Health', style: ShiftleyTokens.bodyLarge.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: ShiftleyTokens.spaceM),
              financialsAsync.when(
                data: (metrics) => _buildFinancialTable(metrics),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, stack) => Center(child: Text('Error: $err')),
              ),
            ],
          ),

          const SizedBox(height: ShiftleyTokens.spaceXXL),

          // ── Charts & Breakdown ───────────────────────────────────────
          _buildPnLChartSection(pnlAsync),
        ],
      ),
    );
  }

  Widget _buildMetricCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: ShiftleyTokens.spaceM, vertical: ShiftleyTokens.spaceS),
      decoration: BoxDecoration(
        color: color,
        border: ShiftleyTokens.primaryBorder,
        borderRadius: BorderRadius.zero,
      ),
      child: Row(
        children: [
          Icon(icon, size: 21, color: ShiftleyTokens.inkBlack),
          const SizedBox(width: ShiftleyTokens.spaceM),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: ShiftleyTokens.caption.copyWith(fontWeight: FontWeight.bold, fontSize: 9, letterSpacing: 1.1)),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(value, style: ShiftleyTokens.h2.copyWith(fontSize: 16)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPnLChartSection(AsyncValue<PnLSummary> pnlAsync) {
    return _buildChartCard(
      title: 'Revenue vs Expenditure',
      subtitle: 'Monthly platform performance tracking',
      child: pnlAsync.when(
        data: (pnl) => _FinancialChart(pnl: pnl),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
    );
  }

  Widget _buildSystemTable(AnalyticsOverview overview) {
    return Column(
      children: [
        _buildTableHeader(),
        _buildTableRow('Active Professionals', overview.activeWorkers.toString(), '+5% from avg', true),
        _buildTableRow('Active Gigs', overview.totalGigs.toString(), 'Current live', true),
        _buildTableRow('Verified Businesses', overview.activeBusinesses.toString(), 'Total active', true),
      ],
    );
  }

  Widget _buildFinancialTable(FinancialMetrics metrics) {
    return Column(
      children: [
        _buildTableHeader(),
        _buildTableRow('Escrow Balance', '₹ ${(metrics.escrowBalancePaise / 100).toStringAsFixed(2)}', 'Current holding', true),
        _buildTableRow('Worker GMV', '₹ ${(metrics.totalWorkerGmvPaise / 100).toStringAsFixed(2)}', 'Total volume', true),
        _buildTableRow('Subscription Revenue', '₹ ${(metrics.subscriptionRevenuePaise / 100).toStringAsFixed(2)}', 'Direct profit', true),
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
}

class _FinancialChart extends StatelessWidget {
  final PnLSummary pnl;
  const _FinancialChart({required this.pnl});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(painter: _ChartPainter(pnl: pnl), size: Size.infinite);
  }
}

class _ChartPainter extends CustomPainter {
  final PnLSummary pnl;
  _ChartPainter({required this.pnl});

  @override
  void paint(Canvas canvas, Size size) {
    const leftPadding = 60.0;
    const bottomPadding = 40.0;
    const topPadding = 20.0;
    final chartWidth = size.width - leftPadding - 20;
    final chartHeight = size.height - bottomPadding - topPadding;
    
    final revenuePaint = Paint()..color = ShiftleyTokens.secondaryCyan..style = PaintingStyle.stroke..strokeWidth = 3.0..strokeCap = StrokeCap.round;
    final expenditurePaint = Paint()..color = ShiftleyTokens.primaryRed..style = PaintingStyle.stroke..strokeWidth = 3.0..strokeCap = StrokeCap.round;
    final gridPaint = Paint()..color = ShiftleyTokens.utilityGrey.withAlpha(26)..strokeWidth = 1.0;

    // Y-Axis Labels & Grid
    final totalGross = (pnl.grossRevenue['total_gross_paise'] ?? 0) as num;
    final totalExp = (pnl.expenditures['total_expenditure_paise'] ?? 0) as num;
    final maxVal = (totalGross > totalExp ? totalGross : totalExp).toDouble();
    
    for (int i = 0; i <= 5; i++) {
      final y = topPadding + chartHeight * (1 - i / 5);
      canvas.drawLine(Offset(leftPadding, y), Offset(size.width, y), gridPaint);
      final label = '₹ ${(maxVal * i / 5 / 100).toStringAsFixed(0)}';
      _drawText(canvas, label, Offset(5, y - 7), fontSize: 10);
    }

    // X-Axis Months (Mocking previous months for visual)
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Current'];
    final stepX = chartWidth / (months.length - 1);
    for (int i = 0; i < months.length; i++) {
      final x = leftPadding + i * stepX;
      _drawText(canvas, months[i], Offset(x - 10, size.height - 20), fontSize: 10);
    }

    // Drawing paths (Simplified: trending from 0 to current)
    _drawPath(canvas, Offset(leftPadding, topPadding), Size(chartWidth, chartHeight), [0.1, 0.3, 0.2, 0.5, 0.4, totalGross / (maxVal > 0 ? maxVal : 1)], revenuePaint);
    _drawPath(canvas, Offset(leftPadding, topPadding), Size(chartWidth, chartHeight), [0.05, 0.1, 0.15, 0.2, 0.3, totalExp / (maxVal > 0 ? maxVal : 1)], expenditurePaint);
    _drawLegend(canvas, Offset(leftPadding, 0));
  }

  void _drawLegend(Canvas canvas, Offset offset) {
    _drawLegendItem(canvas, offset, ShiftleyTokens.secondaryCyan, 'Revenue');
    _drawLegendItem(canvas, offset + const Offset(100, 0), ShiftleyTokens.primaryRed, 'Expenditure');
  }

  void _drawLegendItem(Canvas canvas, Offset offset, Color color, String label) {
    canvas.drawCircle(offset + const Offset(5, 5), 4, Paint()..color = color);
    _drawText(canvas, label, offset + const Offset(15, 0), fontSize: 12, fontWeight: FontWeight.bold);
  }

  void _drawText(Canvas canvas, String text, Offset offset, {double fontSize = 12, FontWeight fontWeight = FontWeight.normal}) {
    final tp = TextPainter(
      text: TextSpan(
        text: text, 
        style: TextStyle(
          color: ShiftleyTokens.mutedText, 
          fontSize: fontSize, 
          fontWeight: fontWeight,
          fontFamily: 'Figtree'
        )
      ),
      textDirection: ui.TextDirection.ltr
    )..layout();
    tp.paint(canvas, offset);
  }

  void _drawPath(Canvas canvas, Offset origin, Size size, List<double> points, Paint paint) {
    final path = Path();
    final stepX = size.width / (points.length - 1);
    for (int i = 0; i < points.length; i++) {
      final x = origin.dx + i * stepX;
      final y = origin.dy + size.height * (1 - points[i]);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
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
