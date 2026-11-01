import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/pricing/pricing_cubit.dart';
import '../../bloc/pricing/pricing_state.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../models/admin_models.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/responsive_layout.dart';
import '../../widgets/status_badge.dart';

class PricingScreen extends StatefulWidget {
  const PricingScreen({super.key});

  @override
  State<PricingScreen> createState() => _PricingScreenState();
}

class _PricingScreenState extends State<PricingScreen> {
  @override
  void initState() {
    super.initState();
    context.read<PricingCubit>().fetchPricingRules();
  }

  void _editRule(AdminPricingRuleItem rule) {
    final rateCtrl = TextEditingController(text: rule.ratePerKm.toString());
    final maxCtrl = TextEditingController(text: rule.maxContributionPerKm.toString());

    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Container(
            padding: const EdgeInsets.all(24),
            constraints: const BoxConstraints(maxWidth: 420),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Edit ${rule.vehicleType} Cost Sharing Rule', style: AppTextStyles.h3),
                const SizedBox(height: 16),
                TextField(
                  controller: rateCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Standard Rate Per Km (₹)'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: maxCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Maximum Cap Per Km (₹)'),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: () async {
                        final rate = double.tryParse(rateCtrl.text.trim());
                        final max = double.tryParse(maxCtrl.text.trim());
                        if (rate == null || max == null) return;
                        Navigator.pop(context);
                        await context.read<PricingCubit>().updatePricingRule(rule.id, {
                          'ratePerKm': rate,
                          'maxContributionPerKm': max,
                        });
                      },
                      child: const Text('Save Changes'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveLayout.isMobile(context);

    return Scaffold(
      backgroundColor: AppColors.lightBg,
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Non-Commercial Fuel Sharing Rate Caps', style: AppTextStyles.h3),
            const SizedBox(height: 8),
            Text(
              'Enforce statutory compliance guardrails ensuring rides remain purely cost-sharing without commercial profit.',
              style: AppTextStyles.subtitle,
            ),
            const SizedBox(height: 20),
            Expanded(
              child: BlocBuilder<PricingCubit, PricingState>(
                builder: (context, state) {
                  if (state is PricingLoading) {
                    return const Center(child: CircularProgressIndicator(color: AppColors.primary));
                  }

                  if (state is PricingError) {
                    return EmptyState(
                      title: 'Error loading pricing rules',
                      message: state.message,
                      onRetry: () => context.read<PricingCubit>().fetchPricingRules(),
                    );
                  }

                  if (state is PricingLoaded) {
                    final rules = state.rules;

                    return GridView.builder(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: isMobile ? 1 : 2,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        childAspectRatio: isMobile ? 2.0 : 1.8,
                      ),
                      itemCount: rules.length,
                      itemBuilder: (context, i) {
                        final r = rules[i];
                        final isCar = r.vehicleType == 'CAR';

                        return Card(
                          child: Padding(
                            padding: const EdgeInsets.all(24),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        color: isCar ? Colors.blue.shade50 : Colors.purple.shade50,
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Icon(
                                        isCar ? Icons.directions_car : Icons.two_wheeler,
                                        color: isCar ? Colors.blue : Colors.purple,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text('${r.vehicleType} Cost Sharing', style: AppTextStyles.h3.copyWith(fontSize: 16)),
                                          Text('Distance: ${r.minimumDistanceKm.toInt()} km - ${r.maximumDistanceKm.toInt()} km', style: AppTextStyles.caption),
                                        ],
                                      ),
                                    ),
                                    StatusBadge(status: r.isActive ? 'ACTIVE' : 'INACTIVE'),
                                  ],
                                ),
                                const Spacer(),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Text('Base Rate', style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
                                        Text('₹${r.ratePerKm}/km', style: AppTextStyles.h2.copyWith(fontSize: 20)),
                                      ],
                                    ),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Text('Max Cost Cap', style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
                                        Text('₹${r.maxContributionPerKm}/km', style: AppTextStyles.h2.copyWith(fontSize: 20, color: AppColors.primaryDark)),
                                      ],
                                    ),
                                    ElevatedButton.icon(
                                      onPressed: () => _editRule(r),
                                      icon: const Icon(Icons.edit, size: 14),
                                      label: const Text('Edit Cap'),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  }

                  return const SizedBox.shrink();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

