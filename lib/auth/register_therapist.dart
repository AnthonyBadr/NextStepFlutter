import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class Therapist_Register extends StatefulWidget {
  final Map<String, dynamic> userData;

  const Therapist_Register({Key? key, required this.userData}) : super(key: key);

  @override
  _TherapistRegisterState createState() => _TherapistRegisterState();
}

class _TherapistRegisterState extends State<Therapist_Register> {
  final _formKey = GlobalKey<FormState>();
  final _graduationDateController = TextEditingController();
  DateTime? _selectedDate;

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _graduationDateController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  @override
  void dispose() {
    _graduationDateController.dispose();
    super.dispose();
  }

  Widget _buildDatePicker(String label, TextEditingController controller, BuildContext context) {
    return TextFormField(
      controller: controller,
      readOnly: true,
      decoration: InputDecoration(
        labelText: label,
        suffixIcon: IconButton(
          icon: const Icon(Icons.calendar_today),
          onPressed: () => _selectDate(context),
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please select a date';
        }
        return null;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Graduation Date')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              _buildDatePicker('Date of Graduation', _graduationDateController, context),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    widget.userData['graduationDate'] = _graduationDateController.text;
                    print('Final User Data: ${widget.userData}');
                    // Implement your data processing logic here
                  }
                },
                child: const Text('Submit'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
