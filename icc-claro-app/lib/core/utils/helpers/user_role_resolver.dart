import 'package:icc_claro_app/features/routesicc/models/route_model.dart';

class UserRoleResolver {
  static bool isAssistant(RouteModel route, String currentUsername) {
    final assignedUser =
        route.currentlyAssignedToName.split(' ').first.toLowerCase().trim();
    final assistantUser =
        route.routeAssistantName.split(' ').first.toLowerCase().trim();
    final username = currentUsername.toLowerCase().trim();

    return assignedUser == username && assistantUser == username;
  }

  static bool isManager(RouteModel route, String currentUsername) {
    final assignedUser =
        route.currentlyAssignedToName.split(' ').first.toLowerCase().trim();
    final managerUser =
        route.routeManagerName.split(' ').first.toLowerCase().trim();
    final username = currentUsername.toLowerCase().trim();

    return assignedUser == username && managerUser == username;
  }
}
