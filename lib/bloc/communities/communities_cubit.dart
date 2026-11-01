import 'package:flutter_bloc/flutter_bloc.dart';
import 'communities_repo.dart';
import 'communities_state.dart';

class CommunitiesCubit extends Cubit<CommunitiesState> {
  final CommunitiesRepo repo;

  CommunitiesCubit({required this.repo}) : super(CommunitiesInitial());

  Future<void> fetchCommunities() async {
    emit(CommunitiesLoading());
    try {
      final list = await repo.getCommunities();
      emit(CommunitiesLoaded(communities: list));
    } catch (e) {
      emit(CommunitiesError(e.toString()));
    }
  }

  Future<bool> createCommunity(Map<String, dynamic> data) async {
    try {
      final ok = await repo.createCommunity(data);
      if (ok) {
        await fetchCommunities();
      }
      return ok;
    } catch (_) {
      return false;
    }
  }
}

