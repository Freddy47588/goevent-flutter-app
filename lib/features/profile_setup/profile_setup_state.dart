class ProfileSetupState {
  final String username;
  final String? photoUrl;
  final List<String> favourites;

  const ProfileSetupState({
    this.username = '',
    this.photoUrl,
    this.favourites = const [],
  });

  ProfileSetupState copyWith({
    String? username,
    String? photoUrl,
    List<String>? favourites,
  }) {
    return ProfileSetupState(
      username: username ?? this.username,
      photoUrl: photoUrl ?? this.photoUrl,
      favourites: favourites ?? this.favourites,
    );
  }
}
