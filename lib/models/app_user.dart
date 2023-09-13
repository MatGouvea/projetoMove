class AppUser {
  final String id;
  final String name;
  final String email;
  final String? imageUrl;

  const AppUser({
    required this.id,
    required this.name,
    required this.email,
    this.imageUrl
  });

}