import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/providers/theme_provider.dart';
import '../lead_provider.dart';

class LeadCreationScreen extends ConsumerStatefulWidget {
  const LeadCreationScreen({super.key});

  @override
  ConsumerState<LeadCreationScreen> createState() => _LeadCreationScreenState();
}

class _LeadCreationScreenState extends ConsumerState<LeadCreationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _mobileController = TextEditingController();
  final _emailController = TextEditingController();
  final _notesController = TextEditingController();
  
  String _selectedSource = 'WALK_IN';
  String _selectedInterest = 'Medium';
  DateTime? _trialDate;
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _mobileController.dispose();
    _emailController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      await ref.read(leadListProvider.notifier).createLead({
        'fullName': _nameController.text.trim(),
        'mobile': _mobileController.text.trim(),
        'email': _emailController.text.trim(),
        'notes': _notesController.text.trim(),
        'source': _selectedSource,
        'interestLevel': _selectedInterest,
        'trialDate': _trialDate != null ? _trialDate!.toIso8601String().split('T')[0] : null,
      });
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = ref.watch(themeModeProvider) == ThemeMode.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Lead', style: TextStyle(fontWeight: FontWeight.w900)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: AppTheme.pageBackground(isDark: isDark),
        child: Stack(
          children: [
            Positioned.fill(
              child: DecoratedBox(
                decoration: AppTheme.foregroundGlow(isDark: isDark),
              ),
            ),
            SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildField(_nameController, 'Full Name', Icons.person_outline, isDark),
                      const SizedBox(height: 16),
                      _buildField(_mobileController, 'Mobile Number', Icons.phone_android, isDark, keyboardType: TextInputType.phone),
                      const SizedBox(height: 16),
                      _buildField(_emailController, 'Email Address (Optional)', Icons.email_outlined, isDark, keyboardType: TextInputType.emailAddress),
                      const SizedBox(height: 24),
                      Text('Source', style: TextStyle(fontWeight: FontWeight.bold, color: isDark ? Colors.white70 : Colors.black54)),
                      const SizedBox(height: 8),
                      _buildSourceDropdown(isDark),
                      const SizedBox(height: 24),
                      Text('Interest Level', style: TextStyle(fontWeight: FontWeight.bold, color: isDark ? Colors.white70 : Colors.black54)),
                      const SizedBox(height: 8),
                      _buildInterestToggles(isDark),
                      const SizedBox(height: 24),
                      Text('Trial Session', style: TextStyle(fontWeight: FontWeight.bold, color: isDark ? Colors.white70 : Colors.black54)),
                      const SizedBox(height: 8),
                      _buildTrialPicker(isDark),
                      const SizedBox(height: 24),
                      _buildField(_notesController, 'Notes / Requirements', Icons.note_add_outlined, isDark, maxLines: 3),
                      const SizedBox(height: 40),
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _submit,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          ),
                          child: _isLoading 
                            ? const CircularProgressIndicator(color: Colors.white)
                            : const Text('SAVE LEAD', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildField(TextEditingController controller, String label, IconData icon, bool isDark, {TextInputType? keyboardType, int maxLines = 1}) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      style: TextStyle(color: isDark ? Colors.white : Colors.black),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: AppColors.primary),
        filled: true,
        fillColor: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.05),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
      ),
      validator: (value) {
        if (label == 'Full Name' && (value == null || value.isEmpty)) return 'Please enter name';
        if (label == 'Mobile Number' && (value == null || value.isEmpty)) return 'Please enter mobile';
        return null;
      },
    );
  }

  Widget _buildSourceDropdown(bool isDark) {
    final sources = ['WALK_IN', 'INSTAGRAM', 'FACEBOOK', 'GOOGLE', 'REFERRAL', 'OTHER'];
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedSource,
          isExpanded: true,
          dropdownColor: isDark ? const Color(0xFF101018) : Colors.white,
          onChanged: (val) => setState(() => _selectedSource = val!),
          items: sources.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
        ),
      ),
    );
  }

  Widget _buildInterestToggles(bool isDark) {
    final levels = ['Low', 'Medium', 'High'];
    return Row(
      children: levels.map((l) {
        final isSelected = _selectedInterest == l;
        return Expanded(
          child: GestureDetector(
            onTap: () => setState(() => _selectedInterest = l),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : (isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.05)),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: isSelected ? AppColors.primary : Colors.transparent),
              ),
              child: Center(
                child: Text(
                  l,
                  style: TextStyle(
                    color: isSelected ? Colors.white : (isDark ? Colors.white70 : Colors.black54),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildTrialPicker(bool isDark) {
    return GestureDetector(
      onTap: () async {
        final date = await showDatePicker(
          context: context,
          initialDate: DateTime.now(),
          firstDate: DateTime.now(),
          lastDate: DateTime.now().add(const Duration(days: 30)),
        );
        if (date != null) setState(() => _trialDate = date);
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.05),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            const Icon(Icons.calendar_today_rounded, color: AppColors.primary, size: 20),
            const SizedBox(width: 12),
            Text(
              _trialDate == null ? 'Schedule Trial (Optional)' : 'Trial on ${DateFormat('MMM dd, yyyy').format(_trialDate!)}',
              style: TextStyle(color: isDark ? Colors.white70 : Colors.black87),
            ),
            const Spacer(),
            if (_trialDate != null)
              IconButton(
                onPressed: () => setState(() => _trialDate = null),
                icon: const Icon(Icons.close_rounded, size: 18),
                constraints: const BoxConstraints(),
                padding: EdgeInsets.zero,
              ),
          ],
        ),
      ),
    );
  }
}
