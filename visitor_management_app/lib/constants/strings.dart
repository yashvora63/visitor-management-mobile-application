import 'package:flutter/material.dart';

class Strings {
  Strings._();

  static final GlobalKey<NavigatorState> appNavigatorKey =
      GlobalKey<NavigatorState>();

  // General & Branding
  static const String appName = "Visitor Management App";
  static const String appTitleName = "Visitor Management App";
  static const String companyName = "Sumadhura Group";

  // Navigation & Modules
  static const String dashboard = "Dashboard";
  static const String visitors = "Visitors";
  static const String visitorList = "Visitor Directory";
  static const String registerVisitor = "Register Visitor";
  static const String editVisitor = "Edit Visitor";
  static const String visitorDetails = "Visitor Details";
  static const String scanQrCode = "Scan QR Code";
  static const String qrScanner = "QR Scanner";

  // Dashboard Metrics
  static const String totalVisitorsToday = "Total Visitors Today";
  static const String currentlyCheckedIn = "Currently Checked In";
  static const String checkedOutToday = "Checked Out Today";

  // Form Fields & Labels
  static const String visitorName = "Visitor Name";
  static const String mobileNumber = "Mobile Number";
  static const String email = "Email Address";
  static const String visitorType = "Visitor Type";
  static const String project = "Project";
  static const String purposeOfVisit = "Purpose of Visit";
  static const String status = "Status";
  static const String checkInTime = "Check-In Time";
  static const String checkOutTime = "Check-Out Time";
  static const String createdAt = "Registered At";

  // Status Values
  static const String statusRegistered = "Registered";
  static const String statusCheckedIn = "Checked In";
  static const String statusCheckedOut = "Checked Out";

  // Actions
  static const String checkIn = "Check In";
  static const String checkOut = "Check Out";
  static const String save = "Save";
  static const String cancel = "Cancel";
  static const String confirm = "Confirm";
  static const String delete = "Delete";
  static const String edit = "Edit";
  static const String retry = "Retry";
  static const String search = "Search";
  static const String searchPlaceholder = "Search by name or mobile number...";

  // Dialogs & Feedback
  static const String deleteConfirmTitle = "Delete Visitor";
  static const String deleteConfirmMessage =
      "Are you sure you want to delete this visitor record? This action cannot be undone.";
  static const String invalidQrCode = "Invalid QR code. Please try again.";
  static const String visitorNotFound =
      "Visitor not found for the scanned QR code.";
  static const String duplicateCheckInError = "Visitor is already checked in.";
  static const String visitCompletedError =
      "Visitor visit is already completed.";

  // Theme Modes
  static const String theme = "Theme";
  static const String lightTheme = "Light (Gold Cream)";
  static const String darkTheme = "Dark (Obsidian Gold)";
  static const String systemTheme = "System Default";

  // Feedback States
  static const String loading = "Loading...";
  static const String success = "Success";
  static const String error = "Error";
  static const String noDataFound = "No visitors found";

  static const String warningTitleText = "warning_title_text";
  static const String successTitleText = "success_title_text";
  static const String errorTitleText = "error_title_text";
}
