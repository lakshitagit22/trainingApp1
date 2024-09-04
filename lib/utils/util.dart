import 'package:flutter/material.dart';
import 'package:another_flushbar/flushbar.dart';



// Function to display a flushbar message on the screen (assuming using another_flushbar package)
void showFlushbarMessage(BuildContext context, String message , Colors backgroundColor , FlushbarPosition position) {
  // Create a Flushbar to display the error message
  Flushbar(
    // Set margin around the Flushbar
    margin: const EdgeInsets.all(10),
    // Set background color to be displayed
    backgroundColor: backgroundColor,
    // Set animation duration for showing the Flushbar
    animationDuration: const Duration(seconds: 1),
    // Set animation curve for showing the Flushbar (bounce in effect)
    forwardAnimationCurve: Curves.bounceIn,
    // Set the direction for dismissing the Flushbar (swipes up)
    dismissDirection: FlushbarDismissDirection.VERTICAL,
    // Set the duration for which the Flushbar will be displayed
    duration: null,
    // Set the position of the Flushbar on the screen (top or Bottom)
    flushbarPosition: position,
    // Set the style of the Flushbar (floating in this case)
    flushbarStyle: FlushbarStyle.FLOATING,
    // Set the error message to be displayed
    message: message,
    // Set the color of the message text to white
    messageColor: Colors.white,
    // Set the font size of the message text
    messageSize: 18,
    // Set the border radius for the corners of the Flushbar
    borderRadius: const BorderRadius.all(Radius.circular(10)),
    // Add a main button to close the Flushbar
    mainButton: TextButton(
      onPressed: () {
        // Close the Flushbar when the button is tapped
        Navigator.of(context).pop();
      },
      child: const Icon(
        Icons.close,
        color: Colors.white,
      ),
    ),
  ).show(context);
}