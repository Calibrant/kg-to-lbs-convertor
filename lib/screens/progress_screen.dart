import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:intl/intl.dart';
import 'package:confetti/confetti.dart';
import 'package:kgtolbs_converter_offline/utils/local_storage.dart';
import 'package:kgtolbs_converter_offline/l10n/app_localizations.dart';

class ProgressScreen extends StatefulWidget {
  final LocalStorage storage;
  final bool isKg;

  const ProgressScreen({super.key, required this.storage, required this.isKg});

  @override
  State<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen> {
  List<Map<String, dynamic>> _history = [];
  late ConfettiController _confettiController;
  BannerAd? _bannerAd;
  bool _isAdLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadHistory();
    _confettiController = ConfettiController(
      duration: const Duration(seconds: 3),
    );
    _loadAd();
    _checkGoalAchievement();
  }

  void _loadHistory() {
    setState(() {
      _history = widget.storage.getHistory();
      // Sort by date
      _history.sort(
        (a, b) =>
            DateTime.parse(a['date']).compareTo(DateTime.parse(b['date'])),
      );
    });
  }

  void _checkGoalAchievement() {
    double? current = widget.storage.getCurrentWeight();
    double? goal = widget.storage.getGoalWeight();
    if (current != null && goal != null && current <= goal) {
      _confettiController.play();
    }
  }

  Future<void> _clearHistory() async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.clearHistory),
        content: Text(l10n.confirmClear),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              l10n.clearHistory,
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await widget.storage.clearHistory();
      _loadHistory();
    }
  }

  void _loadAd() {
    _bannerAd = BannerAd(
      adUnitId: 'ca-app-pub-2717584945928240/2883547422',
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (_) {
          setState(() {
            _isAdLoaded = true;
          });
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
        },
      ),
    )..load();
  }

  @override
  void dispose() {
    _confettiController.dispose();
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final unit = widget.isKg ? 'kg' : 'lbs';
    final isDarkMode = theme.brightness == Brightness.dark;

    final gradientColors = isDarkMode
        ? [const Color(0xFF000957), const Color(0xFF0F226E)]
        : [const Color(0xFFF0F4FF), const Color(0xFFE0E7FF)];

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.history),
        backgroundColor: const Color(0xFF344CB7),
        elevation: 4.0,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.white),
            onPressed: _clearHistory,
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: gradientColors,
          ),
        ),
        child: Stack(
          children: [
            SafeArea(
              child: Column(
                children: [
                  // Chart
                  if (_history.isNotEmpty)
                    Column(
                      // Wrap the chart in a Column to add a message
                      children: [
                        Container(
                          height: 300,
                          padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
                          child: LineChart(
                            LineChartData(
                              minX: -0.5,
                              maxX: (_history.length - 1) + 0.5,
                              minY:
                                  _history
                                      .map(
                                        (e) => (e['weight'] as num).toDouble(),
                                      )
                                      .reduce((a, b) => a < b ? a : b) -
                                  2,
                              maxY:
                                  _history
                                      .map(
                                        (e) => (e['weight'] as num).toDouble(),
                                      )
                                      .reduce((a, b) => a > b ? a : b) +
                                  2,
                              lineTouchData: LineTouchData(
                                touchTooltipData: LineTouchTooltipData(
                                  getTooltipColor: (_) =>
                                      const Color(0xFF344CB7),
                                  getTooltipItems:
                                      (List<LineBarSpot> touchedBarSpots) {
                                        return touchedBarSpots.map((barSpot) {
                                          return LineTooltipItem(
                                            '${barSpot.y} $unit',
                                            TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          );
                                        }).toList();
                                      },
                                ),
                              ),
                              gridData: const FlGridData(show: true),
                              titlesData: const FlTitlesData(
                                bottomTitles: AxisTitles(
                                  sideTitles: SideTitles(showTitles: false),
                                ),
                                topTitles: AxisTitles(
                                  sideTitles: SideTitles(showTitles: false),
                                ),
                                rightTitles: AxisTitles(
                                  sideTitles: SideTitles(showTitles: false),
                                ),
                              ),
                              borderData: FlBorderData(show: true),
                              clipData: const FlClipData.all(),
                              lineBarsData: [
                                LineChartBarData(
                                  spots: _history.asMap().entries.map((e) {
                                    return FlSpot(
                                      e.key.toDouble(),
                                      (e.value['weight'] as num).toDouble(),
                                    );
                                  }).toList(),
                                  isCurved: true,
                                  gradient: const LinearGradient(
                                    colors: [
                                      Color(0xFF577BC1),
                                      Color(0xFFFFEB00),
                                    ],
                                    begin: Alignment.centerLeft,
                                    end: Alignment.centerRight,
                                  ),
                                  barWidth: 4,
                                  isStrokeCapRound: true,
                                  dotData: const FlDotData(show: true),
                                  belowBarData: BarAreaData(
                                    show: true,
                                    gradient: LinearGradient(
                                      colors: [
                                        const Color(
                                          0xFF577BC1,
                                        ).withOpacity(0.3),
                                        const Color(
                                          0xFFFFEB00,
                                        ).withOpacity(0.05),
                                      ],
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        if (_history.length == 1)
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16.0,
                              vertical: 8.0,
                            ),
                            child: Text(
                              l10n.localeName.startsWith('ru')
                                  ? 'Добавьте еще одну запись, чтобы увидеть линию'
                                  : 'Add one more entry to see the line',
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(fontStyle: FontStyle.italic),
                            ),
                          ),
                      ],
                    )
                  else
                    Padding(
                      padding: const EdgeInsets.all(32.0),
                      child: Text(
                        l10n.motivationStart,
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    ),

                  // List
                  Expanded(
                    child: ListView.builder(
                      itemCount: _history.length,
                      itemBuilder: (context, index) {
                        // Show latest first
                        final entry = _history[_history.length - 1 - index];
                        final date = DateTime.parse(entry['date']);
                        final isNewRecord =
                            index == 0; // Simplified logic for demo

                        return Card(
                          margin: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          color: isDarkMode
                              ? const Color(0xFF1a234f)
                              : Colors.white,
                          child: ListTile(
                            leading: const Icon(
                              Icons.fitness_center,
                              color: Color(0xFFFFEB00),
                            ),
                            title: Text(
                              '${entry['weight']} $unit',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                                color: isNewRecord
                                    ? const Color(0xFFFFEB00)
                                    : (isDarkMode
                                          ? Colors.white
                                          : const Color(0xFF000957)),
                              ),
                            ),
                            subtitle: Text(
                              DateFormat.yMMMd().format(date),
                              style: TextStyle(
                                color: isDarkMode
                                    ? const Color(0xFFB0C4FF)
                                    : const Color(0xFF5A7BDB),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            Align(
              alignment: Alignment.topCenter,
              child: ConfettiWidget(
                confettiController: _confettiController,
                blastDirectionality: BlastDirectionality.explosive,
                shouldLoop: false,
                colors: const [
                  Colors.green,
                  Colors.blue,
                  Colors.pink,
                  Colors.orange,
                  Colors.purple,
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _isAdLoaded
          ? SizedBox(
              height: _bannerAd!.size.height.toDouble(),
              width: _bannerAd!.size.width.toDouble(),
              child: AdWidget(ad: _bannerAd!),
            )
          : null,
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFFFFEB00),
        foregroundColor: const Color(0xFF000957),
        onPressed: () async {
          // Quick add current weight to history
          double? current = widget.storage.getCurrentWeight();
          if (current != null) {
            await widget.storage.addHistoryEntry(current, DateTime.now());
            _loadHistory();
            if (mounted) {
              ScaffoldMessenger.of(context).clearSnackBars();
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(l10n.save)));
            }
          }
        },
        tooltip: l10n.addToday,
        child: const Icon(Icons.add),
      ),
    );
  }
}
