
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/core/theme/app_theme.dart';
import 'package:mobile/core/extensions/build_context_extensions.dart';

class PremiumChatInput extends StatefulWidget {
  final TextEditingController controller;
  final VoidCallback onSend;
  final VoidCallback onToggleListening;
  final bool isSending;
  final bool isListening;

  const PremiumChatInput({
    super.key,
    required this.controller,
    required this.onSend,
    required this.onToggleListening,
    this.isSending = false,
    this.isListening = false,
  });

  @override
  State<PremiumChatInput> createState() => _PremiumChatInputState();
}

class _PremiumChatInputState extends State<PremiumChatInput> with SingleTickerProviderStateMixin {
  bool _isFocused = false;
  late AnimationController _micPulseController;
  late FocusNode _focusNode; // Persistent focus management

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    
    // Track focus to handle "technical" styling if needed later
    _focusNode.addListener(() {
      setState(() {
        _isFocused = _focusNode.hasFocus;
      });
    });

    // "Push to talk" style attention grabber (breathing effect)
    _micPulseController = AnimationController(
             vsync: this,
             duration: const Duration(milliseconds: 1500),
           )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _micPulseController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // V5 DESIGN: "Technical Rectangular" - 45px Height, Square Icons, Idle Animation
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: Container(
          height: 45, // STRICT REQUIREMENT: 45px
          decoration: BoxDecoration(
            color: AppTheme.surfaceWhite,
            borderRadius: BorderRadius.circular(12), // Rounded Rectangle (Not Capsule)
            boxShadow: [
              BoxShadow(
                color: AppTheme.navyPrimary.withValues(alpha: 0.08),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
            border: Border.all(
              color: AppTheme.dividerGreyLight,
              width: 1.0,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Voice Button - Square with Idle Animation
              _buildVoiceButton(),
              
              // Text Input - Centered, Persistent Focus
              Expanded(
                 child: Container(
                   // Use a container to strictly center the inner TextField if needed, 
                   // but standard Expanded + TextField usually works best without height constraints if aligned properly.
                   alignment: Alignment.center, 
                   child: TextField(
                    controller: widget.controller,
                    focusNode: _focusNode,
                    // height: 1.0 reduces huge cursor. fontSize 14 is clean.
                    style: AppTheme.bodyPrimaryRegular.copyWith(fontSize: 14, height: 1.0), 
                    textAlignVertical: TextAlignVertical.center, 
                    decoration: InputDecoration(
                      hintText: context.l10n.typeYourResponse,
                      hintStyle: AppTheme.captionGreyRegular,
                      border: InputBorder.none,
                      focusedBorder: InputBorder.none, 
                      enabledBorder: InputBorder.none, 
                      errorBorder: InputBorder.none,   
                      disabledBorder: InputBorder.none,
                      isDense: true,
                      // Zero padding is critical for perfect center alignment with TextAlignVertical.center
                      contentPadding: EdgeInsets.zero, 
                    ),
                    textCapitalization: TextCapitalization.sentences,
                    textInputAction: TextInputAction.send, 
                    onSubmitted: (_) {
                       widget.onSend();
                       // KEEP FOCUS: Wait for rebuild/send to process, then force focus back
                       Future.delayed(const Duration(milliseconds: 50), () {
                         if (mounted) _focusNode.requestFocus();
                       });
                    },
                    enabled: !widget.isSending,
                    maxLines: 1, 
                  ),
                ),
              ),
              
              // Send Button - Square
              _buildSendButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVoiceButton() {
    // "Botón Micrófono con animación estilo push to talk mientras no se este usando"
    final bool isIdle = !widget.isListening && !widget.isSending;
    
    return GestureDetector(
      onTap: widget.onToggleListening,
      child: AnimatedBuilder(
        animation: _micPulseController,
        builder: (context, child) {
           double scale = 1.0;
           Color borderColor = Colors.transparent;
           
           if (isIdle) {
             // Subtle pulse to invite interaction
             scale = 1.0 + (_micPulseController.value * 0.15); // Slight increased scale
             // Increased opacity to 0.4 so user actually SEES it
             borderColor = AppTheme.navyPrimary.withValues(alpha: 0.4 * _micPulseController.value);
           }
           
           return Container(
            margin: const EdgeInsets.only(left: 6, right: 6),
            height: 34, 
            width: 34,
            decoration: BoxDecoration(
              // Square with slight rounding
              borderRadius: BorderRadius.circular(8), 
              color: widget.isListening ? AppTheme.errorRed.withValues(alpha: 0.1) : Colors.transparent,
              border: Border.all(
                color: widget.isListening ? AppTheme.errorRed : borderColor,
                width: 1.5, // Slightly thicker border for visibility
              )
            ),
            child: Transform.scale(
              scale: isIdle ? scale : 1.0,
              child: Icon(
                widget.isListening ? Icons.mic : Icons.mic_none_outlined,
                color: widget.isListening ? AppTheme.errorRed : AppTheme.navyPrimary,
                size: 20,
              ),
            ),
          );
        }
      ),
    );
  }

  Widget _buildSendButton() {
    return GestureDetector(
      onTap: widget.isSending ? null : widget.onSend,
      child: Container(
        margin: const EdgeInsets.only(right: 6, left: 6),
        height: 34,
        width: 34,
        decoration: BoxDecoration(
          color: AppTheme.navyPrimary,
          // Square with slight rounding
          borderRadius: BorderRadius.circular(8), 
          boxShadow: [
             BoxShadow(
              color: AppTheme.navyPrimary.withValues(alpha: 0.2),
              blurRadius: 4,
              offset: const Offset(0, 2)
            )
          ],
        ),
        child: widget.isSending
            ? const Padding(
                padding: EdgeInsets.all(8.0),
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : const Icon(
                Icons.arrow_forward_rounded, // Rectangular feel -> Forward arrow works well
                color: Colors.white,
                size: 18,
              ),
      ),
    );
  }
}
