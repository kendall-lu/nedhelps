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

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

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

class MyComponent extends StatefulWidget {
  const MyComponent({super.key});

  @override
  State<MyComponent> createState() => _MyComponentState();
}

class _MyComponentState extends State<MyComponent> {
  Metadata? revenue;
  @override
  void initState() {
    fetchData().then((res) {
      if (res.statusCode == 200) {
        List decodedJson = jsonDecode(res.body);
        decodedJson.forEach((json) {
          var metadata = Metadata.fromJson(json);
          setState(() {
            if (metadata.name == 'revenue_amount') {
              revenue = metadata;
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
      // width: 750,
      // height: 500,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: FinancingOptions(
              revenue: revenue,
            ),
          ),
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(color: Colors.blue),
          ),
          Expanded(
            child: Placeholder(),
          ),
        ],
      ),
    );
  }
}

class FinancingOptions extends StatefulWidget {
  final Metadata? revenue;
  const FinancingOptions({
    super.key,
    this.revenue,
  });

  @override
  State<FinancingOptions> createState() => _FinancingOptionsState();
}

class _FinancingOptionsState extends State<FinancingOptions> {
  TextEditingController? financingOptionsController;
  int? initialValue;
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
    Metadata? revenue = widget.revenue;
    String initialValue = revenue != null
        ? int.parse(revenue.placeholder.replaceAll(RegExp(r'[^\w\s]+'), ''))
            .toString()
        : '';
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
            if (initialValue.isNotEmpty)
              TextFormField(
                autovalidateMode: AutovalidateMode.always,
                keyboardType: TextInputType.number,
                controller: financingOptionsController,
                initialValue: initialValue,
                decoration: InputDecoration(
                  prefixIcon: Text("\$"),
                  hintText: revenue?.label ?? '',
                ),
              ),
          ],
        )));
  }
}
