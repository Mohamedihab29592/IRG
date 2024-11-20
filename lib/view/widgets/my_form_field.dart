import 'package:flutter/material.dart';



class MyFormField extends StatefulWidget {
  final double radius;
  final String ? title;
  final String? hint;
  final int? maxLines;
  final VoidCallback? suffixIconPressed;
  final IconData? suffixIcon;
  final Widget? widget;
  final TextEditingController? controller;
  final bool isPassword;
  final bool isReadonly;
  final List<String>? menuItems; // List of menu items for dropdown/popup menu
  final bool
      showDownMenu;
  bool multiSelect ;
  final FormFieldValidator<String>? validator; // Add validator as a parameter
  void Function()? onTap;

  MyFormField({
    Key? key,
    this.isPassword = false,
    this.radius = 15,
    this.isReadonly = false,
    required this.maxLines,
    this.suffixIcon,
    this.multiSelect = false,
    this.suffixIconPressed,
    this.onTap,
    this.widget,
    this.controller,
     this.title="",
    this.menuItems, // New parameter for menu items
    this.showDownMenu = false,
    this.hint, this.validator, // Default value to show the down menu
  }) : super(key: key);

  @override
  _MyFormFieldState createState() => _MyFormFieldState();
}

class _MyFormFieldState extends State<MyFormField> {
  late TextEditingController _textFieldController;
  List<String> _filteredItems = [];
  Set<String> _selectedItems = Set(); // Initialize selected items set
  bool _isMenuOpen = false;

  @override
  void initState() {
    super.initState();
    _textFieldController = widget.controller ?? TextEditingController();
    _filteredItems = widget.menuItems ?? [];
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.title!,
          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
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
                onTap:widget.onTap,
                readOnly: widget.isReadonly,

                validator: widget.validator ?? (value) {
                  if ((value == null || value.isEmpty) && _selectedItems.isEmpty) {
                    return "* Required";
                  }
                  return null;
                },
                cursorColor: Colors.blue,
                obscureText: widget.isPassword,
                controller: _textFieldController,
                maxLines: widget.maxLines,
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

                      if (widget.showDownMenu )
                        IconButton(
                          onPressed: _toggleMenu,
                          icon: _isMenuOpen ? Icon(Icons.keyboard_arrow_up) : Icon(Icons.keyboard_arrow_down),
                        ),
                    ],
                  ),
                ),
                onChanged: widget.showDownMenu ? _onTextChanged : null,
              ),

              if (_isMenuOpen && widget.showDownMenu && _filteredItems.isNotEmpty)
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
                          Divider(height: 1,),
                          ListTile(
                            title: Text(_filteredItems[index]),
                            onTap: () {
                              setState(() {
                                _onMenuItemSelected(_filteredItems[index]);
                              });
                            },
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

  void _onTextChanged(String value) {
    setState(() {
      if (value.isEmpty) {
        // Filter items based on selected items
        _filteredItems = widget.menuItems!.where((item) => _selectedItems.contains(item)).toList();
        _isMenuOpen = true;
      } else {
        _filteredItems = widget.menuItems!
            .where((item) => item.toLowerCase().contains(value.toLowerCase()))
            .toList();
        _isMenuOpen = true;
      }
      if (_filteredItems.isEmpty) {
        _filteredItems.add('No result found');
      }

    });
  }

  void _onMenuItemSelected(String item) {
    if (item != 'No result found') {
      setState(() {
        if (widget.multiSelect) {
          if (_selectedItems.contains(item)) {
            _selectedItems.remove(item);
          } else {
            _selectedItems.add(item);
          }
          _textFieldController.text = _selectedItems.join(', '); // Update text field with selected items
        } else {
          _toggleMenu();
          _textFieldController.text = item;

        }
      });
    }
  }

  void _toggleMenu() {
    setState(() {
      _isMenuOpen = !_isMenuOpen;
    });
  }
}
