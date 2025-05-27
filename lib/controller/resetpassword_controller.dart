import  'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';
import 'dart:math'; // Random key generator
import 'package:flutter_dotenv/flutter_dotenv.dart';


class ResetPassword {
  bool _isSending = false;

  Future<int> sendEmail(String email) async {
    await dotenv.load();  // Ensure .env is loaded

    String username = dotenv.env['USERNAME_GMAIL'] ?? '';
    String password = dotenv.env['PASSWORD_GMAIL'] ?? '';

    final smtpServer = gmail(username, password);

    final verificationCode = generateVerificationCode();

    final message = Message()
      ..from = Address(username, 'HeartCare') // Replace with your app name
      ..recipients.add(email) // Recipient email
      ..subject = '(HeartCare) Your Verification Code - ${DateTime.now().toLocal()}'
      ..html = """
        <div style="font-family: Arial, sans-serif; padding: 20px; line-height: 1.5;">
          <h2 style="color: #4CAF50;">Password Verification</h2>
          <p>Hi,</p>
          <p>Your password verification code is:</p>
          <div style="font-size: 20px; font-weight: bold; color: #333; margin: 20px 0;">
            $verificationCode
          </div>
          <p>Please enter this code in the app to complete your verification process.</p>
        </div>
      """;

    try {
      // Send the email and handle any exceptions
      _isSending = true;
      final sendReport = await send(message, smtpServer);
      print('Message sent: ${sendReport.toString()}');
      return int.parse(verificationCode); // Return the verification code as an integer
    } on MailerException catch (e) {
      print('Message not sent.');
      for (var p in e.problems) {
        print('Problem: ${p.code}: ${p.msg}');
      }
    } finally {
      _isSending = false;
    }

    return 0; // Return 0 if something went wrong
  }

  String generateVerificationCode() {
    final random = Random();
    return (100000 + random.nextInt(900000)).toString(); // 6-digit code
  }
}
