// lib/feature/project/model/project_page.dart
import '../../models/project.dart';

class ProjectPage {
  final int total;
  final int page;
  final int limit;
  final int pages;
  final List<Project> items;

  const ProjectPage({
    required this.total,
    required this.page,
    required this.limit,
    required this.pages,
    required this.items,
  });
}
