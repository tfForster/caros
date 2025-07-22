import 'package:flutter/material.dart';

class ToggleButton extends StatefulWidget {
  final String label;
  final void Function(bool)? onToggle;

  const ToggleButton({Key? key, required this.label, this.onToggle}) : super(key: key);

  @override
  _ToggleButtonState createState() => _ToggleButtonState();
}

class _ToggleButtonState extends State<ToggleButton> {
  bool isOn = false;

  void toggle() {
    setState(() {
      isOn = !isOn;
    });
    if (widget.onToggle != null) {
      widget.onToggle!(isOn);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: toggle,
      style: ElevatedButton.styleFrom(
        backgroundColor: isOn ? Colors.red[900] : Colors.grey, // Match the toggle state color
        minimumSize: const Size(200, 60), // Match the size from _buildButton
        shape: RoundedRectangleBorder( 
          borderRadius: BorderRadius.circular(8), // Match the border radius
        ),
      ),
      child: Text(
        widget.label,
        style: const TextStyle(
          color: Colors.white, // Match the text color
          fontSize: 16, // Match the font size
        ),
      ),
    );
  }

}
