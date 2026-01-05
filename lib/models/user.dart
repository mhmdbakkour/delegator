class AppUser {
  final int id;
  final String username;

  const AppUser({required this.id, required this.username});

  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(id: json['id'], username: json['username']);
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'username': username};
  }
}
