import 'package:equatable/equatable.dart';
import '../../models/admin_models.dart';

abstract class CommunitiesState extends Equatable {
  const CommunitiesState();

  @override
  List<Object?> get props => [];
}

class CommunitiesInitial extends CommunitiesState {}

class CommunitiesLoading extends CommunitiesState {}

class CommunitiesLoaded extends CommunitiesState {
  final List<AdminCommunityItem> communities;
  const CommunitiesLoaded({required this.communities});

  @override
  List<Object?> get props => [communities];
}

class CommunitiesError extends CommunitiesState {
  final String message;
  const CommunitiesError(this.message);

  @override
  List<Object?> get props => [message];
}

