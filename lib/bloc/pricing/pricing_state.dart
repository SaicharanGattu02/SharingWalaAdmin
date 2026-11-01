import 'package:equatable/equatable.dart';
import '../../models/admin_models.dart';

abstract class PricingState extends Equatable {
  const PricingState();

  @override
  List<Object?> get props => [];
}

class PricingInitial extends PricingState {}

class PricingLoading extends PricingState {}

class PricingLoaded extends PricingState {
  final List<AdminPricingRuleItem> rules;
  const PricingLoaded({required this.rules});

  @override
  List<Object?> get props => [rules];
}

class PricingError extends PricingState {
  final String message;
  const PricingError(this.message);

  @override
  List<Object?> get props => [message];
}

