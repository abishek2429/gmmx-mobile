import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final planListProvider = StateProvider<List<Plan>>((ref) {
  return [
    Plan(id: '1', name: 'Basic', price: 2999, sessionsPerMonth: 12, description: '3 days/week'),
    Plan(id: '2', name: 'Premium', price: 4999, sessionsPerMonth: 20, description: '5 days/week'),
    Plan(id: '3', name: 'Elite', price: 6999, sessionsPerMonth: 30, description: 'Unlimited'),
  ];
});

class Plan {
  final String id, name, description;
  final int price, sessionsPerMonth;
  Plan({required this.id, required this.name, required this.price, required this.sessionsPerMonth, required this.description});
}

class PlanListPage extends ConsumerWidget {
  const PlanListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final plans = ref.watch(planListProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Membership Plans', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w700)),
                  FilledButton.icon(
                    onPressed: () => _showCreatePlanDialog(context),
                    icon: const Icon(Icons.add, size: 20),
                    label: const Text('New'),
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFFFF5C73),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: plans.length,
                itemBuilder: (context, index) => _PlanCard(plans[index]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showCreatePlanDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const _CreatePlanDialog(),
    );
  }
}

class _PlanCard extends StatelessWidget {
  final Plan plan;
  const _PlanCard(this.plan);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFF1E293B), Color(0xFF0F172A)]),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF334155)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(plan.name, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFFF5C73).withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text('₹${plan.price}', style: const TextStyle(color: Color(0xFFFF5C73), fontWeight: FontWeight.w600)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(plan.description, style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 13)),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.fitness_center, size: 16, color: Colors.white.withValues(alpha: 0.6)),
              const SizedBox(width: 8),
              Text('${plan.sessionsPerMonth} sessions/month', style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 13)),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${plan.name} selected'))),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFFFF5C73),
                side: const BorderSide(color: Color(0xFFFF5C73)),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text('Select Plan'),
            ),
          ),
        ],
      ),
    );
  }
}

class _CreatePlanDialog extends ConsumerStatefulWidget {
  const _CreatePlanDialog();

  @override
  ConsumerState<_CreatePlanDialog> createState() => _CreatePlanDialogState();
}

class _CreatePlanDialogState extends ConsumerState<_CreatePlanDialog> {
  late TextEditingController nameCtrl, priceCtrl, sessionsCtrl;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    nameCtrl = TextEditingController();
    priceCtrl = TextEditingController();
    sessionsCtrl = TextEditingController();
  }

  @override
  void dispose() {
    nameCtrl.dispose();
    priceCtrl.dispose();
    sessionsCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: const Color(0xFF1E293B),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Create Plan', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700)),
            const SizedBox(height: 20),
            _FormField('Plan Name', nameCtrl),
            const SizedBox(height: 16),
            _FormField('Price (₹)', priceCtrl, isNumber: true),
            const SizedBox(height: 16),
            _FormField('Sessions/Month', sessionsCtrl, isNumber: true),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(side: const BorderSide(color: Color(0xFF334155))),
                    child: const Text('Cancel', style: TextStyle(color: Color(0xFF94A3B8))),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    onPressed: isLoading ? null : _createPlan,
                    style: FilledButton.styleFrom(backgroundColor: const Color(0xFFFF5C73)),
                    child: isLoading
                        ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation(Colors.white)))
                        : const Text('Create'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _createPlan() async {
    final name = nameCtrl.text.trim();
    final price = int.tryParse(priceCtrl.text.trim());
    final sessions = int.tryParse(sessionsCtrl.text.trim());

    if (name.isEmpty || price == null || sessions == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter valid plan name, price, and sessions.')),
      );
      return;
    }

    setState(() => isLoading = true);
    await Future.delayed(const Duration(seconds: 1));
    final newPlan = Plan(
      id: DateTime.now().toString(),
      name: name,
      price: price,
      sessionsPerMonth: sessions,
      description: '$sessions sessions/month',
    );
    
    // Using the native 'ref' from ConsumerState
    ref.read(planListProvider.notifier).state = [...ref.read(planListProvider), newPlan];
    
    if (!mounted) return;
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Plan created')));
  }
}

class _FormField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final bool isNumber;
  const _FormField(this.label, this.controller, {this.isNumber = false});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.white.withValues(alpha: 0.6)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFF334155)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFFF5C73), width: 2),
        ),
      ),
    );
  }
}
