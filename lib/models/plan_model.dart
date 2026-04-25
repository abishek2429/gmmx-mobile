import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';

/// The subscription plan tiers available in GMMX
enum GymPlan { free, starter, growth, pro }

extension GymPlanExtension on GymPlan {
  String get displayName {
    switch (this) {
      case GymPlan.free:    return 'FREE';
      case GymPlan.starter: return 'STARTER';
      case GymPlan.growth:  return 'GROWTH';
      case GymPlan.pro:     return 'PRO';
    }
  }

  String get tagline {
    switch (this) {
      case GymPlan.free:    return 'Get started, no cost';
      case GymPlan.starter: return 'Grow your gym';
      case GymPlan.growth:  return 'The full system';
      case GymPlan.pro:     return 'Serious gyms only';
    }
  }

  String get price {
    switch (this) {
      case GymPlan.free:    return '₹0';
      case GymPlan.starter: return '₹499';
      case GymPlan.growth:  return '₹999';
      case GymPlan.pro:     return '₹1999';
    }
  }

  String get priceLabel {
    switch (this) {
      case GymPlan.free:    return 'Free forever';
      case GymPlan.starter: return '/month';
      case GymPlan.growth:  return '/month';
      case GymPlan.pro:     return '/month';
    }
  }

  int get memberLimit {
    switch (this) {
      case GymPlan.free:    return 30;
      case GymPlan.starter: return 100;
      case GymPlan.growth:  return 300;
      case GymPlan.pro:     return 9999; // unlimited
    }
  }

  String get memberLimitLabel {
    if (this == GymPlan.pro) return 'Unlimited members';
    return 'Up to ${memberLimit} members';
  }

  Color get color {
    switch (this) {
      case GymPlan.free:    return AppColors.planFree;
      case GymPlan.starter: return AppColors.planStarter;
      case GymPlan.growth:  return AppColors.planGrowth;
      case GymPlan.pro:     return AppColors.planPro;
    }
  }

  Color get lightColor {
    switch (this) {
      case GymPlan.free:    return AppColors.planFreeLight;
      case GymPlan.starter: return AppColors.planStarterLight;
      case GymPlan.growth:  return AppColors.planGrowthLight;
      case GymPlan.pro:     return AppColors.planProLight;
    }
  }

  List<Color> get gradient {
    switch (this) {
      case GymPlan.free:    return AppColors.planFreeGradient;
      case GymPlan.starter: return AppColors.planStarterGradient;
      case GymPlan.growth:  return AppColors.planGrowthGradient;
      case GymPlan.pro:     return AppColors.planProGradient;
    }
  }

  bool isAtLeast(GymPlan required) {
    return index >= required.index;
  }

  List<PlanFeature> get features {
    switch (this) {
      case GymPlan.free:
        return [
          PlanFeature('Up to 30 members', true),
          PlanFeature('Add & edit members', true),
          PlanFeature('Manual attendance', true),
          PlanFeature('Basic dashboard', true),
          PlanFeature('Add trainers', false),
          PlanFeature('QR attendance', false),
          PlanFeature('Payment tracking', false),
          PlanFeature('WhatsApp reminders', false),
          PlanFeature('Reports', false),
          PlanFeature('Microsite', false),
        ];
      case GymPlan.starter:
        return [
          PlanFeature('Up to 100 members', true),
          PlanFeature('Add & manage trainers', true),
          PlanFeature('QR attendance (basic)', true),
          PlanFeature('Payment tracking', true),
          PlanFeature('WhatsApp reminders (manual)', true),
          PlanFeature('Monthly reports', true),
          PlanFeature('Auto WhatsApp reminders', false),
          PlanFeature('Progress tracking', false),
          PlanFeature('Microsite', false),
          PlanFeature('Export reports', false),
        ];
      case GymPlan.growth:
        return [
          PlanFeature('Up to 300 members', true),
          PlanFeature('Full QR attendance', true),
          PlanFeature('Auto WhatsApp reminders', true),
          PlanFeature('Trainer performance tracking', true),
          PlanFeature('Member progress tracking', true),
          PlanFeature('Payment insights', true),
          PlanFeature('Export reports (Excel/PDF)', true),
          PlanFeature('Basic microsite', true),
          PlanFeature('Multi-staff logins', true),
          PlanFeature('Online payments', false),
        ];
      case GymPlan.pro:
        return [
          PlanFeature('Unlimited members', true),
          PlanFeature('Full automation suite', true),
          PlanFeature('Advanced analytics', true),
          PlanFeature('Custom subdomain microsite', true),
          PlanFeature('Online payments (Razorpay)', true),
          PlanFeature('Multi-branch support', true),
          PlanFeature('Priority support', true),
          PlanFeature('White-label (optional)', true),
        ];
    }
  }
}

class PlanFeature {
  final String label;
  final bool included;
  PlanFeature(this.label, this.included);
}

/// Enum for gated features — used by UpgradeGate
enum GatedFeature {
  addTrainers,
  qrAttendance,
  paymentTracking,
  whatsappReminders,
  autoReminders,
  reports,
  exportReports,
  progressTracking,
  microsite,
  multiStaff,
}

extension GatedFeatureExtension on GatedFeature {
  GymPlan get requiredPlan {
    switch (this) {
      case GatedFeature.addTrainers:       return GymPlan.starter;
      case GatedFeature.qrAttendance:      return GymPlan.starter;
      case GatedFeature.paymentTracking:   return GymPlan.starter;
      case GatedFeature.whatsappReminders: return GymPlan.starter;
      case GatedFeature.reports:           return GymPlan.starter;
      case GatedFeature.autoReminders:     return GymPlan.growth;
      case GatedFeature.exportReports:     return GymPlan.growth;
      case GatedFeature.progressTracking:  return GymPlan.growth;
      case GatedFeature.microsite:         return GymPlan.growth;
      case GatedFeature.multiStaff:        return GymPlan.growth;
    }
  }

  String get displayName {
    switch (this) {
      case GatedFeature.addTrainers:       return 'Trainer Management';
      case GatedFeature.qrAttendance:      return 'QR Attendance';
      case GatedFeature.paymentTracking:   return 'Payment Tracking';
      case GatedFeature.whatsappReminders: return 'WhatsApp Reminders';
      case GatedFeature.autoReminders:     return 'Auto Reminders';
      case GatedFeature.reports:           return 'Reports';
      case GatedFeature.exportReports:     return 'Export Reports';
      case GatedFeature.progressTracking:  return 'Progress Tracking';
      case GatedFeature.microsite:         return 'Microsite';
      case GatedFeature.multiStaff:        return 'Multi-Staff Access';
    }
  }
}
