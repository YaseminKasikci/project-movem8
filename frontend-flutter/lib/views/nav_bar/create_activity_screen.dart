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
  /// Si `existing` est non nul → mode ÉDITION (prérempli, envoi PATCH partiel)
  final ActivityDetail? existing;

  const CreateActivityScreen({
    Key? key,
    required this.community,
    this.existing,
  }) : super(key: key);

  @override
  State<CreateActivityScreen> createState() => _CreateActivityScreenState();
}

class _CreateActivityScreenState extends State<CreateActivityScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final _scrollCtrl = ScrollController();
  final _titleCtrl = TextEditingController();
  final _addrCtrl  = TextEditingController();
  final _priceCtrl = TextEditingController();
  final _descCtrl  = TextEditingController();

  // UI state
  List<File> _selectedImages = [];
  Level? _selectedLevel;
  int _participants = 1;
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  SportModel? _selectedSport;

  // user
  UserModel? _me;
  final _userService = UserService();

  bool get _isEdit => widget.existing != null;

  @override
  void initState() {
    super.initState();
    _loadMe();
    _prefillIfEditing();
  }

  @override
  void dispose() {
    _scrollCtrl.dispose();
    _titleCtrl.dispose();
    _addrCtrl.dispose();
    _priceCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  // ---------------- Helpers ----------------
  Future<void> _loadMe() async {
    try {
      final me = await _userService.getMyProfile();
      if (mounted) setState(() => _me = me);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Impossible de charger ton profil")),
      );
    }
  }

  void _prefillIfEditing() {
    final ex = widget.existing;
    if (ex == null) return;

    _titleCtrl.text = ex.title;
    _addrCtrl.text  = ex.location;
    _priceCtrl.text = ex.price == 0 ? '' : ex.price.toString();
    _descCtrl.text  = ex.description;

    _selectedLevel = ex.level;
    _participants  = ex.numberOfParticipant;
    _selectedDate  = ex.dateHour;
    _selectedTime  = TimeOfDay(hour: ex.dateHour.hour, minute: ex.dateHour.minute);
    _selectedSport = (ex.sportId != null)
        ? SportModel(id: ex.sportId!, sportName: ex.sportName ?? '', iconUrl: null)
        : null;
  }

  void _goBack() => Navigator.of(context).pop();

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
      initialDate: (_selectedDate ?? DateTime.now()).add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  Future<void> _selectTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay.now(),
    );
    if (picked != null) setState(() => _selectedTime = picked);
  }

  void _toast(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  bool _validateBeforeSubmit() {
    if (!_isEdit && _selectedLevel == null) {
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

  // --------------- Submit (Create or Update) ---------------
  Future<void> _submitForm() async {
    try {
      if (!_validateBeforeSubmit()) return;

      final pickedDateHour = DateTime(
        _selectedDate!.year,
        _selectedDate!.month,
        _selectedDate!.day,
        _selectedTime!.hour,
        _selectedTime!.minute,
      );

      final svc = ActivityService();

      // ==== EDIT ====
      final ex = widget.existing;
      if (ex != null) {
        final newCoverUrl = await _uploadFirstCoverIfAny(); // null si rien choisi

        String? title;
        final titleTrim = _titleCtrl.text.trim();
        if (titleTrim.isNotEmpty && titleTrim != ex.title) title = titleTrim;

        String? location;
        final addrTrim = _addrCtrl.text.trim();
        if (addrTrim.isNotEmpty && addrTrim != ex.location) location = addrTrim;

        double? price;
        final priceTxt = _priceCtrl.text.trim();
        if (priceTxt.isNotEmpty) {
          final parsed = double.tryParse(priceTxt.replaceAll(',', '.'));
          if (parsed != null && parsed != ex.price) price = parsed;
        } else if (ex.price != 0) {
          price = 0;
        }

        String? description;
        final descTrim = _descCtrl.text.trim();
        if (descTrim.isNotEmpty && descTrim != ex.description) description = descTrim;

        DateTime? dateHour;
        if (pickedDateHour != ex.dateHour) dateHour = pickedDateHour;

        int? numberOfParticipant;
        if (_participants != ex.numberOfParticipant) {
          numberOfParticipant = _participants;
        }

        Level? level;
        // if (_selectedLevel != null && _selectedLevel != ex.level) level = _selectedLevel!;

        int? sportId;
        if (_selectedSport != null && _selectedSport!.id != (ex.sportId ?? _selectedSport!.id)) {
          sportId = _selectedSport!.id;
        }

        final patch = ActivityUpdateRequest(
          title: title,
          description: description,
          location: location,
          dateHour: dateHour,
          price: price,
          numberOfParticipant: numberOfParticipant,
          photo: newCoverUrl,
          level: level,
          sportId: sportId,
        );

        if (patch.toJson().isEmpty) {
          _toast('Aucune modification détectée');
          return;
        }

        final updated = await svc.update(ex.id, patch);

        if (!mounted) return;
        FocusScope.of(context).unfocus();
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => ActivityDetailScreen(activity: updated)),
        );
        return;
      }

      // ==== CREATE ====
      final coverUrl = await _uploadFirstCoverIfAny();
      final priceVal = double.tryParse(_priceCtrl.text.replaceAll(',', '.')) ?? 0.0;

      final req = CreateActivityRequest(
        title: _titleCtrl.text.trim().isNotEmpty
            ? _titleCtrl.text.trim()
            : (_selectedSport?.sportName ?? 'Activity'),
        description: _descCtrl.text.trim(),
        location: _addrCtrl.text.trim(),
        dateHour: pickedDateHour,
        price: priceVal,
        numberOfParticipant: _participants,
        level: _selectedLevel ?? Level.D,
        sportId: _selectedSport!.id,
        communityId: widget.community.id,
        photo: coverUrl,
      );

      await svc.create(req);

      // Succès création → on remonte vers l’écran précédent (CommunityHome écoute le booléen)
      if (!mounted) return;
      FocusScope.of(context).unfocus();
      Navigator.pop(context, true);
    } catch (e, st) {
      // ignore: avoid_print
      print('CreateActivityScreen submit error: $e\n$st');
      if (!mounted) return;
      _toast('Erreur: $e');
    }
  }

  // -------------------- UI --------------------
  @override
  Widget build(BuildContext context) {
    // Hauteur utile du clavier (on retire le safe-area iOS)
    final mq = MediaQuery.of(context);
    final double bottomPad = (mq.viewInsets.bottom - mq.viewPadding.bottom)
        .clamp(0.0, double.infinity);

    return Scaffold(
      // On gère nous-mêmes le décalage clavier via AnimatedPadding (pour éviter la bande blanche)
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text(_isEdit ? 'Edit activity' : 'Suggest an activity'),
        leading: const BackButton(),
       
      ),
      body: SafeArea(
        child: AnimatedPadding(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          padding: EdgeInsets.only(bottom: bottomPad),
          child: GestureDetector(
            onTap: () => FocusScope.of(context).unfocus(),
            child: SingleChildScrollView(
              controller: _scrollCtrl,
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    // ---- Photos ----
                    const _SectionTitle('Photos'),
                    const SizedBox(height: 8),
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
                                    const SizedBox(height: 6),
                                    Text(
                                      _isEdit
                                          ? "Choisir une nouvelle couverture (facultatif)"
                                          : "Jusqu'à 5 photos maximum",
                                      style: const TextStyle(color: Colors.grey),
                                    ),
                                  ],
                                ),
                              )
                            : ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: _selectedImages.length,
                                itemBuilder: (_, i) => Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Image.file(_selectedImages[i], width: 100, fit: BoxFit.cover),
                                ),
                              ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // ---- Niveau ----
                    if (!_isEdit) ...[
                      const _SectionTitle('Niveau de l’activité'),
                      const SizedBox(height: 8),
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
                    ],

                    // ---- Sport ----
                    const _SectionTitle('Sport'),
                    const SizedBox(height: 8),
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
                                  tooltip: 'Changer',
                                  onPressed: () => setState(() => _selectedSport = null),
                                ),
                              ],
                            ),
                          )
                        : _buildPicker(
                            'Choose your activity',
                            null,
                            () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => ChooseCategoryScreen(
                                    selectedLevel: _selectedLevel ?? Level.D,
                                    onSportSelected: (SportModel sport) {
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
                    const _SectionTitle('Quand ?'),
                    const SizedBox(height: 8),
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
                              labelText: 'Date',
                              hintText: '12/10/2025',
                              border: OutlineInputBorder(),
                            ),
                            onTap: _selectDate,
                            textInputAction: TextInputAction.next,
                            scrollPadding: const EdgeInsets.only(bottom: 120),
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
                              labelText: 'Heure',
                              hintText: '16h30',
                              border: OutlineInputBorder(),
                            ),
                            onTap: _selectTime,
                            textInputAction: TextInputAction.next,
                            scrollPadding: const EdgeInsets.only(bottom: 120),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    // ---- Lieu ----
                    const _SectionTitle('Où ?'),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _addrCtrl,
                      decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.location_on),
                        hintText: 'Adresse',
                        border: OutlineInputBorder(),
                      ),
                      textInputAction: TextInputAction.next,
                      scrollPadding: const EdgeInsets.only(bottom: 120),
                    ),

                    const SizedBox(height: 12),

                    // ---- Prix ----
                    const _SectionTitle('Prix'),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _priceCtrl,
                      decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.euro),
                        hintText: '0 (gratuit) ou 16',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      textInputAction: TextInputAction.next,
                      scrollPadding: const EdgeInsets.only(bottom: 120),
                    ),

                    const SizedBox(height: 12),

                    // ---- Participants ----
                    const _SectionTitle('Participants'),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
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
                        Text('$_participants',
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

                    const SizedBox(height: 16),

                    // ---- Titre ----
                    const _SectionTitle('Titre'),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _titleCtrl,
                      decoration: const InputDecoration(
                        hintText: 'Titre de ton activité',
                        border: OutlineInputBorder(),
                      ),
                      textInputAction: TextInputAction.next,
                      scrollPadding: const EdgeInsets.only(bottom: 120),
                    ),

                    const SizedBox(height: 16),

                    // ---- Description ----
                    const _SectionTitle('Description'),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _descCtrl,
                      maxLength: 500,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        hintText: 'Ton texte (max 500 caractères)',
                        border: OutlineInputBorder(),
                      ),
                      textInputAction: TextInputAction.done,
                      scrollPadding: const EdgeInsets.only(bottom: 160),
                    ),

                    const SizedBox(height: 16),

                    // ---- Actions ----
                    Row(
                      children: [
                    
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _submitForm,
                            icon: const Icon(Icons.check),
                            label: Text(_isEdit ? 'Enregistrer' : 'Créer'),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              backgroundColor: _getSelectedColor(),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Couleur accent : niveau sélectionné sinon Découverte
  Color _getSelectedColor() {
    final hex = (_selectedLevel ?? Level.D).color;
    return Color(int.parse(hex.replaceAll('#', '0xFF')));
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

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text, {super.key});
  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        text,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
      ),
    );
  }
}
