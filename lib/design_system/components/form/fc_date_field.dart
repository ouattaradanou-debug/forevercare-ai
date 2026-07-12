import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../foundations/radius/app_radius.dart';
import '../../foundations/spacing/app_spacing.dart';

/// Champ officiel de sélection de date du
/// ForeverCare Design Language.
///
/// Toutes les dates de l'application doivent utiliser
/// ce composant.
class FCDateField extends StatefulWidget {
  const FCDateField({
    super.key,
    this.label,
    this.hint,
    this.initialDate,
    this.firstDate,
    this.lastDate,
    this.onChanged,
    this.validator,
    this.enabled = true,
    this.dateFormat = 'dd/MM/yyyy',
  });

  final String? label;

  final String? hint;

  final DateTime? initialDate;

  final DateTime? firstDate;

  final DateTime? lastDate;

  final ValueChanged<DateTime?>? onChanged;

  final FormFieldValidator<String>? validator;

  final bool enabled;

  final String dateFormat;

  @override
  State<FCDateField> createState() => _FCDateFieldState();
}

class _FCDateFieldState extends State<FCDateField> {
  late final TextEditingController _controller;

  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();

    _selectedDate = widget.initialDate;
    _controller = TextEditingController();

    _refreshText();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _refreshText() {
    if (_selectedDate == null) {
      _controller.text = '';
      return;
    }

    _controller.text = DateFormat(widget.dateFormat).format(_selectedDate!);
  }

  Future<void> _pickDate() async {
    if (!widget.enabled) return;

    final now = DateTime.now();

    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? widget.initialDate ?? now,
      firstDate: widget.firstDate ?? DateTime(1900),
      lastDate: widget.lastDate ?? DateTime(2100),
    );

    if (picked == null) return;

    setState(() {
      _selectedDate = picked;
      _refreshText();
    });

    widget.onChanged?.call(picked);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.fieldSpacing),
      child: TextFormField(
        controller: _controller,
        readOnly: true,
        enabled: widget.enabled,
        validator: widget.validator,
        onTap: _pickDate,
        style: theme.textTheme.bodyLarge,
        decoration: InputDecoration(
          labelText: widget.label,
          hintText: widget.hint,
          suffixIcon: const Icon(Icons.calendar_month_rounded),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.lg,
          ),
          border: OutlineInputBorder(borderRadius: AppRadius.input),
          enabledBorder: OutlineInputBorder(
            borderRadius: AppRadius.input,
            borderSide: BorderSide(color: theme.colorScheme.outline),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: AppRadius.input,
            borderSide: BorderSide(color: theme.colorScheme.primary, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: AppRadius.input,
            borderSide: BorderSide(color: theme.colorScheme.error),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: AppRadius.input,
            borderSide: BorderSide(color: theme.colorScheme.error, width: 2),
          ),
        ),
      ),
    );
  }
}
