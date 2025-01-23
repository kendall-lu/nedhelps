import 'package:flutter/material.dart';
import 'package:nedhelps/classes/metadata.dart';
import 'package:nedhelps/main.dart';

class RevenueAmount extends StatefulWidget {
  final Metadata? fundingAmount;
  final Map<KnownKey, dynamic> knownKeyToValue;
  final void Function({required KnownKey key, required dynamic value})
      handleUpdate;

  const RevenueAmount({
    super.key,
    required this.fundingAmount,
    required this.knownKeyToValue,
    required this.handleUpdate,
  });

  @override
  State<RevenueAmount> createState() => _RevenueAmountState();
}

class _RevenueAmountState extends State<RevenueAmount> {
  late TextEditingController _controller;

  double get loanAmount => widget.knownKeyToValue[KnownKey.loan_amount] ?? 0;
  double get maxLoanAmount =>
      widget.knownKeyToValue[KnownKey.max_loan_amount] ?? 1;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: loanAmount.toStringAsFixed(2));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onSliderChanged(double value) {
    setState(() {
      _controller.text = value.toStringAsFixed(2);
    });
    widget.handleUpdate(key: KnownKey.loan_amount, value: value);
  }

  void _onTextChanged(String val) {
    var parsedVal = double.tryParse(val) ?? 0;
    widget.handleUpdate(
      key: KnownKey.loan_amount,
      value: parsedVal > maxLoanAmount ? maxLoanAmount : parsedVal,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(widget.fundingAmount?.label ??
                  'What is your desired loan amount?'),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(toDollar(0)),
                  Text(toDollar(maxLoanAmount)),
                ],
              ),
              Slider(
                min: 0,
                max: maxLoanAmount,
                value: loanAmount,
                onChanged: _onSliderChanged,
              ),
            ],
          ),
        ),
        SizedBox(
          width: 100,
          child: TextFormField(
            keyboardType: TextInputType.number,
            controller: _controller,
            onChanged: _onTextChanged,
          ),
        ),
      ],
    );
  }
}
