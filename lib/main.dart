import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

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
      home: SalaryPredictorApp(),
    );
  }
}

class SalaryPredictorApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Salary Predictor',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: SalaryForm(),
    );
  }
}

class SalaryForm extends StatefulWidget {
  @override
  _SalaryFormState createState() => _SalaryFormState();
}

class _SalaryFormState extends State<SalaryForm> {
  final _formKey = GlobalKey<FormState>();
  final _yearsExperienceController = TextEditingController();
  final _BachelorController = TextEditingController();
  final _MasterController = TextEditingController();
  final _PhDController = TextEditingController();
  final _ageController = TextEditingController();

  String _predictedSalary = "";

  // Function to call the Flask API
  Future<void> _predictSalary() async {
    final String apiUrl = "http://192.168.1.8:5000/predict"; // Your Flask API

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "years_experience": int.tryParse(_yearsExperienceController.text),
          "education_level": _BachelorController.text,
          "Master": _MasterController.text,
          "PhD": _PhDController.text,
          "age": int.tryParse(_ageController.text),
        }),
      );

      // Log the response
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}'); // Print the response body

      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);

        // Ensure result contains 'predicted_salary'
        if (result.containsKey('predicted_salary')) {
          double predictedSalary = result['predicted_salary'];

          // Check if salary is a valid number
          if (predictedSalary.isInfinite || predictedSalary.isNaN) {
            setState(() {
              _predictedSalary = "Invalid predicted salary (Infinity or NaN)";
            });
          } else {
            setState(() {
              _predictedSalary = predictedSalary.toStringAsFixed(2);
            });
          }
        } else {
          // Handle if the key 'predicted_salary' is missing
          setState(() {
            _predictedSalary = "Error: Predicted salary not found in response";
          });
        }
      } else {
        setState(() {
          _predictedSalary =
              "Failed to predict salary (Error ${response.statusCode})";
        });
      }
    } catch (e) {
      print("Request failed: $e");
      setState(() {
        _predictedSalary = "Error occurred while predicting salary: $e";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Salary Predictor'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
              TextFormField(
                controller: _yearsExperienceController,
                decoration: InputDecoration(labelText: 'Years of Experience'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your years of experience';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _BachelorController,
                decoration: InputDecoration(labelText: 'Bachelor'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your education level';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _MasterController,
                decoration: InputDecoration(labelText: 'Master'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your education level';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _PhDController,
                decoration: InputDecoration(labelText: 'PhD'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your education level';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _ageController,
                decoration: InputDecoration(labelText: 'Age'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your age';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _predictSalary();
                  }
                },
                child: Text('Predict Salary'),
              ),
              SizedBox(height: 20),
              Text(
                _predictedSalary.isNotEmpty
                    ? 'Predicted Salary: $_predictedSalary'
                    : '',
                style: TextStyle(fontSize: 18),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
