import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../data/models/paper.dart';
import '../services/zotero_service.dart';

// Events
abstract class PaperEvent extends Equatable {
  const PaperEvent();

  @override
  List<Object?> get props => [];
}

class LoadPapers extends PaperEvent {
  final String? searchQuery;
  final String? itemType;
  final String? collection;

  const LoadPapers({
    this.searchQuery,
    this.itemType,
    this.collection,
  });

  @override
  List<Object?> get props => [searchQuery, itemType, collection];
}

class RefreshPapers extends PaperEvent {
  const RefreshPapers();
}

// States
abstract class PaperState extends Equatable {
  const PaperState();

  @override
  List<Object?> get props => [];
}

class PaperInitial extends PaperState {}

class PaperLoading extends PaperState {}

class PaperLoaded extends PaperState {
  final List<Paper> papers;
  final String? searchQuery;
  final String? itemType;
  final String? collection;

  const PaperLoaded({
    required this.papers,
    this.searchQuery,
    this.itemType,
    this.collection,
  });

  @override
  List<Object?> get props => [papers, searchQuery, itemType, collection];
}

class PaperError extends PaperState {
  final String message;

  const PaperError(this.message);

  @override
  List<Object?> get props => [message];
}

// Bloc
class PaperBloc extends Bloc<PaperEvent, PaperState> {
  final ZoteroService _zoteroService;

  PaperBloc(this._zoteroService) : super(PaperInitial()) {
    on<LoadPapers>(_onLoadPapers);
    on<RefreshPapers>(_onRefreshPapers);
  }

  Future<void> _onLoadPapers(
    LoadPapers event,
    Emitter<PaperState> emit,
  ) async {
    emit(PaperLoading());

    try {
      final papers = await _zoteroService.searchPapers(
        query: event.searchQuery ?? '',
        itemType: event.itemType,
        collection: event.collection,
      );

      emit(PaperLoaded(
        papers: papers,
        searchQuery: event.searchQuery,
        itemType: event.itemType,
        collection: event.collection,
      ));
    } catch (e) {
      emit(PaperError(e.toString()));
    }
  }

  Future<void> _onRefreshPapers(
    RefreshPapers event,
    Emitter<PaperState> emit,
  ) async {
    add(const LoadPapers());
  }
} 