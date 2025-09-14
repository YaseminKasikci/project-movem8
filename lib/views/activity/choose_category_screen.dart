

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:move_m8/enums/level.dart';
import 'package:move_m8/models/category_model.dart';
import 'package:move_m8/models/sport_model.dart';
import 'package:move_m8/services/category_service.dart';
import 'package:move_m8/services/user_service.dart';
import 'package:move_m8/views/activity/choose_sport_screen.dart';
import '../../widgets/plus_fab.dart';

class ChooseCategoryScreen extends StatefulWidget {
  final Level selectedLevel;
  final Function(SportModel) onSportSelected;

  const ChooseCategoryScreen({
    super.key,
    required this.selectedLevel,
    required this.onSportSelected,
  });

  @override
  State<ChooseCategoryScreen> createState() => _ChooseCategoryScreenState();
}

class _ChooseCategoryScreenState extends State<ChooseCategoryScreen> {
  final _categoryService = CategoryService();

  List<CategoryModel> _categories = [];
  bool _loading = true;
  bool _isAdmin = false;

  @override
  void initState() {
    super.initState();
    _initRoleThenData();
  }

  Future<void> _initRoleThenData() async {
    await _loadUserRole();     // rôle d’abord (local → fallback API)
    await _fetchCategories();  // puis data
  }

  /// Essaie d’abord le rôle stocké localement, sinon appelle /users/me
  Future<void> _loadUserRole() async {
    try {
      // 1) Local (SharedPreferences)
      final prefs = await SharedPreferences.getInstance();
      final userJson = prefs.getString('user');
      if (userJson != null) {
        final role = (jsonDecode(userJson) as Map<String, dynamic>)['role'] as String?;
        if (role != null) {
          setState(() => _isAdmin = role == 'ADMIN');
          return;
        }
      }

      // 2) Fallback API
      final me = await UserService().getMyProfile();
      setState(() => _isAdmin = me.role == 'ADMIN');
    } catch (_) {
      // En cas d’erreur réseau/parse, on reste en non-admin
      setState(() => _isAdmin = false);
    }
  }

  Future<void> _fetchCategories() async {
    try {
      final data = await _categoryService.fetchAll();
      setState(() {
        _categories = data;
        _loading = false;
      });
    } catch (_) {
      if (mounted) {
        setState(() => _loading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erreur lors du chargement des catégories')),
        );
      }
    }
  }

  IconData _getIconForCategory(String categoryName) {
    switch (categoryName.toLowerCase()) {
      case 'racket':
        return Icons.sports_tennis;
      case 'water':
        return Icons.pool;
      case 'mountain':
        return Icons.terrain;
      case 'snow':
        return Icons.ac_unit;
      case 'combat':
        return Icons.sports_mma;
      case 'team':
        return Icons.groups;
      case 'strength / mobility':
        return Icons.fitness_center;
      case 'running / endurance':
        return Icons.directions_run;
      case 'cycling':
        return Icons.pedal_bike;
      default:
        return Icons.sports;
    }
  }

  void _confirmDeleteCategory(CategoryModel category) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Confirmer la suppression"),
        content: Text("Voulez-vous vraiment supprimer « ${category.categoryName} » ?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Annuler"),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              try {
                await _categoryService.delete(category.id);
                if (mounted) {
                  setState(() => _categories.removeWhere((c) => c.id == category.id));
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

  Future<void> _showEditCategorySheet(CategoryModel category) async {
    final controller = TextEditingController(text: category.categoryName);

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 16,
            left: 16,
            right: 16,
            top: 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("Modifier la catégorie", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              TextField(
                controller: controller,
                decoration: const InputDecoration(labelText: "Nom de la catégorie"),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () async {
                  final updatedName = controller.text.trim();
                  if (updatedName.isEmpty) return;
                  try {
                    await _categoryService.update(category.id, updatedName);
                    if (!mounted) return;
                    Navigator.pop(ctx);
                    await _fetchCategories();
                  } catch (_) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Erreur lors de la modification")),
                      );
                    }
                  }
                },
                child: const Text("Modifier"),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _showCreateCategorySheet() async {
    String name = "";

    await showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      isScrollControlled: true,
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 16,
            left: 16,
            right: 16,
            top: 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("Ajouter une catégorie", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              TextField(
                decoration: const InputDecoration(labelText: "Nom de la catégorie"),
                onChanged: (v) => name = v,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () async {
                  if (name.trim().isEmpty) return;
                  try {
                    await _categoryService.create(name.trim());
                    if (!mounted) return;
                    Navigator.pop(ctx);
                    await _fetchCategories();
                  } catch (e) {
            // LOG visible
                     debugPrint("❌ Create category failed: $e");

                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Erreur de création")),
                      );
                    }
                  }
                },
                child: const Text("Enregistrer"),
              ),
            ],
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
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
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
                          "Choice your sport category",
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                        const Spacer(),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.only(left: 16),
                    child: Row(
                      children: [
                        Text(
                          widget.selectedLevel.label.toUpperCase(),
                          style: TextStyle(color: levelColor, fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: GridView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2, crossAxisSpacing: 12, mainAxisSpacing: 12, childAspectRatio: 1.1,
                      ),
                      itemCount: _categories.length,
                      itemBuilder: (context, index) {
                        final category = _categories[index];
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ChooseSportScreen(
                                  selectedLevel: widget.selectedLevel,
                                  category: category,
                                  onSportSelected: (SportModel sport) {
                                    widget.onSportSelected(sport);
                                    Navigator.pop(context);
                                  },
                                ),
                              ),
                            );
                          },
                          child: Stack(
                            children: [
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: levelColor.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.withOpacity(0.1),
                                      blurRadius: 5,
                                      offset: const Offset(2, 2),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                                  children: [
                                    Icon(_getIconForCategory(category.categoryName), size: 40),
                                    Text(
                                      category.categoryName,
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                                    ),
                                    Align(
                                      alignment: Alignment.bottomRight,
                                      child: Icon(Icons.arrow_forward, color: levelColor),
                                    ),
                                  ],
                                ),
                              ),

                              // Boutons admin
                              if (_isAdmin)
                                Positioned(
                                  top: 4,
                                  right: 4,
                                  child: GestureDetector(
                                    onTap: () => _showEditCategorySheet(category),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Colors.white.withOpacity(0.9),
                                        boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 2)],
                                      ),
                                      child: Icon(Icons.edit, size: 20, color: levelColor),
                                    ),
                                  ),
                                ),
                              if (_isAdmin)
                                Positioned(
                                  top: 4,
                                  left: 4,
                                  child: GestureDetector(
                                    onTap: () => _confirmDeleteCategory(category),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Colors.white.withOpacity(0.9),
                                        boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 2)],
                                      ),
                                      child: const Icon(Icons.close, size: 20, color: Colors.red),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
      ),
      floatingActionButton: _isAdmin
          ? Align(
              alignment: Alignment.bottomLeft,
              child: Padding(
                padding: const EdgeInsets.only(left: 24, bottom: 24),
                child: PlusFAB(
                  heroTag: 'addCategoryFAB',
                  onPressed: _showCreateCategorySheet,
                  backgroundColor: levelColor,
                  diameter: 60,
                  barLength: 35,
                  barThickness: 5,
                ),
              ),
            )
          : null,
    );
  }
}
