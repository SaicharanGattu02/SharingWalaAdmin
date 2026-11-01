import 'package:flutter_bloc/flutter_bloc.dart';
import 'staff_repo.dart';
import 'staff_state.dart';

class StaffCubit extends Cubit<StaffState> {
  final StaffRepo repo;

  StaffCubit({required this.repo}) : super(StaffInitial());

  Future<void> fetchStaffAndLogs() async {
    emit(StaffLoading());
    try {
      final staffList = await repo.getStaff();
      final logs = await repo.getAuditLogs();
      emit(StaffLoaded(staff: staffList, auditLogs: logs));
    } catch (e) {
      emit(StaffError(e.toString()));
    }
  }
}

