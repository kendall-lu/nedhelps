import 'package:flutter/material.dart';
import 'package:nedhelps/classes/metadata.dart';
import 'package:nedhelps/main.dart';
import 'package:nedhelps/widgets/revenue_amount.dart';
import 'package:nedhelps/widgets/use_of_funds.dart';

class FinancingOptions extends StatefulWidget {
  final Map<KnownKey, dynamic> knownKeyToValue;
  final void Function({required KnownKey key, required dynamic value})
      handleUpdate;
  final Metadata? revenue;
  final Metadata? fundingAmount;
  final Metadata? revenuePercentage;
  final Metadata? revenueSharedFrequency;
  final Metadata? desiredRepaymentDelay;
  final Metadata? useOfFunds;

  const FinancingOptions({
    super.key,
    required this.knownKeyToValue,
    required this.handleUpdate,
    this.revenue,
    this.fundingAmount,
    this.revenuePercentage,
    this.revenueSharedFrequency,
    this.desiredRepaymentDelay,
    this.useOfFunds,
  });

  @override
  State<FinancingOptions> createState() => _FinancingOptionsState();
}

class _FinancingOptionsState extends State<FinancingOptions> {
  late TextEditingController _controller;

  double get revenueAmount =>
      widget.knownKeyToValue[KnownKey.revenue_amount] ?? 0;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: revenueAmount.toString());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var revenuePercentage = widget.knownKeyToValue[KnownKey.revenue_percentage];
    var userFriendlyRevenueAmount = revenueAmount.toString();

    if (_controller.text != userFriendlyRevenueAmount) {
      _controller.text = userFriendlyRevenueAmount;
    }

    return Expanded(
      child: Card(
        margin: EdgeInsets.zero,
        child: SizedBox.expand(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Financing options', style: TextStyle(fontSize: 30)),
              Text(widget.revenue?.label ?? ''),
              TextFormField(
                keyboardType: TextInputType.number,
                controller: _controller,
                onChanged: (val) {
                  var parsedVal = int.tryParse(val);
                  widget.handleUpdate(
                    key: KnownKey.revenue_amount,
                    value: parsedVal != null ? parsedVal.toDouble() : 0,
                  );
                },
              ),
              RevenueAmount(
                fundingAmount: widget.fundingAmount,
                knownKeyToValue: widget.knownKeyToValue,
                handleUpdate: widget.handleUpdate,
              ),
              Row(
                children: [
                  Text('${widget.revenuePercentage?.tooltip ?? ''}: '),
                  Text(percentageFrom(revenuePercentage)),
                ],
              ),
              if (widget.revenueSharedFrequency != null)
                _buildRevenueShareFrequency(),
              if (widget.desiredRepaymentDelay != null)
                _buildDesiredRepaymentDelay(),
              UseOfFunds(
                useOfFunds: widget.useOfFunds,
                knownKeyToValue: widget.knownKeyToValue,
                handleUpdate: widget.handleUpdate,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRevenueShareFrequency() {
    return Row(
      children: [
        Text(widget.revenueSharedFrequency!.label),
        Row(
          children: widget.revenueSharedFrequency!.value.split('*').map((e) {
            return Row(
              children: [
                Radio<String>(
                  value: e,
                  groupValue:
                      widget.knownKeyToValue[KnownKey.revenue_share_frequency],
                  onChanged: (val) {
                    widget.handleUpdate(
                      key: KnownKey.revenue_share_frequency,
                      value: val,
                    );
                  },
                ),
                Text(e),
              ],
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildDesiredRepaymentDelay() {
    var temp = widget.knownKeyToValue[KnownKey.desired_repayment_delay];

    return Row(
      children: [
        Text(widget.desiredRepaymentDelay!.label),
        DropdownMenu(
          initialSelection: temp?.toString(),
          onSelected: (value) {
            widget.handleUpdate(
              key: KnownKey.desired_repayment_delay,
              value: value,
            );
          },
          dropdownMenuEntries:
              widget.desiredRepaymentDelay!.value.split('*').map((val) {
            return DropdownMenuEntry(
              value: val,
              label: val,
            );
          }).toList(),
        ),
      ],
    );
  }
}
