import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'classes/metadata.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: MyComponent(),
    );
  }
}

Future<Response> fetchData() async {
  return await get(Uri.parse(
      'https://gist.githubusercontent.com/motgi/8fc373cbfccee534c820875ba20ae7b5/raw/7143758ff2caa773e651dc3576de57cc829339c0/config.json'));
}

int fromDollars(String dollars) {
  return int.parse(dollars.replaceAll(RegExp(r'[^\w\s]+'), ''));
}

class MyComponent extends StatefulWidget {
  const MyComponent({super.key});

  @override
  State<MyComponent> createState() => _MyComponentState();
}

// ignore: constant_identifier_names - using JSON values to key into handleUpdate
enum KnownKey { revenue_amount, funding_amount }

class _MyComponentState extends State<MyComponent> {
  Metadata? revenue;
  Metadata? fundingAmount;
  Metadata? revenuePercentage;
  Metadata? revenueSharedFrequency;
  Metadata? desiredRepaymentDelay;
  Metadata? useOfFunds;

  Map<KnownKey, int> knownKeyToValue = {
    KnownKey.revenue_amount: 1,
    KnownKey.funding_amount: 1,
  };

  void handleUpdate({required KnownKey key, required int value}) {
    setState(() {
      knownKeyToValue[key] = value;
      if (key == KnownKey.revenue_amount) {
        knownKeyToValue[KnownKey.funding_amount] = (value / 3).toInt();
      }
    });
  }

  @override
  void initState() {
    fetchData().then((res) {
      if (res.statusCode == 200) {
        List decodedJson = jsonDecode(res.body);
        decodedJson.forEach((json) {
          var metadata = Metadata.fromJson(json);
          setState(() {
            switch (metadata.name) {
              case 'revenue_amount':
                revenue = metadata;
                handleUpdate(
                    key: KnownKey.revenue_amount,
                    value: fromDollars(metadata.placeholder));
                break;
              case 'funding_amount':
                fundingAmount = metadata;
              case 'revenue_percentage':
                revenuePercentage = metadata;
              case 'revenue_shared_frequency':
                revenueSharedFrequency = metadata;
              case 'desired_repayment_delay':
                desiredRepaymentDelay = metadata;
              case 'use_of_funds':
                useOfFunds = metadata;
            }
          });
        });
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.blue),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: FinancingOptions(
              knownKeyToValue: knownKeyToValue,
              handleUpdate: handleUpdate,
              revenue: revenue,
              fundingAmount: fundingAmount,
              revenuePercentage: revenuePercentage,
              revenueSharedFrequency: revenueSharedFrequency,
              desiredRepaymentDelay: desiredRepaymentDelay,
              useOfFunds: useOfFunds,
            ),
          ),
          Expanded(
            child: Placeholder(),
          ),
          SizedBox.shrink()
        ],
      ),
    );
  }
}

class FinancingOptions extends StatefulWidget {
  final Map<KnownKey, int> knownKeyToValue;
  final void Function({required KnownKey key, required int value}) handleUpdate;
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
    required this.revenue,
    required this.fundingAmount,
    required this.revenuePercentage,
    required this.revenueSharedFrequency,
    required this.desiredRepaymentDelay,
    required this.useOfFunds,
  });

  @override
  State<FinancingOptions> createState() => _FinancingOptionsState();
}

class _FinancingOptionsState extends State<FinancingOptions> {
  TextEditingController? financingOptionsController;
  double? initialValue;
  String? sharedFrequency;

  @override
  void initState() {
    var revenue = widget.revenue;
    if (revenue != null) {
      financingOptionsController = TextEditingController();
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var revenueAmount = widget.knownKeyToValue[KnownKey.revenue_amount];
    var fundingAmount = widget.knownKeyToValue[KnownKey.funding_amount];

    return Card(
        margin: EdgeInsets.zero,
        child: SizedBox.expand(
            child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Financing options',
              style: TextStyle(fontSize: 30),
            ),
            Text(widget.revenue?.label ?? ''),
            TextFormField(
              key: Key(revenueAmount.toString()),
              autovalidateMode: AutovalidateMode.always,
              keyboardType: TextInputType.number,
              controller: financingOptionsController,
              initialValue: '$revenueAmount',
              onChanged: (val) {
                var parsedVal = int.tryParse(val);
                if (parsedVal != null && parsedVal > 0) {
                  widget.handleUpdate(
                      key: KnownKey.revenue_amount, value: parsedVal);
                }
              },
            ),
            RevenueAmount(
              key: Key(initialValue.toString()),
              fundingAmount: widget.fundingAmount,
              knownKeyToValue: widget.knownKeyToValue,
              handleUpdate: widget.handleUpdate,
            ),
            Row(
              children: [
                Text('${widget.revenuePercentage?.tooltip ?? ''}: '),
                Text(
                    '${(((0.156 / 6.2055 / (revenueAmount ?? 1)) * ((fundingAmount ?? 1) * 10)) * 100).toStringAsFixed(2)}%'),
              ],
            ),
            if (widget.revenueSharedFrequency != null)
              Row(
                children: [
                  Text(widget.revenueSharedFrequency!.label),
                  Row(
                    children: [
                      ...widget.revenueSharedFrequency!.value
                          .split('*')
                          .map((e) {
                        return Row(
                          children: [
                            Radio(
                                value: e,
                                groupValue: sharedFrequency,
                                onChanged: (val) {
                                  setState(() {
                                    sharedFrequency = val;
                                  });
                                }),
                            Text(e),
                          ],
                        );
                      })
                    ],
                  ),
                ],
              ),
            if (widget.desiredRepaymentDelay != null)
              Row(
                children: [
                  Text(widget.desiredRepaymentDelay!.label),
                  DropdownMenu(
                      dropdownMenuEntries: widget.desiredRepaymentDelay!.value
                          .split('*')
                          .map((val) {
                    return DropdownMenuEntry(value: val, label: val);
                  }).toList())
                ],
              ),
            UseOfFunds(
                useOfFunds: widget.useOfFunds,
                knownKeyToValue: widget.knownKeyToValue,
                handleUpdate: widget.handleUpdate)
          ],
        )));
  }
}

class RevenueAmount extends StatefulWidget {
  final Metadata? fundingAmount;
  final Map<KnownKey, int> knownKeyToValue;
  final void Function({required KnownKey key, required int value}) handleUpdate;

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
  double fundingAmount = 0;
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var revenueAmount = widget.knownKeyToValue[KnownKey.revenue_amount]!;
    var fundingAmount = widget.knownKeyToValue[KnownKey.funding_amount]!;
    double maxRevenue = revenueAmount / 3;
    return Row(children: [
      Expanded(
          child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(widget.fundingAmount?.label ?? ''),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [Text('0'), Text(maxRevenue.toStringAsFixed(0))],
          ),
          Slider(
            min: 0,
            value: fundingAmount.toDouble(),
            max: maxRevenue,
            onChanged: (val) {
              widget.handleUpdate(
                  key: KnownKey.funding_amount, value: val.toInt());
            },
          ),
        ],
      )),
      SizedBox(
          width: 100,
          height: 50,
          child: TextFormField(
            keyboardType: TextInputType.number,
            key: Key(fundingAmount.toString()),
            initialValue: fundingAmount.toString(),
            onChanged: (val) {
              // TODO: Fix bug..
              var parsedVal = int.tryParse(val);
              if (parsedVal != null && parsedVal <= maxRevenue) {
                widget.handleUpdate(
                    key: KnownKey.funding_amount, value: parsedVal);
              }
            },
          )),
    ]);
  }
}

class UseOfFunds extends StatefulWidget {
  final Metadata? useOfFunds;
  final Map<KnownKey, int> knownKeyToValue;
  final void Function({required KnownKey key, required int value}) handleUpdate;

  const UseOfFunds({
    super.key,
    required this.useOfFunds,
    required this.knownKeyToValue,
    required this.handleUpdate,
  });

  @override
  State<UseOfFunds> createState() => _UseOfFundsState();
}

class _UseOfFundsState extends State<UseOfFunds> {
  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
