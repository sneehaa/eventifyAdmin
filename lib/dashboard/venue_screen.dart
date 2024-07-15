import 'dart:io';

import 'package:eventify_admin/core/flutter_secure_storage/flutter_secure_Storage.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:logger/logger.dart';
import 'package:path/path.dart';

class AdminVenueCreationPage extends StatefulWidget {
  const AdminVenueCreationPage({super.key});

  @override
  State<AdminVenueCreationPage> createState() => _AdminVenueCreationPageState();
}

class _AdminVenueCreationPageState extends State<AdminVenueCreationPage> {
  final int _selectedIndex = 0;
  bool _showSuccessMessage = false;
  bool _isVenueCreated = false;
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  List<File> _image = [];
  final ImagePicker _picker = ImagePicker();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController locationController = TextEditingController();
  final TextEditingController priceController = TextEditingController();

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
          _image = pickedFiles.map((file) => File(file.path)).toList();
        });
      }
    } catch (e) {
      logger.e('Error picking image: $e');
    }
  }

  Future<void> createVenue(BuildContext context) async {
    final url = Uri.parse('http://192.168.68.109:5500/api/venues/create-venue');
    try {
      final token = await SecureStorage().readToken();

      var request = http.MultipartRequest('POST', url)
        ..headers['Authorization'] = 'Bearer $token'
        ..fields['name'] = nameController.text
        ..fields['location'] = locationController.text
        ..fields['price'] = priceController.text;

      // Adding image to request
      if (_image.isNotEmpty) {
        for (var i = 0; i < _image.length; i++) {
          final file = _image[i];
          final fileName = basename(file.path);
          final stream = http.ByteStream(Stream.castFrom(file.openRead()));
          final length = await file.length();

          final multipartFile = http.MultipartFile(
            'image',
            stream,
            length,
            filename: fileName,
          );

          request.files.add(multipartFile);
        }
      } else {
        request.fields['image'] = [] as String;
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 201) {
        print('Venue created successfully');
        setState(() {
          _isVenueCreated = true;
          _showSuccessMessage = true;
        });
      } else {
        print('Failed to create venue. Status code: ${response.statusCode}');
        print('Response body: ${response.body}');
      }
    } catch (e) {
      print('Error creating venue: $e');
    }
  }

  Widget _buildImageGrid() {
    if (_image.isNotEmpty) {
      int crossAxisCount = 1;
      if (_image.length == 2) {
        crossAxisCount = 2;
      } else if (_image.length >= 3) {
        crossAxisCount = 3;
      }

      return GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          crossAxisSpacing: 8.0,
          mainAxisSpacing: 8.0,
        ),
        itemCount: _image.length,
        itemBuilder: (context, index) {
          return Image.file(
            _image[index],
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
              'Create Venue',
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
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              if (!_isVenueCreated)
                GestureDetector(
                  onTap: _getImageFromGallery,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Add image:',
                        style: GoogleFonts.libreBaskerville(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8.0),
                      Text(
                        'image that best describe your event (Add up to 5 image)',
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
                        child: _image.isEmpty
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
              if (!_isVenueCreated)
                Text(
                  'Venue Name',
                  style: GoogleFonts.libreBaskerville(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: const Color(0x99232A36),
                  ),
                ),
              const SizedBox(height: 8.0),
              if (!_isVenueCreated)
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
                          controller: nameController,
                          textAlign: TextAlign.left,
                          style: const TextStyle(fontSize: 12),
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            hintText: 'Venue Name',
                            hintStyle: TextStyle(fontSize: 12),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 16.0),
              if (!_isVenueCreated)
                Text(
                  'Location',
                  style: GoogleFonts.libreBaskerville(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: const Color(0x99232A36),
                  ),
                ),
              const SizedBox(height: 8.0),
              if (!_isVenueCreated)
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
                          controller: locationController,
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
              if (!_isVenueCreated)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8.0),
                    // General Ticket Price
                    Text(
                      'Venue Prices',
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
                              controller: priceController,
                              keyboardType: TextInputType.number,
                              textAlign: TextAlign.left,
                              style: const TextStyle(fontSize: 12),
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                                hintText: 'Venue Price',
                                hintStyle: TextStyle(fontSize: 12),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 32.0),
                    if (!_isVenueCreated)
                      Center(
                        child: ElevatedButton(
                          onPressed: () => createVenue(context),
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
                                'Venue created successfully!',
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
                                'Venue created successfully!',
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
            ]),
          ),
        ));
  }
}
