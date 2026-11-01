import 'package:flutter_bloc/flutter_bloc.dart';
import 'banners_repo.dart';
import 'banners_state.dart';

class BannersCubit extends Cubit<BannersState> {
  final BannersRepo repo;

  BannersCubit({required this.repo}) : super(BannersInitial());

  Future<void> fetchBanners() async {
    emit(BannersLoading());
    try {
      final list = await repo.getBanners();
      emit(BannersLoaded(banners: list));
    } catch (e) {
      emit(BannersError(e.toString()));
    }
  }

  Future<bool> createBanner(Map<String, dynamic> data) async {
    try {
      final ok = await repo.createBanner(data);
      if (ok) await fetchBanners();
      return ok;
    } catch (_) {
      return false;
    }
  }

  Future<bool> updateBanner(String id, Map<String, dynamic> data) async {
    try {
      final ok = await repo.updateBanner(id, data);
      if (ok) await fetchBanners();
      return ok;
    } catch (_) {
      return false;
    }
  }

  Future<bool> deleteBanner(String id) async {
    try {
      final ok = await repo.deleteBanner(id);
      if (ok) await fetchBanners();
      return ok;
    } catch (_) {
      return false;
    }
  }
}

