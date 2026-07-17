import 'dart:async';

import 'package:flutter/material.dart';

/// Live search field (UI/UX spec Section 17, superseded per
/// enhancement request): results update automatically as the user
/// types, debounced by 300ms so rapid keystrokes don't fire a reload
/// per character. No Search button — clearing the field (via the
/// clear icon or deleting all text) immediately shows the complete
/// list, matching [EmployeeProvider]/[ClientProvider]'s existing
/// "empty query = no filter" behavior.
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
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _onChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      widget.onSearch(value.trim());
    });
    // Rebuild so the clear (x) button's visibility follows the text.
    setState(() {});
  }

  void _clear() {
    _debounce?.cancel();
    _controller.clear();
    widget.onSearch('');
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      textInputAction: TextInputAction.search,
      decoration: InputDecoration(
        hintText: widget.hintText,
        prefixIcon: const Icon(Icons.search),
        suffixIcon: _controller.text.isEmpty
            ? null
            : IconButton(icon: const Icon(Icons.clear), onPressed: _clear),
      ),
      onChanged: _onChanged,
      // Enter still works as an immediate, non-debounced submit for
      // keyboard users who prefer it.
      onSubmitted: (value) {
        _debounce?.cancel();
        widget.onSearch(value.trim());
      },
    );
  }
}
