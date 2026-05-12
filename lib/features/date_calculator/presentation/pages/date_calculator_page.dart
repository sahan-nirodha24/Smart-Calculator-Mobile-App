import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../providers/date_history_provider.dart';
import '../../../standard_calculator/presentation/widgets/history_panel.dart';

class DateCalculatorPage extends ConsumerStatefulWidget {
  const DateCalculatorPage({super.key});

  @override
  ConsumerState<DateCalculatorPage> createState() => _DateCalculatorPageState();
}

class _DateCalculatorPageState extends ConsumerState<DateCalculatorPage> {
  int _selectedTab = 0; // 0: Difference, 1: Add/Subtract, 2: Age, 3: Business Days

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Row(
          children: [
            Expanded(
              child: Column(
                children: [
                  _buildTabs(),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(24.0),
                      child: _buildSelectedTool(),
                    ),
                  ),
                ],
              ),
            ),
            if (constraints.maxWidth > 900)
              Container(
                width: 300,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border(left: BorderSide(color: Theme.of(context).dividerColor.withOpacity(0.1))),
                ),
                child: const HistoryPanel(),
              ),
          ],
        );
      }
    );
  }

  Widget _buildTabs() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _tabItem(0, "Difference"),
          _tabItem(1, "Add/Subtract"),
          _tabItem(2, "Age"),
          _tabItem(3, "Business Days"),
        ],
      ),
    );
  }

  Widget _tabItem(int index, String label) {
    bool isSelected = _selectedTab == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedTab = index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isSelected ? Theme.of(context).colorScheme.primary : Colors.transparent,
              width: 2,
            ),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: isSelected ? Theme.of(context).colorScheme.primary : null,
          ),
        ),
      ),
    );
  }

  Widget _buildSelectedTool() {
    switch (_selectedTab) {
      case 0: return const _DateDifferenceTool();
      case 1: return const _DateAddSubtractTool();
      case 2: return const _AgeCalculatorTool();
      case 3: return const _BusinessDaysTool();
      default: return const SizedBox();
    }
  }
}

// --- Tool 1: Date Difference ---
class _DateDifferenceTool extends ConsumerStatefulWidget {
  const _DateDifferenceTool();
  @override
  ConsumerState<_DateDifferenceTool> createState() => _DateDifferenceToolState();
}

class _DateDifferenceToolState extends ConsumerState<_DateDifferenceTool> {
  DateTime fromDate = DateTime.now();
  DateTime toDate = DateTime.now().add(const Duration(days: 1));

  void _autoSave() {
    String diffText = _calculateDiff();
    String entry = "${DateFormat.yMd().format(fromDate)} - ${DateFormat.yMd().format(toDate)} = $diffText";
    ref.read(dateHistoryProvider.notifier).addEntry(entry);
  }

  String _calculateDiff() {
    int years = toDate.year - fromDate.year;
    int months = toDate.month - fromDate.month;
    int dayDiff = toDate.day - fromDate.day;

    if (dayDiff < 0) {
      months -= 1;
    }
    if (months < 0) {
      years -= 1;
      months += 12;
    }
    
    DateTime tempDate = DateTime(fromDate.year + years, fromDate.month + months, fromDate.day);
    int finalDays = toDate.difference(tempDate).inDays;

    List<String> parts = [];
    if (years.abs() > 0) parts.add("${years.abs()} years");
    if (months.abs() > 0) parts.add("${months.abs()} months");
    if (finalDays.abs() > 0) parts.add("${finalDays.abs()} days");
    
    return parts.isEmpty ? "0 days" : parts.join(", ");
  }

  @override
  Widget build(BuildContext context) {
    String diffText = _calculateDiff();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _datePickerTile("From", fromDate, (d) {
          setState(() => fromDate = d);
          _autoSave();
        }),
        const SizedBox(height: 16),
        _datePickerTile("To", toDate, (d) {
          setState(() => toDate = d);
          _autoSave();
        }),
        const SizedBox(height: 40),
        const Text("Difference", style: TextStyle(color: Colors.grey)),
        Text(diffText, style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Text("${toDate.difference(fromDate).inDays.abs()} total days", style: const TextStyle(color: Colors.grey)),
      ],
    );
  }
}

// --- Tool 2: Add/Subtract ---
class _DateAddSubtractTool extends ConsumerStatefulWidget {
  const _DateAddSubtractTool();
  @override
  ConsumerState<_DateAddSubtractTool> createState() => _DateAddSubtractToolState();
}

class _DateAddSubtractToolState extends ConsumerState<_DateAddSubtractTool> {
  DateTime baseDate = DateTime.now();
  bool isAdd = true;
  int years = 0, months = 0, days = 0;

  void _autoSave() {
    DateTime res = result;
    String op = isAdd ? "+" : "-";
    String entry = "${DateFormat.yMd().format(baseDate)} $op ($years y, $months m, $days d) = ${DateFormat.yMd().format(res)}";
    ref.read(dateHistoryProvider.notifier).addEntry(entry);
  }

  DateTime get result {
    int factor = isAdd ? 1 : -1;
    return DateTime(
      baseDate.year + (years * factor),
      baseDate.month + (months * factor),
      baseDate.day + (days * factor),
    );
  }

  @override
  Widget build(BuildContext context) {
    DateTime res = result;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _datePickerTile("From", baseDate, (d) {
          setState(() => baseDate = d);
          _autoSave();
        }),
        const SizedBox(height: 24),
        Row(
          children: [
            ChoiceChip(label: const Text("Add"), selected: isAdd, onSelected: (v) {
              setState(() => isAdd = true);
              _autoSave();
            }),
            const SizedBox(width: 8),
            ChoiceChip(label: const Text("Subtract"), selected: !isAdd, onSelected: (v) {
              setState(() => isAdd = false);
              _autoSave();
            }),
          ],
        ),
        const SizedBox(height: 24),
        _numInput("Years", years, (v) {
          setState(() => years = v);
          _autoSave();
        }),
        _numInput("Months", months, (v) {
          setState(() => months = v);
          _autoSave();
        }),
        _numInput("Days", days, (v) {
          setState(() => days = v);
          _autoSave();
        }),
        const SizedBox(height: 40),
        const Text("Result Date", style: TextStyle(color: Colors.grey)),
        Text(DateFormat.yMMMMd().format(res), style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),
        Text(DateFormat('EEEE').format(res), style: const TextStyle(color: Colors.grey, fontSize: 18)),
      ],
    );
  }

  Widget _numInput(String label, int val, Function(int) onChanged) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        children: [
          SizedBox(width: 80, child: Text(label)),
          IconButton(icon: const Icon(Icons.remove), onPressed: () => onChanged(val > 0 ? val - 1 : 0)),
          Text("$val", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          IconButton(icon: const Icon(Icons.add), onPressed: () => onChanged(val + 1)),
        ],
      ),
    );
  }
}

// --- Tool 3: Age Calculator ---
class _AgeCalculatorTool extends ConsumerStatefulWidget {
  const _AgeCalculatorTool();
  @override
  ConsumerState<_AgeCalculatorTool> createState() => _AgeCalculatorToolState();
}

class _AgeCalculatorToolState extends ConsumerState<_AgeCalculatorTool> {
  DateTime dob = DateTime(2000, 1, 1);
  DateTime today = DateTime.now();

  void _autoSave() {
    int y = today.year - dob.year;
    int m = today.month - dob.month;
    int d = today.day - dob.day;
    if (d < 0) { m -= 1; d += 30; }
    if (m < 0) { y -= 1; m += 12; }
    String entry = "Age (${DateFormat.yMd().format(dob)}) = $y y, $m m, $d d";
    ref.read(dateHistoryProvider.notifier).addEntry(entry);
  }

  @override
  Widget build(BuildContext context) {
    int years = today.year - dob.year;
    int months = today.month - dob.month;
    int days = today.day - dob.day;

    if (days < 0) {
      months -= 1;
      days += DateTime(today.year, today.month, 0).day;
    }
    if (months < 0) {
      years -= 1;
      months += 12;
    }

    String ageText = "$years years, $months months, $days days";

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _datePickerTile("Date of Birth", dob, (d) {
          setState(() => dob = d);
          _autoSave();
        }),
        const SizedBox(height: 16),
        _datePickerTile("Today\u0027s Date", today, (d) {
          setState(() => today = d);
          _autoSave();
        }),
        const SizedBox(height: 40),
        const Text("Age", style: TextStyle(color: Colors.grey)),
        Text(ageText, style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 20),
        _nextBirthdayInfo(),
      ],
    );
  }

  Widget _nextBirthdayInfo() {
    DateTime nextBday = DateTime(today.year, dob.month, dob.day);
    if (nextBday.isBefore(today)) {
      nextBday = DateTime(today.year + 1, dob.month, dob.day);
    }
    int daysLeft = nextBday.difference(today).inDays;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          const Icon(Icons.cake_outlined),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Next Birthday"),
              Text("${DateFormat('EEEE').format(nextBday)}, in $daysLeft days", style: const TextStyle(fontWeight: FontWeight.bold)),
            ],
          )
        ],
      ),
    );
  }
}

// --- Tool 4: Business Days ---
class _BusinessDaysTool extends ConsumerStatefulWidget {
  const _BusinessDaysTool();
  @override
  ConsumerState<_BusinessDaysTool> createState() => _BusinessDaysToolState();
}

class _BusinessDaysToolState extends ConsumerState<_BusinessDaysTool> {
  DateTime fromDate = DateTime.now();
  DateTime toDate = DateTime.now().add(const Duration(days: 10));

  void _autoSave() {
    int bDays = _calculateBusinessDays();
    String entry = "Business Days (${DateFormat.yMd().format(fromDate)} - ${DateFormat.yMd().format(toDate)}) = $bDays days";
    ref.read(dateHistoryProvider.notifier).addEntry(entry);
  }

  int _calculateBusinessDays() {
    int count = 0;
    DateTime temp = fromDate;
    while (temp.isBefore(toDate)) {
      if (temp.weekday != DateTime.saturday && temp.weekday != DateTime.sunday) {
        count++;
      }
      temp = temp.add(const Duration(days: 1));
    }
    return count;
  }

  @override
  Widget build(BuildContext context) {
    int bDays = _calculateBusinessDays();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _datePickerTile("Start Date", fromDate, (d) {
          setState(() => fromDate = d);
          _autoSave();
        }),
        const SizedBox(height: 16),
        _datePickerTile("End Date", toDate, (d) {
          setState(() => toDate = d);
          _autoSave();
        }),
        const SizedBox(height: 40),
        const Text("Business Days (Mon-Fri)", style: TextStyle(color: Colors.grey)),
        Text("$bDays days", style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Text("Leap Year: ${DateTime(fromDate.year, 3, 0).day == 29 ? 'Yes' : 'No'} (${fromDate.year})", style: const TextStyle(color: Colors.grey)),
      ],
    );
  }
}

// --- Helper UI Widgets ---
Widget _datePickerTile(String label, DateTime date, Function(DateTime) onChanged) {
  return Builder(
    builder: (context) => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        const SizedBox(height: 4),
        InkWell(
          onTap: () async {
            final picked = await showDatePicker(
              context: context,
              initialDate: date,
              firstDate: DateTime(1900),
              lastDate: DateTime(2100),
            );
            if (picked != null) onChanged(picked);
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.withOpacity(0.3)),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(DateFormat.yMMMMd().format(date), style: const TextStyle(fontSize: 16)),
                const Icon(Icons.calendar_month_outlined, size: 20),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}
