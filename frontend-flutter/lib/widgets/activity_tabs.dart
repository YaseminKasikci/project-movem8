// 📁 lib/widgets/activity/activity_tabs.dart

import 'package:flutter/material.dart';

class ActivityTabs extends StatelessWidget {
  final List<String> tabs;
  final int index;
  final ValueChanged<int> onChanged;

  const ActivityTabs({
    Key? key,
    required this.tabs,
    required this.index,
    required this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(tabs.length, (i) {
        final isSelected = i == index;
        return Expanded(
          child: GestureDetector(
            onTap: () => onChanged(i),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: isSelected ? Colors.white : Colors.grey.shade200,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(i == 0 ? 12 : 0),
                  topRight: Radius.circular(i == tabs.length - 1 ? 12 : 0),
                ),
                border: Border(
                  bottom: BorderSide(
                    color: isSelected ? Colors.transparent : Colors.grey.shade400,
                    width: 2,
                  ),
                ),
              ),
              child: Center(
                child: Text(
                  tabs[i],
                  style: TextStyle(
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    color: isSelected ? Colors.black : Colors.grey.shade600,
                  ),
                ),
              ),
            ),
          ),
        );
      }),
    );
  }
}
