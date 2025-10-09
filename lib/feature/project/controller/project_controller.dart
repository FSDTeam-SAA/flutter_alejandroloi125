// import 'package:get/get.dart';
// import '../model/project_model.dart';
// import '../repo/project_repo.dart';
//
//
//
// class ProjectController extends GetxController {
//   final ProjectRepository repository;
//   ProjectController(this.repository);
//
//   var projects = <Project>[].obs;
//   var loading = false.obs;
//   var error = ''.obs;
//
//   Future<void> loadProjects() async {
//     try {
//       loading.value = true;
//       final data = await repository.fetchProjects();
//       projects.assignAll(data);
//       error.value = '';
//     } catch (e) {
//       error.value = e.toString();
//     } finally {
//       loading.value = false;
//     }
//   }
// }
