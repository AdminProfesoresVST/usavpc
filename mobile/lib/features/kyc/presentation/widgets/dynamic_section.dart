import 'package:flutter/material.dart';
import 'package:mobile/core/theme/app_theme.dart';

class DynamicSection extends StatelessWidget {
  final Map<String, dynamic> schema;
  final Map<String, dynamic> initialData;
  final Function(String key, dynamic value) onChanged;

  const DynamicSection({
    super.key,
    required this.schema,
    this.initialData = const {},
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final fields = schema['fields'] as List<dynamic>;

    return ListView.separated(
      physics: const ClampingScrollPhysics(),
      shrinkWrap: true,
      itemCount: fields.length,
      separatorBuilder: (ctx, i) => SizedBox(height: AppTheme.espacioEntreSecciones),
      itemBuilder: (context, index) {
        final field = fields[index] as Map<String, dynamic>;
        final type = field['type'];
        final key = field['key'];
        final label = field['label'];

        if (type == 'text') {
          return TextFormField(
             initialValue: initialData[key],
             decoration: InputDecoration(
               labelText: label,
               border: const OutlineInputBorder(),
             ),
             onChanged: (val) => onChanged(key, val),
          );
        } else if (type == 'date') {
          return TextFormField(
             key: Key(key), // Key for testing
             initialValue: initialData[key],
             decoration: InputDecoration(
               labelText: label,
               suffixIcon: const Icon(Icons.calendar_today),
               border: const OutlineInputBorder(),
             ),
             readOnly: true,
             onTap: () async {
               // PRODUCTION: Real date picker dialog
               final picked = await showDatePicker(
                 context: context,
                 initialDate: DateTime.now(),
                 firstDate: DateTime(1900),
                 lastDate: DateTime.now().add(const Duration(days: 365 * 10)),
               );
               if (picked != null) {
                 onChanged(key, picked.toIso8601String().split('T').first);
               }
             },
          );
        }
        
        return const SizedBox.shrink();
      },
    );
  }
}
