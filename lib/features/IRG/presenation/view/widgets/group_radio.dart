import 'package:flutter/material.dart';
import '../../../../../core/constants/enum.dart';

class YesNoRadioGroup extends StatelessWidget {
  final String label;
  final String radioKey;
  final YesNo? groupValue;
  final bool includeNotRelevant;
  final void Function(String key, YesNo value) onChanged;

  const YesNoRadioGroup({
    super.key,
    required this.label,
    required this.radioKey,
    required this.groupValue,
    required this.onChanged,
    this.includeNotRelevant = false,
  });

  @override
  Widget build(BuildContext context) {
    return RadioGroup<YesNo>(
      groupValue: groupValue,
      onChanged: (value) {
        if (value != null) onChanged(radioKey, value);
      },
      child: Row(
        children: [
          Flexible(flex: 1, child: Text(label)),
          Flexible(
            flex: 1,
            child: Row(children: [
              Radio<YesNo>(value: YesNo.Yes),
              const Text("Yes"),
            ]),
          ),
          Flexible(
            flex: 1,
            child: Row(children: [
              Radio<YesNo>(value: YesNo.No),
              const Text("No"),
            ]),
          ),
          if (includeNotRelevant)
            Flexible(
              flex: 2,
              child: Row(children: [
                Radio<YesNo>(value: YesNo.Not_Relevant),
                const Text("Not relevant"),
              ]),
            ),
        ],
      ),
    );
  }
}