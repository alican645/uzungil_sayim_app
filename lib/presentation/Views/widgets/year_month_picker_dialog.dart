import 'package:flutter/material.dart';

class YearMonthPickerDialog extends StatefulWidget {
  final int initialYear;
  final int initialMonth;

  const YearMonthPickerDialog({
    super.key,
    required this.initialYear,
    required this.initialMonth,
  });

  @override
  State<YearMonthPickerDialog> createState() => _YearMonthPickerDialogState();
}

class _YearMonthPickerDialogState extends State<YearMonthPickerDialog> {
  late int _selectedYear;
  late int _selectedMonth;

  @override
  void initState() {
    super.initState();
    _selectedYear = widget.initialYear;
    _selectedMonth = widget.initialMonth;
  }

  @override
  Widget build(BuildContext context) {
    final currentYear = DateTime.now().year;
    final years = List.generate(11, (index) => currentYear - 5 + index);
    final months = List.generate(12, (index) => index + 1);

    return AlertDialog(
      title: const Text('Tarih Seçimi'),
      content: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          DropdownButton<int>(
            value: _selectedYear,
            items: years.map((year) {
              return DropdownMenuItem(
                value: year,
                child: Text(year.toString()),
              );
            }).toList(),
            onChanged: (value) {
              if (value != null) {
                setState(() => _selectedYear = value);
              }
            },
          ),
          DropdownButton<int>(
            value: _selectedMonth,
            items: months.map((month) {
              return DropdownMenuItem(
                value: month,
                child: Text(month.toString()),
              );
            }).toList(),
            onChanged: (value) {
              if (value != null) {
                setState(() => _selectedMonth = value);
              }
            },
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('İptal'),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context, {
              'year': _selectedYear,
              'month': _selectedMonth,
            });
          },
          child: const Text('Tamam'),
        ),
      ],
    );
  }
}
