import 'package:shared_preferences/shared_preferences.dart';

class SettingsService {
  static const String _keyCompanyName = 'company_name';
  static const String _keyCompanyPhone = 'company_phone';
  static const String _keyCompanyAddress = 'company_address';
  static const String _keyCompanyLogo = 'company_logo';

  // حفظ بيانات الشركة
  static Future<void> saveCompanyInfo({
    required String name,
    required String phone,
    required String address,
    String? logoPath,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyCompanyName, name);
    await prefs.setString(_keyCompanyPhone, phone);
    await prefs.setString(_keyCompanyAddress, address);
    if (logoPath != null) {
      await prefs.setString(_keyCompanyLogo, logoPath);
    }
  }

  // استرجاع بيانات الشركة
  static Future<Map<String, String>> getCompanyInfo() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'name': prefs.getString(_keyCompanyName) ?? 'اسم الشركة',
      'phone': prefs.getString(_keyCompanyPhone) ?? '',
      'address': prefs.getString(_keyCompanyAddress) ?? '',
      'logo': prefs.getString(_keyCompanyLogo) ?? '',
    };
  }
}