import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  final String _apiKey = "YOUR__API__KEY";

  final String _baseUrl =
      "http://api.exchangeratesapi.io/v1/latest?access_key=";

  final Map<String, double> _currencies = {};

  String _activeCurrency = "USD";

  double result = 0;
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _getData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppbar(),
      body: _currencies.isNotEmpty
          ? _buildBody()
          : const Center(
              child: CircularProgressIndicator(),
            ),
    );
  }

  AppBar _buildAppbar() {
    return AppBar(
      title: const Text("Currency Exchange"),
    );
  }

  Widget _buildBody() {
    return Padding(
        padding: const EdgeInsets.all(16.0), child: _buildExchangeColumn());
  }

  Widget _buildExchangeColumn() {
    return Column(
      children: [
        _buildExchangeRow(),
        const SizedBox(
          height: 16,
        ),
        Text(
          "₺${result.toStringAsFixed(2)}",
          style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w500),
        ),
        Container(
          margin: const EdgeInsets.only(top: 10, bottom: 10),
          color: Colors.black,
          height: 1,
        ),
        Expanded(
          child: ListView.builder(
              itemCount: _currencies.keys.length, itemBuilder: _buildListItem),
        )
      ],
    );
  }

  Widget _buildExchangeRow() {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _controller,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onChanged: (String newVal) {
              _calculate();
            },
          ),
        ),
        const SizedBox(
          width: 16,
        ),
        DropdownButton<String>(
            value: _activeCurrency,
            icon: const Icon(
              Icons.arrow_downward_outlined,
              size: 18,
            ),
            underline: const SizedBox(),
            items: _currencies.keys.map((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
            onChanged: (String? value) {
              if (value != null) {
                _activeCurrency = value;
                _calculate();
              }
            })
      ],
    );
  }

  Widget _buildListItem(BuildContext context, int index) {
    return ListTile(
      title: Text(_currencies.keys.toList()[index]),
      trailing: Text(
        "₺${_currencies.values.toList()[index].toStringAsFixed(2)}",
        style: const TextStyle(fontSize: 12),
      ),
    );
  }

  void _calculate() {
    double? val = double.tryParse(_controller.text);
    double? currVal = _currencies[_activeCurrency];

    if (val != null && currVal != null) {
      setState(() {
        result = val * currVal;
      });
    }
  }

  void _getData() async {
    Uri uri = Uri.parse(_baseUrl + _apiKey);
    http.Response response = await http.get(uri);

    Map<String, dynamic> parsedResponse = jsonDecode(response.body);

    Map<String, dynamic> rates = parsedResponse["rates"];
    double? baseTL = rates["TRY"];

    if (baseTL != null) {
      for (String curr in rates.keys) {
        var baseCurr = rates[curr];
        if (baseCurr != null) {
          double tlVal = baseTL / baseCurr;
          _currencies[curr] = tlVal;
        }
      }
      setState(() {});
    }
  }
}

/*
  {
      "success": true,
      "timestamp": 1519296206,
      "base": "EUR",
      "date": "2021-03-17",
      "rates": {
          "AUD": 1.566015,
          "CAD": 1.560132,
          "CHF": 1.154727,
          "CNY": 7.827874,
          "GBP": 0.882047,
          "JPY": 132.360679,
          "USD": 1.23396,
      [...]
      }
  }
*/