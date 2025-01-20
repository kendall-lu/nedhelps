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

String fromDollars(String dollars) {
  return dollars.replaceAll(RegExp(r'[^\w\s]+'), '');
}

class MyComponent extends StatefulWidget {
  const MyComponent({super.key});

  @override
  State<MyComponent> createState() => _MyComponentState();
}

// ignore: constant_identifier_names - using JSON values to key into handleUpdate
enum KnownKey { revenue_amount }

class _MyComponentState extends State<MyComponent> {
  Metadata? revenue;
  Metadata? fundingAmount;

  Map<KnownKey, dynamic> knownKeyToValue = {KnownKey.revenue_amount: 0};

  void handleUpdate({required KnownKey key, required dynamic value}) {
    setState(() {
      knownKeyToValue[key] = value;
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
              revenue: revenue,
              fundingAmount: fundingAmount,
              knownKeyToValue: knownKeyToValue,
              handleUpdate: handleUpdate,
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
  final Metadata? revenue;
  final Metadata? fundingAmount;
  final Map<KnownKey, dynamic> knownKeyToValue;
  final void Function({required KnownKey key, required dynamic value})
      handleUpdate;

  const FinancingOptions({
    super.key,
    required this.revenue,
    required this.fundingAmount,
    required this.knownKeyToValue,
    required this.handleUpdate,
  });

  @override
  State<FinancingOptions> createState() => _FinancingOptionsState();
}

class _FinancingOptionsState extends State<FinancingOptions> {
  TextEditingController? financingOptionsController;
  double? initialValue;

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
              initialValue: revenueAmount,
              onChanged: (val) {
                var parsedVal = int.tryParse(val);
                if (parsedVal != null && parsedVal > 0) {
                  widget.handleUpdate(
                      key: KnownKey.revenue_amount,
                      value: parsedVal.toString());
                }
              },
            ),
            RevenueAmount(
                fundingAmount: widget.fundingAmount,
                knownKeyToValue: widget.knownKeyToValue,
                key: Key(initialValue.toString()))
          ],
        )));
  }
}

class RevenueAmount extends StatefulWidget {
  final Metadata? fundingAmount;
  final Map<KnownKey, dynamic> knownKeyToValue;
  const RevenueAmount({
    super.key,
    required this.fundingAmount,
    required this.knownKeyToValue,
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
    int revenueAmount =
        int.parse(widget.knownKeyToValue[KnownKey.revenue_amount]);

    double maxRevenue = (revenueAmount / 3);
    return Row(children: [
      Expanded(
          child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(widget.fundingAmount?.label ?? ''),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [Text('0'), Text('$maxRevenue')],
          ),
          Slider(
            min: 0,
            value: fundingAmount.toDouble(),
            max: maxRevenue,
            onChanged: (val) {
              setState(() {
                fundingAmount = val;
              });
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
                setState(() {
                  fundingAmount = parsedVal.toDouble();
                });
              }
            },
          ))
    ]);
  }
}
