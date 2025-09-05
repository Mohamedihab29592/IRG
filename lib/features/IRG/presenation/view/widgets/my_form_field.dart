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
  final List<dynamic>? menuItems; // List of menu items for dropdown/popup menu
  final bool showDownMenu;
  bool multiSelect;
  final String? dependentValue; // Add this to track the dependent field's value
  final Function(String)? onDependentValueChanged; // Callback for dependent field changes
  final TextInputType textType;

  final FormFieldValidator<String>? validator; // Add validator as a parameter
  void Function()? onTap;
  void Function(String)? onChange;

  MyFormField({
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
    this.menuItems, // New parameter for menu items
    this.showDownMenu = false,
    this.hint,
    this.validator, // Default value to show the down menu
    this.dependentValue, // Add this parameter
    this.onDependentValueChanged, // Add this parameter
  }) : super(key: key);

  @override
  _MyFormFieldState createState() => _MyFormFieldState();
}

class _MyFormFieldState extends State<MyFormField> {
  late TextEditingController _textFieldController;
  List<dynamic> _filteredItems = [];
  Set<String> _selectedItems = Set(); // Initialize selected items set
  bool _isMenuOpen = false;

  @override
  void initState() {
    super.initState();
    _textFieldController = widget.controller ?? TextEditingController();
    _filteredItems = widget.menuItems ?? [];
  }
  @override
  void didUpdateWidget(MyFormField oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Update filtered items when dependent value changes
    if (widget.dependentValue != oldWidget.dependentValue) {
      _updateFilteredItems(_textFieldController.text);
    }
    // Update filtered items when menuItems changes
    if (widget.menuItems != oldWidget.menuItems) {
      _updateFilteredItems(_textFieldController.text);
    }
  }
  void _updateFilteredItems(String searchValue) {
    setState(() {
      if (searchValue.isEmpty) {
        _filteredItems = List.from(widget.menuItems ?? []); // Create a new mutable list
      } else {
        _isMenuOpen = true;
        _filteredItems = List.from(widget.menuItems ?? []).where((item) =>
            item.name.toLowerCase().contains(searchValue.toLowerCase())).toList();
      }

      if (widget.dependentValue != null) {
        _filteredItems = _filteredItems.where((item) =>
        item.locationTypeId.toString() == widget.dependentValue).toList();
      }

      // Create a new list before adding an item
      if (_filteredItems.isEmpty) {
        _filteredItems = [
          LocationModel(name: 'No locations found', id: 0, locationTypeId: 0)
        ];
      }
    });
  }
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.title!,
          style:
              const TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
        ),
        const SizedBox(
          height: 5,
        ),
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
                    if (widget.showDownMenu) {
                      _toggleMenu(); // Open menu when clicking on field
                    }
                    widget.onTap?.call();
                  },                  readOnly: widget.isReadonly,
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
                    hintStyle: TextStyle(color: Colors.grey),
                    border: const OutlineInputBorder(
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey),
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
                            icon: Icon(
                              widget.suffixIcon,
                              color: Colors.blue,
                            ),
                          ),
                        if (widget.showDownMenu)
                          IconButton(
                            onPressed: _toggleMenu,
                            icon: _isMenuOpen
                                ? Icon(Icons.keyboard_arrow_up)
                                : Icon(Icons.keyboard_arrow_down),
                          ),
                      ],
                    ),
                  ),

                  onChanged: (value) {
                    if (widget.showDownMenu) {
                      _updateFilteredItems(value);
                    }
                    widget.onChange?.call(value);

                  }),

              if (_isMenuOpen &&
                  widget.showDownMenu &&
                  _filteredItems.isNotEmpty)
                Container(
                  height: _filteredItems.length * 60.0,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(6),
                      bottomRight: Radius.circular(6),
                    ),
                  ),
                  child: ListView.builder(
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: _filteredItems.length,
                    itemBuilder: (context, index) {
                      return Column(
                        children: [
                          Divider(
                            height: 1,
                          ),
                          GestureDetector(
                            onTap: () {
                            setState(() {
                              widget.onTap;
                            });

                            },
                            child:  GestureDetector(
                              onTap: () {
                                _onMenuItemSelected(_filteredItems[index]);
                                widget.onTap?.call();
                              },
                              child: ListTile(
                                title: Text(_filteredItems[index].name),

                              ),
                            ),
                          ),
                        ],
                      );
                    },
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
        if (_selectedItems.contains(item.name)) {
          _selectedItems.remove(item.name);
        } else {
          _selectedItems.add(item.name);
        }
        _textFieldController.text = _selectedItems.join(', ');
      } else {
        _toggleMenu();
        _textFieldController.text = item.name;
        if (widget.onDependentValueChanged != null) {
          widget.onDependentValueChanged!(item.id.toString());
        }
      }
    }
  }

  void _toggleMenu() {
    setState(() {
      _isMenuOpen = !_isMenuOpen;
    });
  }
}
