import 'package:flutter/material.dart';

import '../../../data/Model/location_model.dart';

class MyFormField extends StatefulWidget {
  final double radius;
  final String? title;
  final String? hint;
  final bool enableSpellCheck;
  final VoidCallback? suffixIconPressed;
  final IconData? suffixIcon;
  final Widget? widget;
  final TextEditingController? controller;
  final bool isPassword;
  final bool isReadonly;
  final List<dynamic>? menuItems;
  final bool showDownMenu;
  final bool multiSelect;
  final String? dependentValue;
  final Function(String)? onDependentValueChanged;
  final TextInputType textType;
  final FormFieldValidator<String>? validator;
  final void Function()? onTap;
  final void Function(String)? onChange;

  const MyFormField({
    Key? key,
    this.enableSpellCheck = false,
    this.textType = TextInputType.text,
    this.isPassword = false,
    this.radius = 15,
    this.isReadonly = false,
    this.suffixIcon,
    this.multiSelect = false,
    this.suffixIconPressed,
    this.onTap,
    this.onChange,
    this.widget,
    this.controller,
    this.title = "",
    this.menuItems,
    this.showDownMenu = false,
    this.hint,
    this.validator,
    this.dependentValue,
    this.onDependentValueChanged,
  }) : super(key: key);

  @override
  _MyFormFieldState createState() => _MyFormFieldState();
}

class _MyFormFieldState extends State<MyFormField> {
  late TextEditingController _textFieldController;
  final ScrollController _scrollController = ScrollController();
  List<dynamic> _filteredItems = [];
  Set<String> _selectedItems = {};
  bool _isMenuOpen = false;

  static const int _initialDisplayCount = 5;
  static const double _itemHeight = 60.0;
  static const double _maxMenuHeight = _initialDisplayCount * _itemHeight;

  void _onControllerChanged() {
    if (_textFieldController.text.isEmpty && _selectedItems.isNotEmpty) {
      setState(() {
        _selectedItems.clear();
        _isMenuOpen = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _textFieldController = widget.controller ?? TextEditingController();
    _filteredItems = widget.menuItems ?? [];
    _textFieldController.addListener(_onControllerChanged);
  }

  @override
  void didUpdateWidget(MyFormField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.dependentValue != oldWidget.dependentValue ||
        widget.menuItems != oldWidget.menuItems) {
      _updateFilteredItems(_textFieldController.text);
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _updateFilteredItems(String searchValue) {
    setState(() {
      List<dynamic> items = List.from(widget.menuItems ?? []);

      if (searchValue.isNotEmpty) {
        _isMenuOpen = true;
        items = items
            .where((item) =>
            item.name.toLowerCase().contains(searchValue.toLowerCase()))
            .toList();
      }

      if (widget.dependentValue != null) {
        items = items
            .where((item) =>
        item.locationTypeId.toString() == widget.dependentValue)
            .toList();
      }

      _filteredItems = items.isEmpty
          ? [LocationModel(name: 'No locations found', id: 0, locationTypeId: 0)]
          : items;
    });
  }

  @override
  Widget build(BuildContext context) {
    final double menuHeight = _filteredItems.length <= _initialDisplayCount
        ? _filteredItems.length * _itemHeight
        : _maxMenuHeight;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.title!,
          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
        ),
        const SizedBox(height: 5),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(6),
            color: Colors.white,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                keyboardType: widget.textType,
                textCapitalization: TextCapitalization.sentences,
                autocorrect: widget.enableSpellCheck,
                enableSuggestions: widget.enableSpellCheck,
                onTap: () {
                  if (widget.showDownMenu) _toggleMenu();
                  widget.onTap?.call();
                },
                readOnly: widget.isReadonly,
                validator: widget.validator ??
                        (value) {
                      if ((value == null || value.isEmpty) &&
                          _selectedItems.isEmpty) {
                        return "* Required";
                      }
                      return null;
                    },
                cursorColor: Colors.blue,
                obscureText: widget.isPassword,
                controller: _textFieldController,
                maxLines: null,
                decoration: InputDecoration(
                  hintText: widget.hint,
                  hintStyle: const TextStyle(color: Colors.grey),
                  border: const OutlineInputBorder(borderSide: BorderSide.none),
                  focusedBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Colors.grey),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  suffixIcon: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (widget.suffixIcon != null)
                        IconButton(
                          onPressed: () {
                            widget.suffixIconPressed!();
                            _toggleMenu();
                          },
                          icon: Icon(widget.suffixIcon, color: Colors.blue),
                        ),
                      if (widget.showDownMenu)
                        IconButton(
                          onPressed: _toggleMenu,
                          icon: Icon(_isMenuOpen
                              ? Icons.keyboard_arrow_up
                              : Icons.keyboard_arrow_down),
                        ),
                    ],
                  ),
                ),
                onChanged: (value) {
                  if (widget.showDownMenu) _updateFilteredItems(value);
                  widget.onChange?.call(value);
                },
              ),

              if (_isMenuOpen && widget.showDownMenu && _filteredItems.isNotEmpty)
                Container(
                  height: menuHeight,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(6),
                      bottomRight: Radius.circular(6),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withValues(alpha: 0.2),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Scrollbar(
                    controller: _scrollController,
                    thumbVisibility: true,
                    child: ListView.builder(
                      controller: _scrollController,
                      physics: const ClampingScrollPhysics(),
                      itemCount: _filteredItems.length,
                      itemBuilder: (context, index) {
                        final item = _filteredItems[index];
                        final isSelected = _selectedItems.contains(item.name);

                        return Column(
                          children: [
                            const Divider(height: 1),
                            GestureDetector(
                              onTap: () {
                                _onMenuItemSelected(item);
                                widget.onTap?.call();
                              },
                              child: ListTile(
                                title: Text(item.name),
                                trailing: widget.multiSelect && isSelected
                                    ? const Icon(Icons.check, color: Colors.blue)
                                    : null,
                                tileColor: isSelected
                                    ? Colors.blue.withValues(alpha: 0.05)
                                    : null,
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  void _onMenuItemSelected(dynamic item) {
    if (item.name != 'No locations found') {
      if (widget.multiSelect) {
        setState(() {
          if (_selectedItems.contains(item.name)) {
            _selectedItems.remove(item.name);
          } else {
            _selectedItems.add(item.name);
          }
          _textFieldController.text = _selectedItems.join(', ');
        });
      } else {
        _toggleMenu();
        _textFieldController.text = item.name;
        widget.onDependentValueChanged?.call(item.id.toString());
      }
    }
  }

  void _toggleMenu() {
    setState(() {
      _isMenuOpen = !_isMenuOpen;
      if (_isMenuOpen) {
        if (widget.isReadonly) {
          List<dynamic> items = List.from(widget.menuItems ?? []);
          _filteredItems = items.isEmpty
              ? [LocationModel(name: 'No locations found', id: 0, locationTypeId: 0)]
              : items;
        } else {
          _updateFilteredItems(_textFieldController.text);
        }
      }
    });
  }
}