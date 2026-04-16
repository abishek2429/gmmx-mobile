import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final userProfileProvider = StateProvider<UserProfile>((ref) {
  return UserProfile(
    name: 'Rajesh Kumar',
    email: 'rajesh@gmmx.app',
    phone: '+91 98765 43210',
    role: 'Owner',
    avatar: 'R',
  );
});

final inactivityThresholdProvider = StateProvider<int>((ref) => 15);

class UserProfile {
  final String name, email, phone, role, avatar;
  UserProfile({required this.name, required this.email, required this.phone, required this.role, required this.avatar});

  UserProfile copyWith({String? name, String? email, String? phone}) => UserProfile(
    name: name ?? this.name,
    email: email ?? this.email,
    phone: phone ?? this.phone,
    role: role,
    avatar: avatar,
  );
}

class ProfileSettingsPage extends ConsumerWidget {
  const ProfileSettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(userProfileProvider);
    final threshold = ref.watch(inactivityThresholdProvider);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [const Color(0xFF0f172a), const Color(0xFF1a0f1f)],
              begin: Alignment.topLeft, end: Alignment.bottomRight,
            ),
          ),
          child: Column(
            children: [
              SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        padding: EdgeInsets.zero,
                      ),
                      const Text('Profile & Settings', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w700)),
                    ],
                  ),
                ),
              ),
              Container(
                color: const Color(0xFF1E293B),
                child: TabBar(
                  labelColor: const Color(0xFFFF5C73),
                  unselectedLabelColor: const Color(0xFF64748B),
                  indicatorColor: const Color(0xFFFF5C73),
                  tabs: const [
                    Tab(text: 'Profile'),
                    Tab(text: 'Settings'),
                  ],
                ),
              ),
              Expanded(
                child: TabBarView(
                  children: [
                    _ProfileTab(profile, ref),
                    _SettingsTab(threshold, ref),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProfileTab extends ConsumerWidget {
  final UserProfile profile;
  final WidgetRef ref;
  const _ProfileTab(this.profile, this.ref);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundColor: const Color(0xFFFF5C73).withValues(alpha: 0.2),
                  child: Text(
                    profile.avatar,
                    style: const TextStyle(
                      color: Color(0xFFFF5C73),
                      fontSize: 32,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(profile.name, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w700)),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF5C73).withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    profile.role,
                    style: const TextStyle(color: Color(0xFFFF5C73), fontSize: 12, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Edit Profile', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
                const SizedBox(height: 16),
                _EditableField(
                  label: 'Full Name',
                  initialValue: profile.name,
                  icon: Icons.person,
                  onSave: (value) {
                    ref.read(userProfileProvider.notifier).state = profile.copyWith(name: value);
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profile updated')));
                  },
                ),
                const SizedBox(height: 16),
                _EditableField(
                  label: 'Email',
                  initialValue: profile.email,
                  icon: Icons.email,
                  onSave: (value) {
                    ref.read(userProfileProvider.notifier).state = profile.copyWith(email: value);
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Email updated')));
                  },
                ),
                const SizedBox(height: 16),
                _EditableField(
                  label: 'Phone',
                  initialValue: profile.phone,
                  icon: Icons.phone,
                  onSave: (value) {
                    ref.read(userProfileProvider.notifier).state = profile.copyWith(phone: value);
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Phone updated')));
                  },
                ),
                const SizedBox(height: 32),
                const Divider(color: Color(0xFF334155)),
                const SizedBox(height: 20),
                const Text('App Info', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
                const SizedBox(height: 16),
                _InfoTile('Version', 'v1.0.0'),
                _InfoTile('Build', '2024.001'),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingsTab extends ConsumerWidget {
  final int threshold;
  final WidgetRef ref;
  const _SettingsTab(this.threshold, this.ref);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Notifications', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
            const SizedBox(height: 16),
            _ToggleTile('Push Notifications', true, (value) {}),
            _ToggleTile('Attendance Reminders', true, (value) {}),
            _ToggleTile('Expiry Alerts', true, (value) {}),
            const SizedBox(height: 30),
            const Divider(color: Color(0xFF334155)),
            const SizedBox(height: 20),
            const Text('Inactivity Settings', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            const Text('Mark members inactive after (days)', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12)),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF1E293B),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF334155)),
              ),
              child: Column(
                children: [
                  SliderTheme(
                    data: SliderThemeData(
                      activeTrackColor: const Color(0xFFFF5C73),
                      inactiveTrackColor: const Color(0xFF334155),
                      thumbColor: const Color(0xFFFF5C73),
                      overlayColor: const Color(0xFFFF5C73).withValues(alpha: 0.3),
                    ),
                    child: Slider(
                      value: threshold.toDouble(),
                      min: 5,
                      max: 30,
                      divisions: 5,
                      onChanged: (value) => ref.read(inactivityThresholdProvider.notifier).state = value.toInt(),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('5 days', style: TextStyle(color: Color(0xFF64748B), fontSize: 11)),
                      Text('$threshold days', style: const TextStyle(color: Color(0xFFFF5C73), fontWeight: FontWeight.w600)),
                      const Text('30 days', style: TextStyle(color: Color(0xFF64748B), fontSize: 11)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            const Divider(color: Color(0xFF334155)),
            const SizedBox(height: 20),
            const Text('Account', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: () => _showLogoutDialog(context),
              icon: const Icon(Icons.logout),
              label: const Text('Logout'),
              style: FilledButton.styleFrom(
                backgroundColor: Colors.red.shade700,
                minimumSize: const Size(double.infinity, 50),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        title: const Text('Logout', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
        content: const Text('Are you sure you want to logout?', style: TextStyle(color: Color(0xFF94A3B8))),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Color(0xFF94A3B8))),
          ),
          FilledButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Logged out')));
              Navigator.pop(context);
              Navigator.pop(context);
            },
            style: FilledButton.styleFrom(backgroundColor: Colors.red.shade700),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }
}

class _EditableField extends StatefulWidget {
  final String label, initialValue;
  final IconData icon;
  final Function(String) onSave;
  const _EditableField({required this.label, required this.initialValue, required this.icon, required this.onSave});

  @override
  State<_EditableField> createState() => _EditableFieldState();
}

class _EditableFieldState extends State<_EditableField> {
  late TextEditingController ctrl;
  bool isEditing = false;

  @override
  void initState() {
    super.initState();
    ctrl = TextEditingController(text: widget.initialValue);
  }

  @override
  void dispose() {
    ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF334155)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(widget.icon, size: 18, color: const Color(0xFFFF5C73)),
                  const SizedBox(width: 12),
                  Text(widget.label, style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 12, fontWeight: FontWeight.w500)),
                ],
              ),
              if (!isEditing)
                IconButton(
                  onPressed: () => setState(() => isEditing = true),
                  icon: const Icon(Icons.edit, size: 16, color: Color(0xFFFF5C73)),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                )
              else
                Row(
                  children: [
                    GestureDetector(
                      onTap: () => setState(() => isEditing = false),
                      child: const Icon(Icons.close, size: 16, color: Color(0xFF64748B)),
                    ),
                    const SizedBox(width: 12),
                    GestureDetector(
                      onTap: () {
                        widget.onSave(ctrl.text);
                        setState(() => isEditing = false);
                      },
                      child: const Icon(Icons.check, size: 16, color: Color(0xFF10B981)),
                    ),
                  ],
                ),
            ],
          ),
          const SizedBox(height: 8),
          if (isEditing)
            TextFormField(
              controller: ctrl,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 8),
                enabledBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFF334155))),
                focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFFFF5C73))),
              ),
            )
          else
            Text(ctrl.text, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class _ToggleTile extends StatefulWidget {
  final String label;
  final bool initialValue;
  final Function(bool) onChanged;
  const _ToggleTile(this.label, this.initialValue, this.onChanged);

  @override
  State<_ToggleTile> createState() => _ToggleTileState();
}

class _ToggleTileState extends State<_ToggleTile> {
  late bool value;

  @override
  void initState() {
    super.initState();
    value = widget.initialValue;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFF334155)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(widget.label, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
          Transform.scale(
            scale: 0.8,
            child: Switch(
              value: value,
              onChanged: (newValue) {
                setState(() => value = newValue);
                widget.onChanged(newValue);
              },
              activeThumbColor: const Color(0xFFFF5C73),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final String label, value;
  const _InfoTile(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 14)),
          Text(value, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
