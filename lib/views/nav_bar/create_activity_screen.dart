// lib/views/nav_bar/create_activity_screen.dart
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

import 'package:move_m8/config/api_config.dart';
import 'package:move_m8/enums/level.dart';
import 'package:move_m8/models/activity_model.dart';
import 'package:move_m8/models/community_model.dart';
import 'package:move_m8/models/sport_model.dart';
import 'package:move_m8/models/user_model.dart';

import 'package:move_m8/services/activity_service.dart';
import 'package:move_m8/services/auth_service.dart';
import 'package:move_m8/services/user_service.dart';

import '../activity/activity_detail_screen.dart';
import '../activity/choose_category_screen.dart';

import '../../widgets/less_fab.dart';
import '../../widgets/plus_fab.dart';

class CreateActivityScreen extends StatefulWidget {
  final CommunityModel community;
  const CreateActivityScreen({Key? key, required this.community}) : super(key: key);

  @override
  State<CreateActivityScreen> createState() => _CreateActivityScreenState();
}

class _CreateActivityScreenState extends State<CreateActivityScreen> {
  final _formKey = GlobalKey<FormState>();

  // UI state
  List<File> _selectedImages = [];
  Level? _selectedLevel;
  String? _title;
  String? _address;
  String? _price;
  String? _description;
  int _participants = 1;
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  SportModel? _selectedSport;

  // user
  UserModel? _me;

  @override
  void initState() {
    super.initState();
    // charge l'utilisateur courant au montage
    UserService().getMyProfile().then((u) {
      if (mounted) setState(() => _me = u);
    });
  }

  // -------- Helpers --------

  void _goBackToHome() => Navigator.of(context).pop();

  int? _ageFromBirthday(DateTime? b) {
    if (b == null) return null;
    final now = DateTime.now();
    var age = now.year - b.year;
    if (now.month < b.month || (now.month == b.month && now.day < b.day)) {
      age--;
    }
    return age;
  }

  Future<void> _pickImages() async {
    final picker = ImagePicker();
    final images = await picker.pickMultiImage();
    if (!mounted || images.isEmpty) return;

    if (images.length + _selectedImages.length > 5) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('5 photos maximum')),
      );
      return;
    }
    setState(() {
      _selectedImages.addAll(images.map((x) => File(x.path)));
    });
  }

  Future<String?> _uploadFirstCoverIfAny() async {
    if (_selectedImages.isEmpty) return null;

    final token = await AuthService().getToken();
    if (token == null || token.isEmpty) {
      throw Exception('Session expirée. Reconnectez-vous.');
    }

    final uri = ApiConfig.path(['files', 'upload'])
        .replace(queryParameters: {'type': 'activities'});

    final req = http.MultipartRequest('POST', uri)
      ..headers['Authorization'] = 'Bearer $token'
      ..files.add(await http.MultipartFile.fromPath('file', _selectedImages.first.path));

    final res = await req.send();
    final raw = await res.stream.bytesToString();

    if (res.statusCode == 200) {
      // backend peut renvoyer l’URL brute (string) ou un JSON
      String url;
      final trimmed = raw.trim();
      if (trimmed.startsWith('{')) {
        final data = jsonDecode(trimmed);
        url = (data['url'] as String).trim();
      } else {
        url = trimmed.replaceAll('"', '').trim();
      }
      return ApiConfig.fixImageHost(url);
    }
    throw Exception('Erreur upload couverture: $raw');
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  Future<void> _selectTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) setState(() => _selectedTime = picked);
  }

  bool _validateBeforeCreate() {
    if (_selectedLevel == null) {
      _toast('Choisis un niveau.');
      return false;
    }
    if (_selectedSport == null) {
      _toast('Choisis un sport.');
      return false;
    }
    if (_selectedDate == null || _selectedTime == null) {
      _toast('Choisis une date et une heure.');
      return false;
    }
    if (_formKey.currentState == null) return false;
    if (!_formKey.currentState!.validate()) return false;
    return true;
  }

  void _toast(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  // -------- Submit --------

  Future<void> _submitForm() async {
    try {
      if (!_validateBeforeCreate()) return;
      _formKey.currentState!.save();

      // 1) utilisateur courant si pas encore chargé
      _me ??= await UserService().getMyProfile();

      // 2) compose la DateTime & le prix
      final dateHour = DateTime(
        _selectedDate!.year,
        _selectedDate!.month,
        _selectedDate!.day,
        _selectedTime!.hour,
        _selectedTime!.minute,
      );

      final priceDouble =
          double.tryParse((_price ?? '').replaceAll(',', '.')) ?? 0.0;

      // 3) upload éventuel de la couverture
      final coverUrl = await _uploadFirstCoverIfAny();

      // 4) requête API (ActivityService sans baseUrl, il utilise ApiConfig en interne)
      final svc = ActivityService();

      final req = CreateActivityRequest(
        title: (_title?.trim().isNotEmpty ?? false)
            ? _title!.trim()
            : (_selectedSport?.sportName ?? 'Activity'),
        description: _description?.trim() ?? '',
        location: _address?.trim() ?? '',
        dateHour: dateHour,
        price: priceDouble,
        numberOfParticipant: _participants,
        level: _selectedLevel!,      // déjà validé
        sportId: _selectedSport!.id, // déjà validé
        photo: coverUrl,             // peut être null
      );

      final created = await svc.create(req);

      // 5) navigation → détail
      if (!mounted) return;
      FocusScope.of(context).unfocus();
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => ActivityDetailScreen(activity: created)),
      );
    } catch (e, st) {
      // ignore: avoid_print
      print('CreateActivityScreen _submitForm error: $e\n$st');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur: $e')),
      );
    }
  }


 // -------- UI --------


// --- helpers clavier/FAB ---
double _effectiveKeyboardPadding(BuildContext context) {
  final mq   = MediaQuery.of(context);
  final kb   = mq.viewInsets.bottom;   // hauteur du clavier
  final safe = mq.viewPadding.bottom;  // inset home-indicator iOS (~34)
  final pad  = kb - safe;              // on enlève le safe-area
  return pad > 0 ? pad : 0;
}

double _fabOverlapPadding(BuildContext context) {
  // marge pour que le bouton Create ne passe pas sous ton gros FAB central
  return 88.0; // ajuste 72–104 selon la taille de ton FAB
}

// --- build ---
@override
Widget build(BuildContext context) {
  final kbPad  = _effectiveKeyboardPadding(context);
  final fabPad = _fabOverlapPadding(context);

  return WillPopScope(
    onWillPop: () async { _goBackToHome(); return false; },
    child: Scaffold(
      // on gère nous-mêmes le padding clavier → éviter le double-padding
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        bottom: false, // pas d’espace en plus sous le clavier
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: SingleChildScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            padding: EdgeInsets.only(
              left: 16, right: 16, top: 16,
              bottom: kbPad + fabPad, // colle au clavier + marge pour le FAB
            ),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  const Text(
                    'Suggest an activity',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),

                  // ---- Images ----
                  GestureDetector(
                    onTap: _pickImages,
                    child: Container(
                      height: 160,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: _selectedImages.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.add, size: 36, color: _getSelectedColor()),
                                  const SizedBox(height: 4),
                                  const Text("jusqu'à 5 photos maximum",
                                      style: TextStyle(color: Colors.grey)),
                                ],
                              ),
                            )
                          : ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: _selectedImages.length,
                              itemBuilder: (_, i) => Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Image.file(
                                  _selectedImages[i],
                                  width: 100,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // ---- Niveau ----
                  const Text('Niveau de l’activité',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: Level.values.map((level) {
                      final isSelected = _selectedLevel == level;
                      return ChoiceChip(
                        label: Text(level.label),
                        selected: isSelected,
                        onSelected: (_) => setState(() => _selectedLevel = level),
                        selectedColor: Color(_hexToColor(level.color)),
                        backgroundColor: Colors.grey[200],
                        labelStyle: TextStyle(
                          color: isSelected ? Colors.white : Colors.black,
                        ),
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 24),

                  // ---- Sport choisi / picker ----
                  _selectedSport != null
                      ? Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                          decoration: BoxDecoration(
                            color: _getSelectedColor(),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              if (_selectedSport!.iconUrl != null)
                                Image.network(
                                  ApiConfig.fixImageHost(_selectedSport!.iconUrl!),
                                  width: 30, height: 30,
                                  errorBuilder: (_, __, ___) =>
                                      const Icon(Icons.sports, color: Colors.white),
                                )
                              else
                                const Icon(Icons.sports, color: Colors.white),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  _selectedSport!.sportName,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.close, color: Colors.white),
                                onPressed: () => setState(() => _selectedSport = null),
                              ),
                            ],
                          ),
                        )
                      : _buildPicker(
                          'Choose your activity',
                          null,
                          () {
                            if (_selectedLevel == null) {
                              _toast("Choisis un niveau d'abord.");
                              return;
                            }
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ChooseCategoryScreen(
                                  selectedLevel: _selectedLevel!,
                                  onSportSelected: (sport) {
                                    setState(() => _selectedSport = sport);
                                  },
                                ),
                              ),
                            );
                          },
                        ),

                  const SizedBox(height: 24),
                  const Divider(),
                  const SizedBox(height: 12),

                  // ---- Date + Heure ----
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          readOnly: true,
                          controller: TextEditingController(
                            text: _selectedDate != null
                                ? "${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}"
                                : '',
                          ),
                          decoration: const InputDecoration(
                            prefixIcon: Icon(Icons.calendar_today),
                            hintText: '12/10/2025',
                          ),
                          onTap: _selectDate,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          readOnly: true,
                          controller: TextEditingController(
                            text: _selectedTime != null
                                ? _selectedTime!.format(context)
                                : '',
                          ),
                          decoration: const InputDecoration(
                            prefixIcon: Icon(Icons.access_time),
                            hintText: '16h30',
                          ),
                          onTap: _selectTime,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // ---- Adresse ----
                  TextFormField(
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.location_on),
                      hintText: 'Address',
                    ),
                    onSaved: (val) => _address = val,
                  ),

                  const SizedBox(height: 12),

                  // ---- Prix ----
                  TextFormField(
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.euro),
                      hintText: '16€',
                    ),
                    keyboardType: TextInputType.number,
                    onSaved: (val) => _price = val,
                  ),

                  const SizedBox(height: 12),

                  // ---- Participants ----
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('Participants', style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(width: 50),
                      LessFAB(
                        onPressed: () {
                          setState(() {
                            if (_participants > 1) _participants--;
                          });
                        },
                        backgroundColor: _getSelectedColor(),
                        diameter: 50.0,
                        barLength: 30.0,
                        barThickness: 5.0,
                      ),
                      const SizedBox(width: 20),
                      Text(' $_participants',
                          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                      const SizedBox(width: 20),
                      PlusFAB(
                        onPressed: () => setState(() => _participants++),
                        backgroundColor: _getSelectedColor(),
                        diameter: 50.0,
                        barLength: 30.0,
                        barThickness: 5.0,
                      ),
                    ],
                  ),

                  const SizedBox(height: 15),

                  // ---- Titre ----
                  TextFormField(
                    decoration: const InputDecoration(hintText: 'Title for your activity?'),
                    onSaved: (val) => _title = val,
                  ),

                  const SizedBox(height: 25),

                  // ---- Description ----
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text('Tell us a little more..'),
                  ),
                  TextFormField(
                    maxLength: 100,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      hintText: 'Your text (Max 100 characters)',
                      border: OutlineInputBorder(),
                    ),
                    onSaved: (val) => _description = val,
                  ),

                  const SizedBox(height: 20),

                  // ---- Bouton Create ----
                  Center(
                    child: ElevatedButton(
                      onPressed: _submitForm,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                        backgroundColor: _getSelectedColor(),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: const Text('Create',
                          style: TextStyle(color: Colors.white, fontSize: 16)),
                    ),
                  ),

                  const SizedBox(height: 12),
                ],
              ),
            ),
          ),
        ),
      ),
    ),
  );
}


  Color _getSelectedColor() {
    if (_selectedLevel == null) return Colors.teal;
    return Color(int.parse(_selectedLevel!.color.replaceAll('#', '0xFF')));
  }

  Widget _buildPicker(String title, String? value, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Row(
          children: [
            Text(value ?? title, style: const TextStyle(fontSize: 16)),
            const Spacer(),
            const Icon(Icons.chevron_right),
          ],
        ),
      ),
    );
  }

  int _hexToColor(String hex) => int.parse(hex.substring(1), radix: 16) + 0xFF000000;
}
