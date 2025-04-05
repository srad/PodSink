import 'package:flutter/material.dart';

/// A button that shows a busy indicator and becomes disabled when processing.
class BusyButton extends StatelessWidget {
  final bool isBusy;
  final String label;
  final VoidCallback? onPressed;

  /// Optional style for the ElevatedButton.
  final ButtonStyle? style;

  /// Optional size for the CircularProgressIndicator. Defaults to 16.0.
  final double indicatorSize;

  /// Optional color for the CircularProgressIndicator.
  /// Defaults to the button's foreground color if null.
  final Color? indicatorColor;

  ButtonStyle? defaultStyle;

  /// Optional stroke width for the CircularProgressIndicator. Defaults to 2.0.
  final double indicatorStrokeWidth;

  /// Creates a button that can display a busy state.
  ///
  /// The [isBusy] flag controls the state. When true, a
  /// [CircularProgressIndicator] is shown, and the button is disabled.
  /// The [label] is the text shown on the button.
  /// The [onPressed] callback is triggered when the button is tapped,
  /// but only if [isBusy] is false.
  BusyButton({super.key, this.defaultStyle, required this.isBusy, required this.label, required this.onPressed, this.style, this.indicatorSize = 16.0, this.indicatorColor, this.indicatorStrokeWidth = 4.0});

  @override
  Widget build(BuildContext context) {
    defaultStyle ??= ElevatedButton.styleFrom(
      // Set the background color to the theme's primary color
      backgroundColor: isBusy ? Theme.of(context).colorScheme.primary.withAlpha(100) : Theme.of(context).colorScheme.primary,
      // Set the text/icon color to the theme's 'onPrimary' color for contrast
      foregroundColor: Theme.of(context).colorScheme.onPrimary,
      // You can customize other properties like padding, shape, etc. here
      padding: EdgeInsets.symmetric(horizontal: 25, vertical: 15),
      textStyle: TextStyle(fontSize: 20),
    );

    // Determine the onPressed behavior based on the busy state
    final VoidCallback? effectiveOnPressed = isBusy ? null : onPressed;

    // Determine the indicator color, defaulting to the button's foreground
    // final Color finalIndicatorColor = indicatorColor ?? (style?.foregroundColor?.resolve({}) ?? Theme.of(context).colorScheme.onPrimary);

    return ElevatedButton(
      style: defaultStyle,
      // Disable the button by setting onPressed to null when busy
      onPressed: effectiveOnPressed,
      child: Row(
        mainAxisSize: MainAxisSize.min, // Fit content horizontally
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(label),
          if (isBusy) ...[
            const SizedBox(width: 12.0), // Spacing between indicator and label
            //SizedBox(width: indicatorSize, height: indicatorSize, child: CircularProgressIndicator(strokeWidth: indicatorStrokeWidth, valueColor: AlwaysStoppedAnimation<Color>(finalIndicatorColor))),
            SizedBox(width: indicatorSize, height: indicatorSize, child: CircularProgressIndicator(strokeWidth: indicatorStrokeWidth, color: Colors.white)),
          ],
        ],
      ),
    );
  }
}
