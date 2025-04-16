import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

const mainPurple = Color(0xFFB799E6);
const lighterPurple = Color(0xFFF4EDFE);
const borderGray = Color(0xFFE5E7EB);
const halfOpacityGray = Color(0x77E5E7EB);
const baseUrl = 'http://127.0.0.1:8000';
const baseProfileImageLink = "https://firebasestorage.googleapis.com/v0/b/chateo-72766.appspot.com/o/freepik__silhouette-of-a-hispanic-male-chef-in-a-bustling-r__45380.jpeg?alt=media&token=7043f273-ec2c-4feb-bbbc-aca258b3768c";

const baseRecipeImageLink =	"https://firebasestorage.googleapis.com/v0/b/chateo-72766.appspot.com/o/freepik__the-style-is-3d-model-with-octane-render-volumetri__20092.png?alt=media&token=7f4c99b7-e092-4e7c-b2b8-865138c2ea4f";

TextStyle openSans({TextStyle? style}) {
  return GoogleFonts.openSans(textStyle: style);
}

TextStyle poppins({TextStyle? style}) {
  return GoogleFonts.poppins(textStyle: style);
}

String formatDate(String json) {
  // Parse the input date string
  DateTime dateTime = DateTime.parse(json);

  // Format the date as "dd MMM yyyy"
  String formattedDate =
      "${dateTime.day} ${_getMonthAbbreviation(dateTime.month)} ${dateTime.year}";
  return formattedDate;
}

// Helper method to get month abbreviation
String _getMonthAbbreviation(int month) {
  const monthAbbreviations = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec'
  ];
  return monthAbbreviations[month - 1];
}
