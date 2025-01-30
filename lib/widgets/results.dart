import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:nedhelps/main.dart';

class Results extends StatefulWidget {
  final Map<KnownKey, dynamic> knownKeyToValue;
  const Results({super.key, required this.knownKeyToValue});

  @override
  State<Results> createState() => _ResultsState();
}

class _ResultsState extends State<Results> {
  DateTime addMonthsAndDays({
    String? revenueShareFrequency,
    required int expectedTransfers,
    required int desiredRepaymentDelay,
  }) {
    DateTime result = DateTime.now();

    if (revenueShareFrequency == 'monthly') {
      result = DateTime(
        result.year + ((result.month + expectedTransfers - 1) ~/ 12),
        (result.month + expectedTransfers - 1) % 12 + 1,
        result.day,
      );
    } else if (revenueShareFrequency == 'weekly') {
      result = result.add(Duration(days: expectedTransfers * 7));
    }

    result = result.add(Duration(days: desiredRepaymentDelay));
    return result;
  }

  @override
  Widget build(BuildContext context) {
    final knownKeyToValue = widget.knownKeyToValue;

    // Extract values from the map, providing default values where necessary
    final revenueAmount = knownKeyToValue[KnownKey.revenue_amount] ?? 0;
    final loanAmount = knownKeyToValue[KnownKey.loan_amount] ?? 0;
    final revenuePercentage = knownKeyToValue[KnownKey.revenue_percentage] ?? 0;
    final revenueShareFrequency =
        knownKeyToValue[KnownKey.revenue_share_frequency];
    final desiredRepaymentDelay =
        knownKeyToValue[KnownKey.desired_repayment_delay] ?? 0;
    final desiredFeePercentage =
        knownKeyToValue[KnownKey.desired_fee_percentage] ?? 0;

    // Determine the frequency multiplier (12 for monthly, 52 for weekly)
    final revenueShareFrequencyMultiplier = revenueShareFrequency == 'monthly'
        ? 12
        : revenueShareFrequency == 'weekly'
            ? 52
            : 0;

    // Calculate fees, total revenue share, and expected transfers
    final calculatedTotalFees = desiredFeePercentage * loanAmount;
    final calculatedTotalRevenueShare = loanAmount + calculatedTotalFees;
    final expectedTransfersDenom = revenueAmount * revenuePercentage;

    final calculatedExpectedTransfers =
        (expectedTransfersDenom != 0 && revenueShareFrequencyMultiplier > 0)
            ? ((calculatedTotalRevenueShare * revenueShareFrequencyMultiplier) /
                    expectedTransfersDenom)
                .ceil()
            : 0;

    // Calculate and format the expected completion date
    final calculatedCompletionDate = addMonthsAndDays(
      expectedTransfers: calculatedExpectedTransfers,
      revenueShareFrequency: revenueShareFrequency,
      desiredRepaymentDelay: desiredRepaymentDelay,
    );

    final formattedCompletionDate =
        DateFormat('MMMM d, y').format(calculatedCompletionDate);

    return Expanded(
      child: Card(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Results',
              style: TextStyle(fontSize: 30),
            ),
            ResultSection(
              leading: 'Annual Business Revenue',
              trailing: toDollar(revenueAmount),
            ),
            ResultSection(
              leading: 'Funding Amount',
              trailing: toDollar(loanAmount),
            ),
            ResultSection(
              leading: 'Fees',
              trailing:
                  '(${percentageFrom(desiredFeePercentage)}) ${toDollar(calculatedTotalFees)}',
            ),
            const Divider(),
            ResultSection(
              leading: 'Total Revenue Share',
              trailing: toDollar(calculatedTotalRevenueShare),
            ),
            ResultSection(
              leading: 'Expected Transfers',
              trailing: calculatedExpectedTransfers.toString(),
            ),
            ResultSection(
              leading: 'Expected Completion Date',
              trailing: formattedCompletionDate,
            ),
          ],
        ),
      ),
    );
  }
}

class ResultSection extends StatelessWidget {
  final String leading;
  final String trailing;

  const ResultSection({
    super.key,
    required this.leading,
    required this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    const TextStyle style =
        TextStyle(fontSize: 18, fontWeight: FontWeight.bold);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(leading, style: style),
        Text(trailing, style: style),
      ],
    );
  }
}
