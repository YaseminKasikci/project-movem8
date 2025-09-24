import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:move_m8/config/api_config.dart';
import 'package:move_m8/models/user_model.dart';
import 'package:move_m8/services/user_service.dart';
import 'package:move_m8/services/auth_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path/path.dart' as p;


class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _userService = UserService();
  final _authService = AuthService();

  final TextEditingController _firstName = TextEditingController();
  final TextEditingController _lastName = TextEditingController();
  final TextEditingController _description = TextEditingController();
  final TextEditingController _birthday = TextEditingController();

  String _gender = 'F';
  bool _loading = false;
  String? _error;

  File? _selectedImage;
  String? _imageUrl;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }
   Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

Future<void> _loadUserData() async {
  final user = await _userService.getMyProfile();
  setState(() {
    _firstName.text  = user.firstName;
    _lastName.text   = user.lastName;
    _description.text = user.description ?? '';
    _imageUrl = user.pictureProfile != null
    ? ApiConfig.fixImageHost(user.pictureProfile!)
    : null;
    _birthday.text = user.birthday != null
        ? DateFormat('dd-MM-yyyy').format(user.birthday!)
        : '';
    _gender = user.gender ?? 'F';
  });
}


Future<File> _ensureJpeg(File file) async {
  final ext = p.extension(file.path).toLowerCase();
  // Si c'est déjà un JPG/JPEG → ne rien faire
  if (ext == '.jpg' || ext == '.jpeg') return file;

  // Fichier de sortie unique
  final outPath = p.join(
    p.dirname(file.path),
    '${p.basenameWithoutExtension(file.path)}_${DateTime.now().millisecondsSinceEpoch}.jpg',
  );

  try {
    final x = await FlutterImageCompress.compressAndGetFile(
      file.path, outPath,
      format: CompressFormat.jpeg, quality: 88,
    );
    return x != null ? File(x.path) : file;
  } on UnimplementedError {
    return file; // fallback iOS si plugin non dispo
  } catch (_) {
    return file;
  }
}

Future<String> _uploadProfilePicture(File image) async {
  final jpegImage = await _ensureJpeg(image); // ✅ conversion JPEG si besoin

  final token = await _authService.getToken();
  final uri = ApiConfig.path(['files', 'upload'])
      .replace(queryParameters: {'type': 'profiles'});

final request = http.MultipartRequest('POST', uri)
  ..headers['Authorization'] = 'Bearer $token'
  ..files.add(
    await http.MultipartFile.fromPath(
      'file',
      jpegImage.path,
      contentType: MediaType('image', 'jpeg'), 
    ),
  );

  print("📤 Upload de ${jpegImage.path} vers $uri");

  final response = await request.send();
  final raw = await response.stream.bytesToString();

  if (response.statusCode == 200) {
    String url;
    if (raw.trim().startsWith('{')) {
      final data = jsonDecode(raw);
      url = (data['url'] as String).trim();
    } else {
      url = raw.replaceAll('"', '').trim();
    }
    print("✅ Upload OK, URL reçue: $url");
    return ApiConfig.fixImageHost(url);
  }

  throw Exception('Erreur upload: $raw');
}



Future<void> _submit() async {
  if (!_formKey.currentState!.validate()) return;
  setState(() => _loading = true);

  try {
    // ✅ Récupérer l'utilisateur courant depuis l'API (évite userId null / mauvais champ)
    final me = await _userService.getMyProfile();
    final int userId = me.id;

    // ✅ Upload image si sélectionnée (avec conversion JPEG en amont dans _uploadProfilePicture)
    String? finalImageUrl = _imageUrl;
    if (_selectedImage != null) {
      finalImageUrl = await _uploadProfilePicture(_selectedImage!);
    }

    // ✅ Parser la date tapée (JJ-MM-AAAA) -> DateTime pour le modèle
    final DateTime? parsedBirthday = _birthday.text.isNotEmpty
        ? DateFormat('dd-MM-yyyy').parse(_birthday.text)
        : null;

    // ✅ Construire l'objet UserModel (id non nul)
    final updatedUser = UserModel(
      id: userId,
      firstName: _firstName.text.trim(),
      lastName:  _lastName.text.trim(),
      description: _description.text.trim().isEmpty ? null : _description.text.trim(),
      gender: _gender,
      birthday: parsedBirthday,
      pictureProfile: finalImageUrl, // URL renvoyée par l'upload
    );

    // ✅ Appel API (UserService.completeProfile envoie bien birthday au format dd-MM-yyyy)
    await _userService.completeProfile(userId, updatedUser);

    if (!mounted) return;
    Navigator.pop(context);
  } catch (e) {
    setState(() => _error = e.toString());
  } finally {
    setState(() => _loading = false);
  }
}

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _birthday.text = DateFormat('dd-MM-yyyy').format(picked);
      });
    }
  }

  @override
Widget build(BuildContext context) {
  final imageProvider = _selectedImage != null
      ? FileImage(_selectedImage!)
      : (_imageUrl != null && _imageUrl!.isNotEmpty
          ? NetworkImage(ApiConfig.fixImageHost(_imageUrl!))
          : null);

  return Scaffold(
    appBar: AppBar(title: const Text("Compléter mon profil")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              Center(
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 60,
                      backgroundImage: imageProvider as ImageProvider?,
                      child: imageProvider == null ? const Icon(Icons.person, size: 60) : null,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: GestureDetector(
                        onTap: _pickImage,
                        child: const CircleAvatar(
                          backgroundColor: Colors.blue,
                          radius: 16,
                          child: Icon(Icons.add, size: 16, color: Colors.white),
                        ),
                      ),
                    )
                  ],
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _firstName,
                decoration: const InputDecoration(labelText: 'Prénom'),
                validator: (v) => v == null || v.isEmpty ? 'Obligatoire' : null,
              ),
              TextFormField(
                controller: _lastName,
                decoration: const InputDecoration(labelText: 'Nom'),
                validator: (v) => v == null || v.isEmpty ? 'Obligatoire' : null,
              ),
              TextFormField(
                controller: _description,
                decoration: const InputDecoration(labelText: 'Description'),
                maxLines: 2,
              ),
              DropdownButtonFormField<String>(
                value: _gender,
                items: const [
                  DropdownMenuItem(value: 'M', child: Text('Homme')),
                  DropdownMenuItem(value: 'F', child: Text('Femme')),
                  DropdownMenuItem(value: 'O', child: Text('Autre')),
                ],
                onChanged: (v) => setState(() => _gender = v ?? 'F'),
                decoration: const InputDecoration(labelText: 'Genre'),
              ),
              TextFormField(
                controller: _birthday,
                readOnly: true,
                onTap: _selectDate,
                decoration: const InputDecoration(labelText: 'Date de naissance (JJ-MM-AAAA)'),
              ),
              const SizedBox(height: 20),
              if (_error != null)
                Text(_error!, style: const TextStyle(color: Colors.red)),
              ElevatedButton(
                onPressed: _loading ? null : _submit,
                child: _loading
                    ? const CircularProgressIndicator()
                    : const Text('Enregistrer'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}