import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class KeyButton extends StatefulWidget {
  final String text;
  final VoidCallback onTap;
  final double height;

  const KeyButton({
    super.key,
    required this.text,
    required this.onTap,
    required this.height,
  });

  @override
  State<KeyButton> createState() => _KeyButtonState();
}

class _KeyButtonState extends State<KeyButton> {
  bool isPressed = false;

  void _addHapticFeedback() {
    HapticFeedback.lightImpact();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) {
        setState(() => isPressed = true);
        _addHapticFeedback();
        widget.onTap();
        Future.delayed(const Duration(milliseconds: 100), () {
          if (mounted) {
            setState(() => isPressed = false);
          }
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: widget.height,
        transform: Matrix4.identity()..scale(isPressed ? 0.95 : 1.0),
        decoration: BoxDecoration(
          color: isPressed ? Colors.grey[300] : Colors.grey[100],
          borderRadius: BorderRadius.circular(24),
        ),
        child: Center(
          child: widget.text == 'backspace'
              ? Icon(
                  Icons.backspace_outlined,
                  color: isPressed ? Colors.black : Colors.black54,
                )
              : Text(
                  widget.text,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: isPressed ? Colors.black : Colors.black54,
                  ),
                ),
        ),
      ),
    );
  }
}

class NumberKeyboard extends StatelessWidget {
  final Function(String) onNumberTap;
  final Function() onBackspace;
  final Function() onDone;
  final bool allowDecimal;
  final String currentValue;
  final String fieldName;

  const NumberKeyboard({
    super.key,
    required this.onNumberTap,
    required this.onBackspace,
    required this.onDone,
    required this.currentValue,
    required this.fieldName,
    this.allowDecimal = true,
  });

  Widget _buildKey(String text, VoidCallback onTap, BuildContext context) {
    return Expanded(
      child: KeyButton(
        text: text,
        onTap: onTap,
        height: MediaQuery.of(context).size.height * 0.075,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            height: MediaQuery.of(context).size.height * 0.075,
            padding: const EdgeInsets.fromLTRB(16, 32, 16, 0),
            child: Text(
              fieldName,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          Container(
            width: double.infinity,
            height: MediaQuery.of(context).size.height * 0.18,
            padding: const EdgeInsets.fromLTRB(0, 4, 0, 32),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 100),
              transitionBuilder: (Widget child, Animation<double> animation) {
                return ScaleTransition(
                  scale: animation,
                  child: FadeTransition(
                    opacity: animation,
                    child: child,
                  ),
                );
              },
              child: Text(
                currentValue.isEmpty ? '0' : currentValue,
                key: ValueKey<String>(currentValue),
                style: const TextStyle(
                  fontSize: 56,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          Row(
            children: [
              _buildKey('7', () => onNumberTap('7'), context),
              const SizedBox(width: 8),
              _buildKey('8', () => onNumberTap('8'), context),
              const SizedBox(width: 8),
              _buildKey('9', () => onNumberTap('9'), context),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _buildKey('4', () => onNumberTap('4'), context),
              const SizedBox(width: 8),
              _buildKey('5', () => onNumberTap('5'), context),
              const SizedBox(width: 8),
              _buildKey('6', () => onNumberTap('6'), context),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _buildKey('1', () => onNumberTap('1'), context),
              const SizedBox(width: 8),
              _buildKey('2', () => onNumberTap('2'), context),
              const SizedBox(width: 8),
              _buildKey('3', () => onNumberTap('3'), context),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _buildKey(allowDecimal ? '.' : '', allowDecimal ? () => onNumberTap('.') : () {}, context),
              const SizedBox(width: 8),
              _buildKey('0', () => onNumberTap('0'), context),
              const SizedBox(width: 8),
              _buildKey('backspace', onBackspace, context),
            ],
          ),
          SizedBox(height: MediaQuery.of(context).size.height * 0.05),
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.5,
            height: MediaQuery.of(context).size.height * 0.075,
            child: ElevatedButton(
              onPressed: onDone,
              style: ElevatedButton.styleFrom(
                elevation: 0,
                backgroundColor: Color(0xFFFF1700),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
              child: const Text(
                '完成',
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
