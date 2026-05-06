import 'package:flutter/material.dart';

class NotificationForm extends StatefulWidget {
  final bool isSegmented;
  final bool isSending;
  final Function({
    required String title,
    required String body,
    String? imageUrl,
    String? segment,
  }) onSend;

  const NotificationForm({
    super.key,
    required this.isSegmented,
    required this.isSending,
    required this.onSend,
  });

  @override
  State<NotificationForm> createState() => _NotificationFormState();
}

class _NotificationFormState extends State<NotificationForm> {
  final _titleController = TextEditingController();
  final _bodyController = TextEditingController();
  final _imageController = TextEditingController();
  String _selectedSegment = 'free';

  static const Color _accent = Color(0xFFFF6B00);
  static const Color _cardColor = Color(0xFF1A1A1A);

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    _imageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildInput(
          controller: _titleController,
          label: 'Title',
          hint: 'Notification title...',
          icon: Icons.title,
        ),
        const SizedBox(height: 14),
        _buildInput(
          controller: _bodyController,
          label: 'Message',
          hint: 'Write your message...',
          icon: Icons.message_outlined,
          maxLines: 3,
        ),
        if (!widget.isSegmented) ...[
          const SizedBox(height: 14),
          _buildInput(
            controller: _imageController,
            label: 'Image URL (Optional)',
            hint: 'https://example.com/image.png',
            icon: Icons.image_outlined,
          ),
        ],
        if (widget.isSegmented) ...[
          const SizedBox(height: 14),
          const Text(
            'Target Segment',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: ['free', 'premium', 'all'].map((seg) {
              final isSelected = _selectedSegment == seg;
              return Padding(
                padding: const EdgeInsets.only(right: 10),
                child: GestureDetector(
                  onTap: () => setState(() => _selectedSegment = seg),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected ? _accent : _cardColor,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isSelected
                            ? _accent
                            : Colors.white.withOpacity(0.1),
                      ),
                    ),
                    child: Text(
                      seg[0].toUpperCase() + seg.substring(1),
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.white54,
                        fontSize: 14,
                        fontWeight: isSelected
                            ? FontWeight.w600
                            : FontWeight.normal,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: widget.isSending
                ? null
                : () {
                    widget.onSend(
                      title: _titleController.text.trim(),
                      body: _bodyController.text.trim(),
                      imageUrl: _imageController.text.trim(),
                      segment:
                          widget.isSegmented ? _selectedSegment : null,
                    );
                  },
            style: ElevatedButton.styleFrom(
              backgroundColor: _accent,
              foregroundColor: Colors.white,
              disabledBackgroundColor: _accent.withOpacity(0.4),
              elevation: 0,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: widget.isSending
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Text(
                    'Send Notification',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildInput({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          maxLines: maxLines,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.white.withOpacity(0.3)),
            prefixIcon: Icon(icon, color: Colors.white38, size: 20),
            filled: true,
            fillColor: const Color(0xFF1A1A1A),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide:
                  BorderSide(color: Colors.white.withOpacity(0.08)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide:
                  BorderSide(color: Colors.white.withOpacity(0.08)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Color(0xFFFF6B00)),
            ),
          ),
        ),
      ],
    );
  }
}