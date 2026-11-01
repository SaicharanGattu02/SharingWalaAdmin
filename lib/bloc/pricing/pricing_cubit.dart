import 'package:flutter_bloc/flutter_bloc.dart';
import 'pricing_repo.dart';
import 'pricing_state.dart';

class PricingCubit extends Cubit<PricingState> {
  final PricingRepo repo;

  PricingCubit({required this.repo}) : super(PricingInitial());

  Future<void> fetchPricingRules() async {
    emit(PricingLoading());
    try {
      final list = await repo.getPricingRules();
      emit(PricingLoaded(rules: list));
    } catch (e) {
      emit(PricingError(e.toString()));
    }
  }

  Future<bool> updatePricingRule(String id, Map<String, dynamic> data) async {
    try {
      final ok = await repo.updatePricingRule(id, data);
      if (ok) {
        await fetchPricingRules();
      }
      return ok;
    } catch (_) {
      return false;
    }
  }
}

