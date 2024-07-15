import 'dart:convert';
import 'dart:io';

import 'package:eventify_admin/core/flutter_secure_storage/flutter_secure_Storage.dart';
import 'package:eventify_admin/core/snackbar/snackbar.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';
import 'package:path/path.dart';

class AdminAddEventPage extends StatefulWidget {
  const AdminAddEventPage({super.key});

  @override
  State<AdminAddEventPage> createState() => _AdminAddEventPageState();
}

class _AdminAddEventPageState extends State<AdminAddEventPage> {
  final int _selectedIndex = 0;
  bool _showSuccessMessage = false;
  bool _isEventCreated = false;
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  List<File> _images = [];
  final ImagePicker _picker = ImagePicker();
  final TextEditingController _eventNameController = TextEditingController();
  final TextEditingController _eventDateController = TextEditingController();
  final TextEditingController _eventTimeController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _generalPriceController = TextEditingController();
  final TextEditingController _fanpitPriceController = TextEditingController();
  final TextEditingController _vipPriceController = TextEditingController();
  final Logger logger = Logger(printer: PrettyPrinter());

  Future<void> _getImageFromGallery() async {
    try {
      final List<XFile> pickedFiles = await _picker.pickMultiImage(
        maxWidth: 800,
        maxHeight: 600,
        imageQuality: 80,
      );

      if (pickedFiles.isNotEmpty) {
        setState(() {
          _images = pickedFiles.map((file) => File(file.path)).toList();
        });
      }
    } catch (e) {
      logger.e('Error picking images: $e');
    }
  }

  Future<void> _createEvent(BuildContext context) async {
    if (_eventNameController.text.isEmpty ||
        _eventDateController.text.isEmpty ||
        _eventTimeController.text.isEmpty ||
        _locationController.text.isEmpty ||
        _generalPriceController.text.isEmpty ||
        _fanpitPriceController.text.isEmpty ||
        _vipPriceController.text.isEmpty) {
      showSnackBar(
        message: 'Please fill all fields',
        context: context,
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
      return;
    }

    try {
      final url =
          Uri.parse('http://192.168.68.109:5500/api/admin/events/create');
      final token = await SecureStorage().readToken();
      if (token == null) {
        throw Exception('Token not found');
      }

      final request = http.MultipartRequest('POST', url);
      request.headers['Authorization'] = 'Bearer $token';

      // Adding fields to request
      request.fields['adminEventName'] = _eventNameController.text;
      request.fields['adminEventDate'] = _eventDateController.text;
      request.fields['adminEventTime'] = _eventTimeController.text;
      request.fields['adminLocation'] = _locationController.text;

      final generalPrice =
          _generalPriceController.text.replaceAll(RegExp(r'[^0-9.]'), '');
      final fanpitPrice =
          _fanpitPriceController.text.replaceAll(RegExp(r'[^0-9.]'), '');
      final vipPrice =
          _vipPriceController.text.replaceAll(RegExp(r'[^0-9.]'), '');

      request.fields['adminGeneralPrice'] = generalPrice;
      request.fields['adminFanpitPrice'] = fanpitPrice;
      request.fields['adminVipPrice'] = vipPrice;

      // Adding images to request
      if (_images.isNotEmpty) {
        for (var i = 0; i < _images.length; i++) {
          final file = _images[i];
          final fileName = basename(file.path);
          final stream = http.ByteStream(Stream.castFrom(file.openRead()));
          final length = await file.length();

          final multipartFile = http.MultipartFile(
            'images',
            stream,
            length,
            filename: fileName,
          );

          request.files.add(multipartFile);
        }
      } else {
        request.fields['images'] = [] as String;
      }

      // Print statements to log fields before sending request
      logger.d('Event name: ${_eventNameController.text}');
      logger.d('Event date: ${_eventDateController.text}');
      logger.d('Event time: ${_eventTimeController.text}');
      logger.d('Location: ${_locationController.text}');
      logger.d('General price: ${_generalPriceController.text}');
      logger.d('Fanpit price: ${_fanpitPriceController.text}');
      logger.d('VIP price: ${_vipPriceController.text}');
      logger.d('Images count: ${_images.length}');

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = jsonDecode(response.body);
        logger.i('Event created successfully: $responseData');
        setState(() {
          _isEventCreated = true;
          _showSuccessMessage = true;
        });
      } else {
        logger.e('Failed to create event. Status code: ${response.statusCode}');
        logger.e('Response body: ${response.body}');
      }
    } catch (e) {
      logger.e('Error creating event: $e');
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2015, 8),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        _eventDateController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        _selectedTime = picked;
        _eventTimeController.text = picked.format(context);
      });
    }
  }

  Widget _buildImageGrid() {
    if (_images.isNotEmpty) {
      int crossAxisCount = 1;
      if (_images.length == 2) {
        crossAxisCount = 2;
      } else if (_images.length >= 3) {
        crossAxisCount = 3;
      }

      return GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          crossAxisSpacing: 8.0,
          mainAxisSpacing: 8.0,
        ),
        itemCount: _images.length,
        itemBuilder: (context, index) {
          return Image.file(
            _images[index],
            fit: BoxFit.fitHeight,
          );
        },
      );
    } else {
      return const SizedBox.shrink();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        toolbarHeight: 70,
        backgroundColor: const Color(0xFFFFF0BC),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: Center(
          child: Text(
            'Create Your Event',
            style: GoogleFonts.libreBaskerville(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (!_isEventCreated)
                GestureDetector(
                  onTap: _getImageFromGallery,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Add Images:',
                        style: GoogleFonts.libreBaskerville(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8.0),
                      Text(
                        'Images that best describe your event (Add up to 5 images)',
                        style: GoogleFonts.libreBaskerville(
                          fontSize: 12,
                          color: const Color.fromARGB(128, 14, 27, 48),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16.0),
                      Container(
                        height: 240,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        child: _images.isEmpty
                            ? const Center(
                                child: Icon(
                                  Icons.add_a_photo,
                                  size: 40,
                                ),
                              )
                            : _buildImageGrid(),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 16.0),
              if (!_isEventCreated)
                Text(
                  'Event Name',
                  style: GoogleFonts.libreBaskerville(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: const Color(0x99232A36),
                  ),
                ),
              const SizedBox(height: 8.0),
              if (!_isEventCreated)
                Container(
                  height: 49,
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFAFAFF),
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(13.0),
                  ),
                  child: Row(
                    children: [
                      Image.asset('assets/icons/event.png',
                          width: 23, height: 23),
                      const SizedBox(width: 8.0),
                      Expanded(
                        child: TextField(
                          controller: _eventNameController,
                          textAlign: TextAlign.left,
                          style: const TextStyle(fontSize: 12),
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            hintText: 'Event Name',
                            hintStyle: TextStyle(fontSize: 12),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 16.0),
              if (!_isEventCreated)
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Event Date',
                            style: GoogleFonts.libreBaskerville(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: const Color(0x99232A36),
                            ),
                          ),
                          const SizedBox(height: 8.0),
                          GestureDetector(
                            onTap: () => _selectDate(context),
                            child: Container(
                              height: 49,
                              width: double.infinity,
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16.0),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFAFAFF),
                                border: Border.all(color: Colors.grey),
                                borderRadius: BorderRadius.circular(13.0),
                              ),
                              child: Row(
                                children: [
                                  Image.asset('assets/icons/calendar.png',
                                      width: 23, height: 23),
                                  const SizedBox(width: 8.0),
                                  Expanded(
                                    child: TextField(
                                      controller: _eventDateController,
                                      textAlign: TextAlign.left,
                                      enabled: false,
                                      style: const TextStyle(fontSize: 12),
                                      decoration: const InputDecoration(
                                        border: InputBorder.none,
                                        hintText: 'Event Date',
                                        hintStyle: TextStyle(fontSize: 12),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16.0),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Event Time',
                            style: GoogleFonts.libreBaskerville(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: const Color(0x99232A36),
                            ),
                          ),
                          const SizedBox(height: 8.0),
                          GestureDetector(
                            onTap: () => _selectTime(context),
                            child: Container(
                              height: 49,
                              width: double.infinity,
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16.0),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFAFAFF),
                                border: Border.all(color: Colors.grey),
                                borderRadius: BorderRadius.circular(13.0),
                              ),
                              child: Row(
                                children: [
                                  Image.asset('assets/icons/time.png',
                                      width: 23, height: 23),
                                  const SizedBox(width: 8.0),
                                  Expanded(
                                    child: TextField(
                                      controller: _eventTimeController,
                                      textAlign: TextAlign.left,
                                      enabled: false,
                                      style: const TextStyle(fontSize: 12),
                                      decoration: const InputDecoration(
                                        border: InputBorder.none,
                                        hintText: 'Event Time',
                                        hintStyle: TextStyle(fontSize: 12),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              const SizedBox(height: 16.0),
              if (!_isEventCreated)
                Text(
                  'Location',
                  style: GoogleFonts.libreBaskerville(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: const Color(0x99232A36),
                  ),
                ),
              const SizedBox(height: 8.0),
              if (!_isEventCreated)
                Container(
                  height: 49,
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFAFAFF),
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(13.0),
                  ),
                  child: Row(
                    children: [
                      Image.asset('assets/icons/location.png',
                          width: 23, height: 23),
                      const SizedBox(width: 8.0),
                      Expanded(
                        child: TextField(
                          controller: _locationController,
                          textAlign: TextAlign.left,
                          style: const TextStyle(fontSize: 12),
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            hintText: 'Location',
                            hintStyle: TextStyle(fontSize: 12),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 16.0),
              if (!_isEventCreated)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Ticket Prices',
                      style: GoogleFonts.libreBaskerville(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: const Color(0x99232A36),
                      ),
                    ),
                    const SizedBox(height: 8.0),
                    // General Ticket Price
                    Text(
                      'General Ticket Price',
                      style: GoogleFonts.libreBaskerville(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: const Color(0x99232A36),
                      ),
                    ),
                    const SizedBox(height: 8.0),
                    Container(
                      height: 49,
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFAFAFF),
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(13.0),
                      ),
                      child: Row(
                        children: [
                          Image.asset('assets/icons/price.png',
                              width: 23, height: 23),
                          const SizedBox(width: 8.0),
                          Expanded(
                            child: TextField(
                              controller: _generalPriceController,
                              keyboardType: TextInputType.number,
                              textAlign: TextAlign.left,
                              style: const TextStyle(fontSize: 12),
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                                hintText: 'General Ticket Price',
                                hintStyle: TextStyle(fontSize: 12),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16.0),

                    // Fanpit Ticket Price
                    Text(
                      'Fanpit Ticket Price',
                      style: GoogleFonts.libreBaskerville(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: const Color(0x99232A36),
                      ),
                    ),
                    const SizedBox(height: 8.0),
                    Container(
                      height: 49,
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFAFAFF),
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(13.0),
                      ),
                      child: Row(
                        children: [
                          Image.asset('assets/icons/price.png',
                              width: 23, height: 23),
                          const SizedBox(width: 8.0),
                          Expanded(
                            child: TextField(
                              controller: _fanpitPriceController,
                              keyboardType: TextInputType.number,
                              textAlign: TextAlign.left,
                              style: const TextStyle(fontSize: 12),
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                                hintText: 'Fanpit Ticket Price',
                                hintStyle: TextStyle(fontSize: 12),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16.0),

                    // VIP Ticket Price
                    Text(
                      'VIP Ticket Price',
                      style: GoogleFonts.libreBaskerville(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: const Color(0x99232A36),
                      ),
                    ),
                    const SizedBox(height: 8.0),
                    Container(
                      height: 49,
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFAFAFF),
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(13.0),
                      ),
                      child: Row(
                        children: [
                          Image.asset('assets/icons/price.png',
                              width: 23, height: 23),
                          const SizedBox(width: 8.0),
                          Expanded(
                            child: TextField(
                              controller: _vipPriceController,
                              keyboardType: TextInputType.number,
                              textAlign: TextAlign.left,
                              style: const TextStyle(fontSize: 12),
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                                hintText: 'VIP Ticket Price',
                                hintStyle: TextStyle(fontSize: 12),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              const SizedBox(height: 32.0),
              if (!_isEventCreated)
                Center(
                  child: ElevatedButton(
                    onPressed: () => _createEvent(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFF29649),
                      minimumSize: const Size(310, 49),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(13.0),
                      ),
                    ),
                    child: Text(
                      'Create Event',
                      style: GoogleFonts.libreBaskerville(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              if (_showSuccessMessage)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 24.0),
                    child: Column(
                      children: [
                        const Icon(Icons.check_circle,
                            color: Colors.green, size: 80),
                        const SizedBox(height: 16.0),
                        Text(
                          'Event created successfully!',
                          style: GoogleFonts.libreBaskerville(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
