// import 'package:flutter/material.dart';
// import '../../models/category_model.dart';
// import '../../services/category_service.dart';

// class CategoryScreen extends StatefulWidget {
//   const CategoryScreen({super.key});

//   @override
//   State<CategoryScreen> createState() => _CategoryScreenState();
// }

// class _CategoryScreenState extends State<CategoryScreen> {
//   final CategoryService _svc = CategoryService();
//   final TextEditingController _controller = TextEditingController();
//   List<CategoryModel> _categories = [];
//   bool _loading = true;

//   @override
//   void initState() {
//     super.initState();
//     _load();
//   }

//   Future<void> _load() async {
//     setState(() => _loading = true);
//     try {
//       _categories = await _svc.fetchAll();
//     } catch (_) {}
//     setState(() => _loading = false);
//   }

//   Future<void> _addCategory() async {
//     if (_controller.text.isEmpty) return;
//     try {
//       await _svc.create(_controller.text.trim());
//       _controller.clear();
//       _load();
//     } catch (_) {}
//   }

//   Future<void> _delete(int id) async {
//     try {
//       await _svc.delete(id);
//       _load();
//     } catch (_) {}
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text("Catégories")),
//       body: _loading
//           ? const Center(child: CircularProgressIndicator())
//           : Column(
//               children: [
//                 Padding(
//                   padding: const EdgeInsets.all(12),
//                   child: Row(
//                     children: [
//                       Expanded(
//                         child: TextField(
//                           controller: _controller,
//                           decoration: const InputDecoration(
//                             hintText: "Nouvelle catégorie",
//                             border: OutlineInputBorder(),
//                           ),
//                         ),
//                       ),
//                       const SizedBox(width: 8),
//                       ElevatedButton(
//                         onPressed: _addCategory,
//                         child: const Text("Ajouter"),
//                       ),
//                     ],
//                   ),
//                 ),
//                 Expanded(
//                   child: ListView.builder(
//                     itemCount: _categories.length,
//                     itemBuilder: (_, i) {
//                       final c = _categories[i];
//                       return ListTile(
//                         leading: const Icon(Icons.category),
//                         title: Text(c.categoryName),
//                         trailing: IconButton(
//                           icon: const Icon(Icons.delete, color: Colors.red),
//                           onPressed: () => _delete(c.id),
//                         ),
//                       );
//                     },
//                   ),
//                 ),
//               ],
//             ),
//     );
//   }
// }
