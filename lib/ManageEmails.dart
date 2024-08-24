import 'dart:convert';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';
import 'package:http/http.dart' as http;

class ManageEmails {
  bool isSendingEmail = false;
  String gmailEmail = 'ai.4.pediatric.difficult@enis.tn';
  String gmailPassword = 'NZ2Tq7nTy*&N6uP&';

  final gmailSmtp = gmail("ai.4.pediatric.difficult@enis.tn", "put_aacount_password_here");

  Future<void> sendEmailAndroid(String recipient, String subject, String htmlContent) async {
    final message = Message()
      ..from = Address(gmailEmail, 'MedApp')
      ..recipients.add(recipient)
      ..subject = subject
      ..html = htmlContent;

    try {
      isSendingEmail = true;
      final sendReport = await send(message, gmailSmtp);
      print('Message sent: ' + sendReport.toString());
    } on MailerException catch (e) {
      print('Message not sent. \n' + e.toString());
    } finally {
      isSendingEmail = false;
    }
  }

  Future  sendEmailWeb(String recipient, String subject, String htmlContent) async {
    final url = Uri.parse("https://api.emailjs.com/api/v1.0/email/send");
    const serviceId = "service_x9abueb";
    const templateId= "template_k96prdc";
    const userId = "PeyTVk2ZJqbuCukEh" ;
    final response = await http.post(url,
    headers: {"Content-Type": "application/json"},
        body: json.encode({
          "service_id": serviceId,
          "template_id": templateId,
          "user_id": userId,
          "template_params": {
            "subject": subject,
            "message": htmlContent,
            "user_email": recipient,
        }
        })
    );
    return response.statusCode;
  }

  Future<void> sendApprovalEmail(String recipient) async {
    String subject = 'Approval Notification';
    String htmlContent = '<h1>Féliciations!</h1><p>Votre demande de creation du compte a été bien approuvée!<br> Connectez vous maintenant !</p>';

    if (kIsWeb) {
      await sendEmailWeb(recipient, subject, 'Féliciations! Votre demande de creation du compte a été bien approuvée!');
    } else {
      await sendEmailAndroid(recipient, subject, htmlContent);
    }
  }

  Future<void> sendRejectionEmail(String recipient) async {
    String subject = 'Rejection Notification';
    String htmlContent = "<h1>Désolé!</h1><p>Votre demande de creation du compte est refusée. Contactez l'administrateur pour plus d'informations.</p>";

    if (kIsWeb) {
      await sendEmailWeb(recipient, subject, "Désolé! Votre demande de creation du compte est refusée. Contactez l'administrateur pour plus d'informations.");
    } else {
      await sendEmailAndroid(recipient, subject, htmlContent);
    }
  }
}
