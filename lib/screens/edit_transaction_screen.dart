import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../models/transaction.dart';
import '../services/transaction_service.dart';

class EditTransactionScreen extends StatefulWidget {
  final Transaction transaction;

  EditTransactionScreen({required this.transaction});

  @override
  _EditTransactionScreenState createState() => _EditTransactionScreenState();
}

class _EditTransactionScreenState extends State<EditTransactionScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _typeController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  File? _imageFile; // Change _imageFile to File? here
  final ImagePicker _picker = ImagePicker();

  final TransactionService _transactionService = TransactionService();

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.transaction.name;
    _amountController.text = widget.transaction.amount.toString();
    _dateController.text = widget.transaction.date.toString();
    _typeController.text = widget.transaction.type;
    _descriptionController.text = widget.transaction.description;

    // Load existing image if available
    if (widget.transaction.imageUrl.isNotEmpty) {
      // Check if the imageUrl is a local file path or a remote URL
      if (widget.transaction.imageUrl.startsWith('http')) {
        _imageFile = null; // If imageUrl is a URL, set _imageFile to null
      } else {
        _imageFile = File(widget.transaction.imageUrl);
      }
    }
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);

    setState(() {
      if (pickedFile != null) {
        _imageFile = File(pickedFile.path);
      }
    });
  }

  Future<String> _uploadImage(File imageFile) async {
    // Replace this with your image upload logic (e.g., Firebase Storage)
    // Return the URL of the uploaded image
    String imageUrl = await _transactionService.uploadImage(imageFile);
    return imageUrl;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Transaction'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _nameController,
              decoration: InputDecoration(labelText: 'Transaction Name'),
            ),
            TextField(
              controller: _amountController,
              decoration: InputDecoration(labelText: 'Amount'),
              keyboardType: TextInputType.number,
              onChanged: (value) {
                if (_typeController.text == 'expense' && !value.startsWith('-')) {
                  _amountController.text = '-' + value;
                }
              },
            ),
            TextField(
              controller: _dateController,
              decoration: InputDecoration(labelText: 'Transaction Date'),
              readOnly: true,
              onTap: () async {
                DateTime? pickedDate = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime(2015, 8),
                  lastDate: DateTime.now(),
                );
                if (pickedDate != null) {
                  _dateController.text = pickedDate.toString();
                }
              },
            ),
            DropdownButtonFormField<String>(
              value: _typeController.text,
              items: ['income', 'expense']
                  .map((type) => DropdownMenuItem(
                        value: type,
                        child: Text(type),
                      ))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  _typeController.text = value!;
                  if (value == 'income' && _amountController.text.startsWith('-')) {
                    _amountController.text = _amountController.text.substring(1);
                  }
                });
              },
              decoration: InputDecoration(labelText: 'Transaction Type'),
            ),
            TextField(
              controller: _descriptionController,
              decoration: InputDecoration(labelText: 'Description'),
            ),
            SizedBox(height: 16.0),
            _imageFile != null
                ? Image.file(
                    _imageFile!,
                    height: 100,
                    width: 100,
                    fit: BoxFit.cover,
                  )
                : widget.transaction.imageUrl.isNotEmpty
                    ? Image.network(
                        widget.transaction.imageUrl,
                        height: 100,
                        width: 100,
                        fit: BoxFit.cover,
                      )
                    : SizedBox.shrink(),
            SizedBox(height: 8.0),
            ElevatedButton(
              onPressed: _pickImage,
              child: Text('Select Image'),
            ),
            SizedBox(height: 16.0),
            Center(
              child: ElevatedButton(
                onPressed: () async {
                  String imageUrl = widget.transaction.imageUrl;

                  if (_imageFile != null) {
                    imageUrl = await _uploadImage(_imageFile!);
                  }

                  Transaction updatedTransaction = Transaction(
                    id: widget.transaction.id,
                    userId: widget.transaction.userId,
                    name: _nameController.text,
                    amount: double.parse(_amountController.text),
                    date: DateTime.parse(_dateController.text),
                    type: _typeController.text,
                    imageUrl: imageUrl,
                    description: _descriptionController.text,
                  );

                  _transactionService.updateTransaction(updatedTransaction);

                  Navigator.pop(context);
                },
                child: Text('Update Transaction'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
