enum UserRole {
  admin('admin'),
  member('member');

  final String value;
  const UserRole(this.value);

  static UserRole fromString(String? role) {
    if (role?.toLowerCase() == 'admin') return UserRole.admin;
    return UserRole.member;
  }

  bool get isAdmin => this == UserRole.admin;
}
