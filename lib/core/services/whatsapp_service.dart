import 'package:url_launcher/url_launcher.dart';

class WhatsappService {
  static Future<void> sendMessage({
    required String phone,
    required String message,
  }) async {
    // Normalize phone number (remove non-digits, ensure country code)
    String cleanPhone = phone.replaceAll(RegExp(r'\D'), '');
    if (cleanPhone.length == 10) {
      cleanPhone = '91$cleanPhone'; // Default to India
    }

    final String url = "https://wa.me/$cleanPhone?text=${Uri.encodeComponent(message)}";
    final Uri uri = Uri.parse(url);

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      throw 'Could not launch WhatsApp';
    }
  }

  static Future<void> sendWelcomeMessage(String name, String phone) async {
    final message = "Hi $name! Welcome to our gym. We're excited to have you on board! 💪";
    await sendMessage(phone: phone, message: message);
  }

  static Future<void> sendPaymentReminder(String name, String phone, String amount) async {
    final message = "Hi $name, a quick reminder that your membership payment of ₹$amount is due. Please clear it at the front desk. Thank you! 🙏";
    await sendMessage(phone: phone, message: message);
  }
}
