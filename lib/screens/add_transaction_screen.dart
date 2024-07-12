import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:provider/provider.dart';
import '../models/transaction.dart';
import '../services/transaction_service.dart';
import '../services/auth_service.dart'; // Import AuthService here

class AddTransactionScreen extends StatefulWidget {
  @override
  _AddTransactionScreenState createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  String _name = '';
  double _amount = 0.0;
  DateTime _date = DateTime.now();
  String _type = 'income';
  File? _image;
  String _description = '';

  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      }
    });
  }

  Future<void> _submit() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      final authService = Provider.of<AuthService>(context, listen: false);
      final transactionService = Provider.of<TransactionService>(context, listen: false);
      final currentUser = authService.getCurrentUser();

      if (currentUser != null) {
        String imageUrl = '';
        if (_image != null) {
          imageUrl = await transactionService.uploadImage(_image!);
        }

        final newTransaction = Transaction(
          id: '',
          userId: authService.getCurrentUID(), // Use getCurrentUID to get userId
          name: _name,
          amount: _amount,
          date: _date,
          type: _type,
          imageUrl: imageUrl,
          description: _description,
        );

        await transactionService.addTransaction(newTransaction);

        Navigator.pop(context);
      } else {
        // Handle error if currentUser is null
        print('Error: Current user is null');
      }
    }
  }

  Future<void> _pickDate() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (pickedDate != null && pickedDate != _date) {
      setState(() {
        _date = pickedDate;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add New Transaction'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                decoration: InputDecoration(labelText: 'Name'),
                validator: (value) => value!.isEmpty ? 'Please enter a name' : null,
                onSaved: (value) => _name = value!,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Amount'),
                keyboardType: TextInputType.number,
                validator: (value) => value!.isEmpty ? 'Please enter an amount' : null,
                onSaved: (value) => _amount = double.parse(value!),
              ),
              ListTile(
                title: Text('Date: ${DateFormat.yMd().format(_date)}'),
                trailing: Icon(Icons.calendar_today),
                onTap: _pickDate,
              ),
              DropdownButtonFormField<String>(
                value: _type,
                items: ['income', 'expense']
                    .map((label) => DropdownMenuItem(
                          child: Text(label),
                          value: label,
                        ))
                    .toList(),
                onChanged: (value) => setState(() => _type = value!),
                decoration: InputDecoration(labelText: 'Type'),
              ),
              SizedBox(height: 10),
              Row(
                children: [
                  _image == null
                      ? Text('No image selected.')
                      : Image.file(
                          _image!,
                          width: 100,
                          height: 100,
                        ),
                  Spacer(),
                  IconButton(
                    icon: Icon(Icons.photo),
                    onPressed: _pickImage,
                  ),
                ],
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Description'),
                maxLines: 3,
                onSaved: (value) => _description = value!,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submit,
                child: Text('Add Transaction'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
