import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:move_m8/enums/level.dart';
import 'package:move_m8/models/category_model.dart';
import 'package:move_m8/models/sport_model.dart';
import 'package:move_m8/services/sport_service.dart';
import 'package:move_m8/services/user_service.dart';
import '../../widgets/plus_fab.dart';

class ChooseSportScreen extends StatefulWidget {
  final CategoryModel category;
  final Level selectedLevel;
  final Function(SportModel) onSportSelected;

  const ChooseSportScreen({
    super.key,
    required this.category,
    required this.selectedLevel,
    required this.onSportSelected,
  });

  @override
  State<ChooseSportScreen> createState() => _ChooseSportScreenState();
}

class _ChooseSportScreenState extends State<ChooseSportScreen> {
  final _sportService = SportService();

  List<SportModel> _sports = [];
  bool _isAdmin = false;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _initRoleThenData();
  }

  Future<void> _initRoleThenData() async {
    await _loadUserRole();
    await _loadSports();
  }

  /// Rôle: local d’abord, puis /users/me en fallback
  Future<void> _loadUserRole() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userJson = prefs.getString('user');
      if (userJson != null) {
        final role = (jsonDecode(userJson) as Map<String, dynamic>)['role'] as String?;
        if (role != null) {
          setState(() => _isAdmin = role == 'ADMIN');
          return;
        }
      }
      final me = await UserService().getMyProfile();
      setState(() => _isAdmin = me.role == 'ADMIN');
    } catch (_) {
      setState(() => _isAdmin = false);
    }
  }

  Future<void> _loadSports() async {
    try {
      final sports = await _sportService.fetchByCategory(widget.category.id);
      setState(() {
        _sports = sports;
        _loading = false;
      });
    } catch (_) {
      if (mounted) {
        setState(() => _loading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erreur lors du chargement des sports')),
        );
      }
    }
  }

  void _confirmDeleteSport(SportModel sport) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Supprimer le sport"),
        content: Text("Voulez-vous vraiment supprimer « ${sport.sportName} » ?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Annuler"),
          ),
          TextButton(
            onPressed: () async {
            Navigator.pop(ctx);
              try {
                await _sportService.delete(sport.id);
                if (mounted) {
                  setState(() => _sports.removeWhere((s) => s.id == sport.id));
                }
              } catch (_) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Erreur lors de la suppression")),
                  );
                }
              }
            },
            child: const Text("Supprimer", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showCreateOrEditSheet({SportModel? sport}) {
    final controller = TextEditingController(text: sport?.sportName ?? "");
    File? selectedFile;
    String? selectedFileName;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 16,
            top: 24,
          ),
          child: StatefulBuilder(
            builder: (context, setModalState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    sport == null ? "Ajouter un sport" : "Modifier le sport",
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),

                  TextField(
                    controller: controller,
                    decoration: const InputDecoration(labelText: "Nom du sport"),
                  ),

                  const SizedBox(height: 16),

                  Row(
                    children: [
                      ElevatedButton.icon(
                        onPressed: () async {
                          final result = await FilePicker.platform.pickFiles(
                            type: FileType.custom,
                            allowedExtensions: ['png', 'svg'],
                          );
                          if (result != null && result.files.single.path != null) {
                            setModalState(() {
                              selectedFile = File(result.files.single.path!);
                              selectedFileName = result.files.single.name;
                            });
                          }
                        },
                        icon: const Icon(Icons.upload_file),
                        label: const Text("Icône PNG/SVG"),
                      ),
                      const SizedBox(width: 10),
                      if (selectedFileName != null)
                        Expanded(child: Text(selectedFileName!, overflow: TextOverflow.ellipsis)),
                    ],
                  ),

                  const SizedBox(height: 12),

                  if (selectedFile != null)
                    Image.file(selectedFile!, height: 50, width: 50)
                  else if (sport?.iconUrl != null)
                    Image.network(sport!.iconUrl!, height: 50, width: 50),

                  const SizedBox(height: 16),

                  ElevatedButton(
                    onPressed: () async {
                      final name = controller.text.trim();
                      if (name.isEmpty) return;

                      try {
                        if (sport == null) {
                          await _sportService.create(widget.category.id, name, selectedFile);
                        } else {
                          await _sportService.update(sport.id, name, selectedFile);
                        }
                        if (!mounted) return;
                        Navigator.pop(ctx);
                        await _loadSports();
                      } catch (e) {
                        if (mounted) {
                          Navigator.pop(ctx);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Erreur lors de l’enregistrement")),
                          );
                        }
                      }
                    },
                    child: const Text("Enregistrer"),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }

  Color _getColorFromHex(String hex) {
    final hexCode = hex.replaceAll('#', '');
    return Color(int.parse('FF$hexCode', radix: 16));
  }

  @override
  Widget build(BuildContext context) {
    final Color levelColor = _getColorFromHex(widget.selectedLevel.color);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: levelColor,
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(30),
                        bottomRight: Radius.circular(30),
                      ),
                    ),
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back, color: Colors.white),
                          onPressed: () => Navigator.pop(context),
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          "Choice a sport",
                          style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const Spacer(),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: _sports.isEmpty
                        ? const Center(child: Text("Aucun sport disponible"))
                        : ListView.separated(
                            itemCount: _sports.length,
                            separatorBuilder: (_, __) => const Divider(indent: 24, endIndent: 24),
                            itemBuilder: (ctx, index) {
                              final sport = _sports[index];
                              return ListTile(
                                leading: sport.iconUrl != null
                                    ? Image.network(
                                        sport.iconUrl!,
                                        width: 30,
                                        height: 30,
                                        errorBuilder: (_, __, ___) =>
                                            const Icon(Icons.sports, size: 30),
                                      )
                                    : const Icon(Icons.sports, size: 30),
                                title: Text(sport.sportName, style: const TextStyle(fontSize: 18)),
                                onTap: () {
                                  widget.onSportSelected(sport);
                                  Navigator.pop(context);
                                },
                                trailing: _isAdmin
                                    ? Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          IconButton(
                                            icon: Icon(Icons.edit, color: levelColor),
                                            onPressed: () => _showCreateOrEditSheet(sport: sport),
                                          ),
                                          IconButton(
                                            icon: const Icon(Icons.close, color: Colors.red),
                                            onPressed: () => _confirmDeleteSport(sport),
                                          ),
                                        ],
                                      )
                                    : null,
                              );
                            },
                          ),
                  ),
                ],
              ),
      ),
      floatingActionButton: _isAdmin
          ? Padding(
              padding: const EdgeInsets.only(left: 24),
              child: Align(
                alignment: Alignment.bottomLeft,
                child: PlusFAB(
                  heroTag: 'addSportFAB',
                  backgroundColor: levelColor,
                  onPressed: () => _showCreateOrEditSheet(),
                  diameter: 60,
                  barLength: 35,
                  barThickness: 5,
                ),
              ),
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
    );
  }
}
