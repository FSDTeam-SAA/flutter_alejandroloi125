
import '../model/project_model.dart';
import '../services/project_services.dart';
import '../view/project.dart';

class ProjectRepository {
  final ProjectService service;
  ProjectRepository(this.service);

  Future<List<Project>> fetchProjects() async {
    final list = await service.fetchProjects();
    return list.map((json) => Project.fromJson(json)).toList();
  }
}
