import 'package:flutter/material.dart';

import '../../core/constants/app_spacing.dart';

/// Search field paired with a Search button (UI/UX spec Section 17).
/// Per spec, search executes only when the button is clicked (or
/// Enter is pressed, an equivalent explicit action) — never live as
/// the user types.
class AppSearchBar extends StatefulWidget {
  const AppSearchBar({
    super.key,
    required this.hintText,
    required this.onSearch,
    this.initialValue = '',
  });

  final String hintText;
  final ValueChanged<String> onSearch;
  final String initialValue;

  @override
  State<AppSearchBar> createState() => _AppSearchBarState();
}

class _AppSearchBarState extends State<AppSearchBar> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() => widget.onSearch(_controller.text.trim());

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: TextField(
            controller: _controller,
            decoration: InputDecoration(hintText: widget.hintText, prefixIcon: const Icon(Icons.search)),
            textInputAction: TextInputAction.search,
            onSubmitted: (_) => _submit(),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        ElevatedButton(onPressed: _submit, child: const Text('Search')),
      ],
    );
  }
}
