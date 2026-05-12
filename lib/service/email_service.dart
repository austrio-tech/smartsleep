// ─────────────────────────────────────────────────────────────────────────────
// email_service.dart  –  Client-side email relay via Google Apps Script.
//
// NOTE: All five notification scenarios (signup, login, sleep report, profile
// update, password reset) are now handled SERVER-SIDE (backend → Google Script).
// This class is kept for any future client-triggered email needs.
//
// How it works:
//   1. Build an HTML email body
//   2. POST a JSON payload to the Google Apps Script web app URL
//   3. The GAS script verifies the token and sends via Gmail
// ─────────────────────────────────────────────────────────────────────────────

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

/// Client-side email relay via Google Apps Script.
///
/// All 5 notification scenarios (signup, login, report, profile update,
/// password reset) are now handled server-side (backend → Google Script).
/// This class is kept for any future client-triggered emails.
///
/// Usage:
///   final svc = EmailService(
///     scriptUrl: 'https://script.google.com/...',
///     token: 'YOUR_TOKEN',
///     senderName: 'Smart Sleep Service',
///   );
///   await svc.sendGoogleEmail(recipientEmails: 'a@b.com', subject: '...', htmlBody: '...');
class EmailService {
  const EmailService({
    required this.scriptUrl,
    required this.token,
    this.senderName = 'Smart Sleep Service',
  });

  /// The Google Apps Script web app URL (deploy as web app with "Anyone" access).
  final String scriptUrl;

  /// Secret token the GAS script checks to authenticate requests.
  /// Prevents unauthorized parties from using the relay.
  final String token;

  /// The display name shown as the email sender (e.g., "Smart Sleep Service").
  final String senderName;

  /// Sends an HTML email to one or more recipients via Google Apps Script.
  ///
  /// [recipientEmails] can be either:
  ///   - A single string: "user@example.com"
  ///   - A List<String>: ["user1@example.com", "user2@example.com"]
  ///
  /// Returns a Map with:
  ///   {'success': true, 'message': 'Email sent', 'recipients': '...'}  on success
  ///   {'success': false, 'message': 'error description'}               on failure
  Future<Map<String, dynamic>> sendGoogleEmail({
    required dynamic recipientEmails,
    required String subject,
    required String htmlBody,
  }) async {
    debugPrint('--- EmailService: Attempting to send email ---');

    // Normalise recipient(s) to a comma-separated string
    final to = recipientEmails is List<String>
        ? recipientEmails.join(',')
        : recipientEmails.toString();

    // Build the JSON payload expected by the Google Apps Script
    final payload = {
      'token': token,        // Authentication token
      'to': to,              // Recipient email address(es)
      'subject': subject,    // Email subject line
      'body': htmlBody,      // HTML email content
      'name': senderName,    // Sender display name
      'attachments': <dynamic>[], // No attachments
    };

    try {
      // Use `http.Request` instead of `http.post()` to enable `followRedirects`.
      // Google Apps Script often returns a 302 redirect that must be followed.
      final request = http.Request('POST', Uri.parse(scriptUrl))
        ..headers['Content-Type'] = 'application/json'
        ..body = jsonEncode(payload)
        ..followRedirects = true;

      // `send()` returns a `StreamedResponse` — we must read it into a full Response
      final streamed = await request.send().timeout(const Duration(seconds: 25));
      final response = await http.Response.fromStream(streamed);

      debugPrint('EmailService response: ${response.statusCode}');

      // GAS returns HTTP 200 with "Success" in the body, or a 302 redirect, on success
      if ((response.statusCode == 200 && response.body.contains('Success')) ||
          response.statusCode == 302) {
        return {'success': true, 'message': 'Email sent', 'recipients': to};
      }
      return {'success': false, 'message': 'Server returned ${response.statusCode}'};
    } catch (e) {
      debugPrint('EmailService error: $e');
      return {'success': false, 'message': 'Network error: $e'};
    }
  }
}
