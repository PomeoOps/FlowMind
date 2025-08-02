import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../data/models/project.dart';
import '../services/github_api_service.dart';

// Events
abstract class ProjectEvent extends Equatable {
  const ProjectEvent();

  @override
  List<Object?> get props => [];
}

class LoadProjects extends ProjectEvent {
  final String? searchQuery;
  final String? language;
  final String? sortBy;

  const LoadProjects({
    this.searchQuery,
    this.language,
    this.sortBy,
  });

  @override
  List<Object?> get props => [searchQuery, language, sortBy];
}

class RefreshProjects extends ProjectEvent {
  const RefreshProjects();
}

// States
abstract class ProjectState extends Equatable {
  const ProjectState();

  @override
  List<Object?> get props => [];
}

class ProjectInitial extends ProjectState {}

class ProjectLoading extends ProjectState {}

class ProjectLoaded extends ProjectState {
  final List<Project> projects;
  final String? searchQuery;
  final String? language;
  final String? sortBy;

  const ProjectLoaded({
    required this.projects,
    this.searchQuery,
    this.language,
    this.sortBy,
  });

  @override
  List<Object?> get props => [projects, searchQuery, language, sortBy];
}

class ProjectError extends ProjectState {
  final String message;

  const ProjectError(this.message);

  @override
  List<Object?> get props => [message];
}

// Bloc
class ProjectBloc extends Bloc<ProjectEvent, ProjectState> {
  final GitHubService _githubService;

  ProjectBloc(this._githubService) : super(ProjectInitial()) {
    on<LoadProjects>(_onLoadProjects);
    on<RefreshProjects>(_onRefreshProjects);
  }

  Future<void> _onLoadProjects(
    LoadProjects event,
    Emitter<ProjectState> emit,
  ) async {
    emit(ProjectLoading());

    try {
      final repositories = await _githubService.getUserRepositories(
        sort: event.sortBy == '最近更新' ? 'updated' : 'name',
        perPage: 100,
      );

      // 转换为Project模型
      final projects = repositories.map((repo) {
        return Project(
          githubId: repo['id']?.toString(),
          name: repo['name'],
          fullName: repo['full_name'],
          description: repo['description'],
          language: repo['language'],
          stars: repo['stargazers_count'],
          forks: repo['forks_count'],
          openIssues: repo['open_issues_count'],
          isPrivate: repo['private'],
          isFork: repo['fork'],
          createdAt: repo['created_at'] != null
              ? DateTime.parse(repo['created_at'])
              : null,
          updatedAt: repo['updated_at'] != null
              ? DateTime.parse(repo['updated_at'])
              : null,
          pushedAt: repo['pushed_at'] != null
              ? DateTime.parse(repo['pushed_at'])
              : null,
          defaultBranch: repo['default_branch'],
          homepage: repo['homepage'],
          topics: (repo['topics'] as List<dynamic>?)?.join(','),
          license: repo['license']?['name'],
          owner: repo['owner']?['login'],
          avatarUrl: repo['owner']?['avatar_url'],
          htmlUrl: repo['html_url'],
          cloneUrl: repo['clone_url'],
          lastSyncAt: DateTime.now(),
          status: 'active',
        );
      }).toList();

      // 应用过滤
      var filteredProjects = projects;

      if (event.searchQuery?.isNotEmpty == true) {
        filteredProjects = filteredProjects.where((project) {
          return (project.name?.toLowerCase().contains(
                    event.searchQuery!.toLowerCase(),
                  ) ??
                  false) ||
                  (project.description?.toLowerCase().contains(
                        event.searchQuery!.toLowerCase(),
                      ) ??
                      false);
        }).toList();
      }

      if (event.language?.isNotEmpty == true && event.language != '全部') {
        filteredProjects = filteredProjects.where((project) {
          return project.language == event.language;
        }).toList();
      }

      emit(ProjectLoaded(
        projects: filteredProjects,
        searchQuery: event.searchQuery,
        language: event.language,
        sortBy: event.sortBy,
      ));
    } catch (e) {
      emit(ProjectError(e.toString()));
    }
  }

  Future<void> _onRefreshProjects(
    RefreshProjects event,
    Emitter<ProjectState> emit,
  ) async {
    add(const LoadProjects());
  }
} 