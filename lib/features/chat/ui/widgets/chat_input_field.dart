import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ChatInputField extends StatelessWidget {
  const ChatInputField({
    super.key,
    required this.controller,
    required this.onSend,
    required this.isLoading,
    required this.showSuggestions,
    this.attachedImagePath,
    this.onAttachImage,
    this.onRemoveAttachment,
    this.onSuggestionTap,
  });

  final TextEditingController controller;
  final VoidCallback onSend;
  final bool isLoading;
  final bool showSuggestions;
  final String? attachedImagePath;
  final Future<void> Function()? onAttachImage;
  final VoidCallback? onRemoveAttachment;
  final ValueChanged<String>? onSuggestionTap;

  KeyEventResult _handleKeyPress(KeyEvent event) {
    if (event is! KeyDownEvent) {
      return KeyEventResult.ignored;
    }

    if (event.logicalKey == LogicalKeyboardKey.enter &&
        !HardwareKeyboard.instance.isShiftPressed) {
      onSend();
      return KeyEventResult.handled;
    }

    return KeyEventResult.ignored;
  }

  static const List<String> _suggestions = [
    'Summarize this topic for me',
    'Give me important exam questions',
    'Explain in simple language',
  ];

  Future<void> _pasteFromClipboard(BuildContext context) async {
    final clipboardData = await Clipboard.getData(Clipboard.kTextPlain);
    final pastedText = clipboardData?.text?.trim();

    if (pastedText == null || pastedText.isEmpty) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Clipboard is empty')),
      );
      return;
    }

    final updatedText =
        '${controller.text}${controller.text.isEmpty ? '' : '\n'}$pastedText';
    controller.value = TextEditingValue(
      text: updatedText,
      selection: TextSelection.collapsed(offset: updatedText.length),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final width = MediaQuery.of(context).size.width;
    final isPhoneWidth = width < 520;
    final inputRadius = isPhoneWidth ? 22.0 : 28.0;
    final sendButtonSize = isPhoneWidth ? 44.0 : 52.0;
    final toolbarIconSize = isPhoneWidth ? 20.0 : 24.0;

    return DecoratedBox(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: Color(0xFFDCE3ED)),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (attachedImagePath != null) ...[
                AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFFF6FAFF),
                        Color(0xFFEAF4FF),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(color: const Color(0xFFD5E4F4)),
                  ),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.file(
                          File(attachedImagePath!),
                          width: isPhoneWidth ? 56 : 72,
                          height: isPhoneWidth ? 56 : 72,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Image attached',
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF163A66),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Send it with a question or keep it ready as a diagram reference.',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: const Color(0xFF5D6B7D),
                                height: 1.35,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        tooltip: 'Remove attachment',
                        onPressed: isLoading ? null : onRemoveAttachment,
                        icon: const Icon(Icons.close_rounded),
                      ),
                    ],
                  ),
                ),
              ],
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 220),
                child: showSuggestions
                    ? Column(
                        key: const ValueKey('suggestions'),
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: _suggestions.map((suggestion) {
                              return ActionChip(
                                label: Text(suggestion),
                                backgroundColor: const Color(0xFFF2F6FB),
                                side:
                                    const BorderSide(color: Color(0xFFD7E2F0)),
                                onPressed: onSuggestionTap == null
                                    ? null
                                    : () => onSuggestionTap!(suggestion),
                              );
                            }).toList(),
                          ),
                          const SizedBox(height: 12),
                        ],
                      )
                    : const SizedBox.shrink(key: ValueKey('no-suggestions')),
              ),
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFF6F8FB),
                  borderRadius: BorderRadius.circular(inputRadius),
                  border: Border.all(color: const Color(0xFFD7E2F0)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: GestureDetector(
                  onLongPress:
                      isLoading ? null : () => _pasteFromClipboard(context),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      IconButton(
                        tooltip: 'Attach image',
                        onPressed: isLoading || onAttachImage == null
                            ? null
                            : () => onAttachImage!(),
                        icon: Icon(
                          Icons.add_photo_alternate_outlined,
                          size: toolbarIconSize,
                        ),
                      ),
                      IconButton(
                        tooltip: 'Paste',
                        onPressed:
                            isLoading ? null : () => _pasteFromClipboard(context),
                        icon: Icon(
                          Icons.content_paste_rounded,
                          size: toolbarIconSize,
                        ),
                      ),
                      Expanded(
                        child: Focus(
                          onKeyEvent: (_, event) => _handleKeyPress(event),
                          child: TextField(
                            controller: controller,
                            minLines: 1,
                            maxLines: isPhoneWidth ? 4 : 6,
                            keyboardType: TextInputType.multiline,
                            textInputAction: TextInputAction.newline,
                            textCapitalization: TextCapitalization.sentences,
                            decoration: const InputDecoration(
                              hintText:
                                  'Ask UniGuide anything from your syllabus',
                              border: InputBorder.none,
                              contentPadding:
                                  EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(right: 8, bottom: 6),
                        child: FilledButton(
                          onPressed: isLoading ? null : onSend,
                          style: FilledButton.styleFrom(
                            backgroundColor: const Color(0xFF1B4D8C),
                            foregroundColor: Colors.white,
                            minimumSize:
                                Size(sendButtonSize, sendButtonSize),
                            padding: EdgeInsets.zero,
                            shape: const CircleBorder(),
                          ),
                          child: isLoading
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Icon(Icons.arrow_upward_rounded),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
