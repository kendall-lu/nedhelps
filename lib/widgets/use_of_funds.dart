import 'package:flutter/material.dart';
import 'package:nedhelps/classes/metadata.dart';
import 'package:nedhelps/main.dart';

class UseOfFunds extends StatefulWidget {
  final Metadata? useOfFunds;
  final Map<KnownKey, dynamic> knownKeyToValue;
  final void Function({required KnownKey key, required dynamic value})
      handleUpdate;

  const UseOfFunds({
    super.key,
    required this.knownKeyToValue,
    required this.handleUpdate,
    this.useOfFunds,
  });

  @override
  State<UseOfFunds> createState() => _UseOfFundsState();
}

class _UseOfFundsState extends State<UseOfFunds> {
  String? useOfFund;
  String? description;
  String? amount;

  List<Map<dynamic, dynamic>> usages = [];

  void handleAdd() {
    if (useOfFund != null && description != null && amount != null) {
      setState(() {
        usages.add({
          'useOfFund': useOfFund,
          'description': description,
          'amount': amount,
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.useOfFunds != null
        ? Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(widget.useOfFunds?.label ?? ''),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  DropdownMenu(
                      onSelected: (val) {
                        setState(() {
                          useOfFund = val;
                        });
                      },
                      dropdownMenuEntries:
                          widget.useOfFunds!.value.split('*').map((val) {
                        return DropdownMenuEntry(value: val, label: val);
                      }).toList()),
                  SizedBox(
                    width: 100,
                    child: TextFormField(
                      onChanged: (val) {
                        setState(() {
                          description = val;
                        });
                      },
                      decoration: InputDecoration(labelText: 'Description'),
                    ),
                  ),
                  SizedBox(
                      width: 100,
                      child: TextFormField(
                        onChanged: (val) {
                          setState(() {
                            amount = val;
                          });
                        },
                        decoration: InputDecoration(labelText: 'Amount'),
                      )),
                  FloatingActionButton(
                    onPressed: handleAdd,
                    child: Icon(Icons.add),
                  )
                ],
              ),
              ...usages.asMap().entries.map((usageEntry) {
                var idx = usageEntry.key;
                var usage = usageEntry.value;
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ...usage.entries.map((entry) {
                      return Text(entry.value);
                    }),
                    FloatingActionButton(
                      onPressed: () {
                        setState(() {
                          usages.removeAt(idx);
                        });
                      },
                      child: Icon(Icons.delete),
                    )
                  ],
                );
              })
            ],
          )
        : SizedBox.shrink();
  }
}
