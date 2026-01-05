import 'package:flutter/material.dart';

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
      separatorBuilder: (ctx, i) => const SizedBox(height: 16),
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
               // Mock Date Picker
               onChanged(key, '2023-01-01');
             },
          );
        }
        
        return const SizedBox.shrink();
      },
    );
  }
}
