// ignore_for_file: constant_identifier_names

import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:nedhelps/widgets/financing_options.dart';
import 'package:nedhelps/widgets/results.dart';
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
      home: const Scaffold(
        body: NedHelps(),
      ),
    );
  }
}

Future<Response> fetchData() async {
  return await get(Uri.parse(
      'https://gist.githubusercontent.com/motgi/8fc373cbfccee534c820875ba20ae7b5/raw/7143758ff2caa773e651dc3576de57cc829339c0/config.json'));
}

int filterNumbers(String input) {
  return int.parse(input.replaceAll(RegExp(r'[^0-9]'), ''));
}

double fromDollars(String dollars) {
  return int.parse(dollars.replaceAll(RegExp(r'[^\w\s]+'), '')).toDouble();
}

String percentageFrom(double? value) {
  return value != null && !value.isNaN
      ? '${(value * 100).toStringAsFixed(2)}%'
      : '0%';
}

String toDollar(double? value) {
  return value != null && !value.isNaN
      ? '\$${value.toStringAsFixed(2)}'
      : '\$0.00';
}

class NedHelps extends StatefulWidget {
  const NedHelps({super.key});

  @override
  State<NedHelps> createState() => _NedHelpsState();
}

enum KnownKey {
  revenue_amount,
  loan_amount,
  revenue_percentage,
  revenue_share_frequency,
  desired_repayment_delay,
  max_loan_amount,
}

enum RevenueShareFrequency {
  weekly,
  monthly,
}

class _NedHelpsState extends State<NedHelps> {
  Metadata? revenue;
  Metadata? fundingAmount;
  Metadata? revenuePercentage;
  Metadata? revenueSharedFrequency;
  Metadata? desiredRepaymentDelay;
  Metadata? useOfFunds;

  Map<KnownKey, dynamic> knownKeyToValue = {};

  void handleUpdate({required KnownKey key, required dynamic value}) {
    setState(() {
      knownKeyToValue = {...knownKeyToValue};
      knownKeyToValue[key] = value;

      if (key == KnownKey.revenue_amount || key == KnownKey.loan_amount) {
        if (key == KnownKey.revenue_amount) {
          knownKeyToValue[KnownKey.revenue_amount] = value;
          knownKeyToValue[KnownKey.max_loan_amount] = value / 3;
          knownKeyToValue[KnownKey.loan_amount] = 0;
        }

        var revenueAmount = knownKeyToValue[KnownKey.revenue_amount] ?? 0;
        var loanAmount = knownKeyToValue[KnownKey.loan_amount] ?? 0;

        knownKeyToValue[KnownKey.revenue_percentage] =
            ((0.156 / 6.2055 / revenueAmount) * (loanAmount * 10));
      } else if (key == KnownKey.desired_repayment_delay) {
        knownKeyToValue[KnownKey.desired_repayment_delay] =
            filterNumbers(value);
      }
    });
  }

  void init() {
    fetchData().then((res) {
      if (res.statusCode == 200) {
        List decodedJson = jsonDecode(res.body);
        for (var json in decodedJson) {
          var metadata = Metadata.fromJson(json);
          setState(() {
            switch (metadata.name) {
              case 'revenue_amount':
                revenue = metadata;
                handleUpdate(
                  key: KnownKey.revenue_amount,
                  value: fromDollars(metadata.placeholder),
                );
                break;
              case 'funding_amount':
                fundingAmount = metadata;
                break;
              case 'revenue_percentage':
                revenuePercentage = metadata;
                break;
              case 'revenue_shared_frequency':
                revenueSharedFrequency = metadata;
                break;
              case 'desired_repayment_delay':
                desiredRepaymentDelay = metadata;
                break;
              case 'use_of_funds':
                useOfFunds = metadata;
                break;
            }
          });
        }
      }
    });
  }

  @override
  void initState() {
    init();
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
          FinancingOptions(
            knownKeyToValue: knownKeyToValue,
            handleUpdate: handleUpdate,
            revenue: revenue,
            fundingAmount: fundingAmount,
            revenuePercentage: revenuePercentage,
            revenueSharedFrequency: revenueSharedFrequency,
            desiredRepaymentDelay: desiredRepaymentDelay,
            useOfFunds: useOfFunds,
          ),
          Results(
            knownKeyToValue: knownKeyToValue,
          ),
        ],
      ),
    );
  }
}
