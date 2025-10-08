import 'package:alejandroloi/core/network/api_service/api_client.dart';

class ProjectService {
  final ApiClient apiClient;

  ProjectService(this.apiClient);

  Future<List<Map<String, dynamic>>> fetchProjects() async {
    final res = await apiClient.dio.get('/project/all-project');

    if (res.statusCode == 200) {
      final data = res.data['data'];
      final projects = data['projects'] as List<dynamic>;
      return List<Map<String, dynamic>>.from(projects);
    } else {
      throw Exception('Failed to load projects');
    }
  }
}
