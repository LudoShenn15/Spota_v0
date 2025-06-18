import 'package:flutter/material.dart';

class MagicTabs extends StatelessWidget {
  final List<String> tabs;
  final int selectedIndex;
  final Function(int) onTabSelected;
  final Color? selectedColor;
  final Color? unselectedColor;
  final double height;
  final double borderRadius;

  const MagicTabs({
    super.key,
    required this.tabs,
    required this.selectedIndex,
    required this.onTabSelected,
    this.selectedColor,
    this.unselectedColor,
    this.height = 40.0,
    this.borderRadius = 20.0,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final selected = selectedColor ?? theme.colorScheme.primary;
    final unselected = unselectedColor ?? theme.colorScheme.surface;

    return Container(
      height: height,
      decoration: BoxDecoration(
        color: unselected,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(
          tabs.length,
          (index) {
            final isSelected = index == selectedIndex;
            return GestureDetector(
              onTap: () => onTabSelected(index),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeInOut,
                height: height,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: isSelected ? selected : Colors.transparent,
                  borderRadius: BorderRadius.circular(borderRadius),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: selected.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: Center(
                  child: Text(
                    tabs[index],
                    style: TextStyle(
                      color: isSelected
                          ? theme.colorScheme.onPrimary
                          : theme.colorScheme.onSurface.withOpacity(0.7),
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
