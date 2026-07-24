import 'package:flutter/material.dart';
import 'ui_tokens.dart';

class AppOptionItem<T> {
  final T value;
  final String label;
  final IconData? icon;

  const AppOptionItem({
    required this.value,
    required this.label,
    this.icon,
  });
}

/// Half-screen bottom sheet for selecting one option.
class AppOptionSheet {
  AppOptionSheet._();

  static Future<T?> show<T>({
    required BuildContext context,
    required String title,
    required List<AppOptionItem<T>> options,
    T? selectedValue,
    AppOptionItem<T>? trailingOption,
    String? subtitle,
    int crossAxisCount = 3,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        final bottomInset = MediaQuery.of(sheetContext).viewInsets.bottom;
        final maxHeight = MediaQuery.of(sheetContext).size.height * 0.55;

        return Padding(
          padding: EdgeInsets.only(bottom: bottomInset),
          child: Container(
            constraints: BoxConstraints(maxHeight: maxHeight),
            decoration: const BoxDecoration(
              color: UiColors.card,
              borderRadius: BorderRadius.vertical(top: Radius.circular(UiRadius.xl)),
            ),
            child: SafeArea(
              top: false,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 10),
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: UiColors.border,
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                    child: Column(
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: UiColors.textPrimary,
                          ),
                        ),
                        if (subtitle != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            subtitle,
                            style: const TextStyle(
                              fontSize: 13,
                              color: UiColors.textSecondary,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ],
                    ),
                  ),
                  Flexible(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                      child: Column(
                        children: [
                          GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: crossAxisCount,
                              mainAxisSpacing: 10,
                              crossAxisSpacing: 10,
                              childAspectRatio: 2.4,
                            ),
                            itemCount: options.length,
                            itemBuilder: (context, index) {
                              final option = options[index];
                              final selected = selectedValue != null &&
                                  selectedValue == option.value;
                              return _OptionTile(
                                label: option.label,
                                icon: option.icon,
                                selected: selected,
                                onTap: () => Navigator.of(sheetContext).pop(option.value),
                              );
                            },
                          ),
                          if (trailingOption != null) ...[
                            const SizedBox(height: 10),
                            _OptionTile(
                              label: trailingOption.label,
                              icon: trailingOption.icon ?? Icons.edit_outlined,
                              selected: false,
                              expanded: true,
                              onTap: () => Navigator.of(sheetContext).pop(trailingOption.value),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _OptionTile extends StatelessWidget {
  final String label;
  final IconData? icon;
  final bool selected;
  final bool expanded;
  final VoidCallback onTap;

  const _OptionTile({
    required this.label,
    this.icon,
    required this.selected,
    this.expanded = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final borderColor = selected ? UiColors.primary : UiColors.border;
    final backgroundColor =
        selected ? UiColors.primary.withValues(alpha: 0.08) : UiColors.surfaceVariant;
    final textColor = selected ? UiColors.primary : UiColors.textPrimary;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(UiRadius.md),
        child: Ink(
          width: expanded ? double.infinity : null,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(UiRadius.md),
            border: Border.all(color: borderColor, width: selected ? 1.5 : 1),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 16, color: textColor),
                const SizedBox(width: 6),
              ],
              Flexible(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                    color: textColor,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                ),
              ),
              if (selected) ...[
                const SizedBox(width: 4),
                Icon(Icons.check_circle, size: 16, color: UiColors.primary),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class AppPickerField extends StatelessWidget {
  final String? label;
  final String value;
  final VoidCallback onTap;

  const AppPickerField({
    super.key,
    this.label,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(UiRadius.sm),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          suffixIcon: Icon(Icons.unfold_more, color: Colors.grey.shade600, size: 20),
        ),
        child: Text(
          value,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w500,
            color: UiColors.textPrimary,
          ),
        ),
      ),
    );
  }
}
