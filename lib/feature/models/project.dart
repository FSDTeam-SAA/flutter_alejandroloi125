// lib/feature/project/model/project.dart

// ---------- Common helpers ----------
int _asInt(dynamic v) {
  if (v is num) return v.toInt();
  if (v is String) {
    final m = RegExp(r'-?\d+').firstMatch(v.trim());
    if (m != null) return int.tryParse(m.group(0)!) ?? 0;
  }
  return 0;
}

// ---------- Owner (createdBy) models ----------
class Avatar {
  final String? url;
  final String? publicId;
  const Avatar({this.url, this.publicId});

  factory Avatar.fromDynamic(dynamic v) {
    if (v is Map) {
      final m = Map<String, dynamic>.from(v as Map);
      return Avatar(
        url: (m['url'] ?? m['imageUrl'] ?? m['link'])?.toString(),
        publicId: (m['public_id'] ?? m['publicId'])?.toString(),
      );
    }
    if (v is String && v.isNotEmpty) {
      return Avatar(url: v);
    }
    return const Avatar();
  }
}

class CreatedBy {
  final String? id;
  final String? name;
  final String? username;
  final Avatar avatar;

  const CreatedBy({this.id, this.name, this.username, required this.avatar});

  String? get avatarUrl => avatar.url;

  factory CreatedBy.fromDynamic(dynamic v) {
    final m = (v is Map) ? Map<String, dynamic>.from(v as Map) : const <String, dynamic>{};
    return CreatedBy(
      id: (m['_id'] ?? m['id'])?.toString(),
      name: (m['name'] ?? '').toString(),
      username: (m['username'] ?? '').toString(),
      avatar: Avatar.fromDynamic(m['avatar']),
    );
  }
}

// ---------- Proposal models ----------
class AvatarRef {
  final String? url;
  final String? publicId;
  const AvatarRef({this.url, this.publicId});

  factory AvatarRef.fromDynamic(dynamic v) {
    if (v is Map) {
      final m = Map<String, dynamic>.from(v as Map);
      return AvatarRef(
        url: (m['url'] ?? m['imageUrl'] ?? m['link'])?.toString(),
        publicId: (m['public_id'] ?? m['publicId'])?.toString(),
      );
    }
    if (v is String && v.isNotEmpty) {
      return AvatarRef(url: v);
    }
    return const AvatarRef();
  }
}

class UserMini {
  final String? id;
  final String? name;
  final String? username;
  final AvatarRef avatar;
  const UserMini({this.id, this.name, this.username, required this.avatar});

  String? get avatarUrl => avatar.url;

  factory UserMini.fromDynamic(dynamic v) {
    final m = (v is Map) ? Map<String, dynamic>.from(v as Map) : const <String, dynamic>{};
    return UserMini(
      id: (m['_id'] ?? m['id'] ?? '').toString(),
      name: (m['name'] ?? '').toString(),
      username: (m['username'] ?? '').toString(),
      avatar: AvatarRef.fromDynamic(m['avatar']),
    );
  }
}

class ProjectProposal {
  final UserMini user;
  final String coverLetter;
  final int budget;
  final int deliveryDays;
  final String status;

  const ProjectProposal({
    required this.user,
    required this.coverLetter,
    required this.budget,
    required this.deliveryDays,
    required this.status,
  });

  factory ProjectProposal.fromJson(Map<String, dynamic> j) => ProjectProposal(
    user: UserMini.fromDynamic(j['userId']),
    coverLetter: (j['cover_letter'] ?? '').toString(),
    budget: _asInt(j['budget']),
    deliveryDays: _asInt(j['delivery_timer']),
    status: (j['status'] ?? '').toString(),
  );
}

// ---------- Project ----------
class Project {
  final String id;
  final String title;
  final String description;
  final String category;
  final int minBudget;
  final int maxBudget;
  final int deadlineDays; // numeric days
  final String location;
  final List<String> skills;
  final String? status;

  final CreatedBy? createdBy;
  final List<ProjectProposal> proposals;

  String? get ownerAvatarUrl => createdBy?.avatarUrl;

  Project({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.minBudget,
    required this.maxBudget,
    required this.deadlineDays,
    required this.location,
    required this.skills,
    this.status,
    this.createdBy,
    this.proposals = const [],
  });

  factory Project.fromJson(Map<String, dynamic> j) {
    // category can be a string or a list of strings
    String category;
    final c = j['category'];
    if (c is List) {
      category = c.map((e) => e.toString()).join(', ');
    } else {
      category = (c ?? '').toString();
    }

    // skills can be list or comma-separated string
    List<String> skills = [];
    final sk = j['skills'];
    if (sk is List) {
      skills = sk.map((e) => e.toString()).toList();
    } else if (sk is String) {
      skills = sk.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
    }

    // proposals array
    List<ProjectProposal> proposals = [];
    final pp = j['project_proposal'];
    if (pp is List) {
      proposals = pp
          .where((e) => e is Map)
          .map<ProjectProposal>((e) => ProjectProposal.fromJson(
        Map<String, dynamic>.from(e as Map),
      ))
          .toList();
    }

    return Project(
      id: (j['_id'] ?? j['id'] ?? '').toString(),
      title: (j['title'] ?? j['name'] ?? '').toString(),
      description: (j['description'] ?? '').toString(),
      category: category,
      minBudget: _asInt(j['min_budget'] ?? j['budget_min']),
      maxBudget: _asInt(j['max_budget'] ?? j['budget_max']),
      deadlineDays: _asInt(j['duration'] ?? j['deadline'] ?? j['deadlineDays']),
      location: (j['location'] ?? '').toString(),
      skills: skills,
      status: j['status']?.toString(),
      createdBy: CreatedBy.fromDynamic(j['createdBy']),
      proposals: proposals,
    );
  }
}
