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

  final String scriptUrl;
  final String token;
  final String senderName;

  Future<Map<String, dynamic>> sendGoogleEmail({
    required dynamic recipientEmails,
    required String subject,
    required String htmlBody,
  }) async {
    debugPrint('--- EmailService: Attempting to send email ---');

    final to = recipientEmails is List<String>
        ? recipientEmails.join(',')
        : recipientEmails.toString();

    final payload = {
      'token': token,
      'to': to,
      'subject': subject,
      'body': htmlBody,
      'name': senderName,
      'attachments': <dynamic>[],
    };

    try {
      final request = http.Request('POST', Uri.parse(scriptUrl))
        ..headers['Content-Type'] = 'application/json'
        ..body = jsonEncode(payload)
        ..followRedirects = true;

      final streamed = await request.send().timeout(const Duration(seconds: 25));
      final response = await http.Response.fromStream(streamed);

      debugPrint('EmailService response: ${response.statusCode}');

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
