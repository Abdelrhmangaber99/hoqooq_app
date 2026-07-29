import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import '../../domain/entities/legal_case.dart';
import '../../domain/usecases/get_cases_use_case.dart';

part 'cases_event.dart';
part 'cases_state.dart';

@injectable
class CasesBloc extends Bloc<CasesEvent, CasesState> {
  final GetCasesUseCase _getCasesUseCase;

  CasesBloc(this._getCasesUseCase) : super(CasesInitial()) {
    on<FetchCasesRequested>((event, emit) async {
      emit(CasesLoading());
      final result = await _getCasesUseCase.execute(filter: event.filter);
      
      result.fold(
        (failure) => emit(CasesError(failure.message)),
        (cases) => emit(CasesLoaded(cases)),
      );
    });
  }
}
