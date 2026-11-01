import 'package:flutter_bloc/flutter_bloc.dart';
import 'users_repo.dart';
import 'users_state.dart';

class UsersCubit extends Cubit<UsersState> {
  final UsersRepo repo;

  UsersCubit({required this.repo}) : super(UsersInitial());

  Future<void> fetchUsers({String? search, String? status, String? role}) async {
    emit(UsersLoading());
    try {
      final users = await repo.getUsers(search: search, status: status, role: role);
      emit(UsersLoaded(users: users));
    } catch (e) {
      emit(UsersError(e.toString()));
    }
  }

  Future<bool> updateUserStatus(String userId, String status, {String? reason}) async {
    try {
      final ok = await repo.updateUserStatus(userId, status, reason: reason);
      if (ok) {
        await fetchUsers();
      }
      return ok;
    } catch (_) {
      return false;
    }
  }
}

