class ElfUser {
  final String userID;
  final String email;
  final String displayName;
  final String photoURL;

  ElfUser({
    this.userID,
    this.email,
    this.displayName,
    this.photoURL,
  });

  factory ElfUser.fromJson(Map<String, dynamic> json) {
    return ElfUser(
      userID: json['userID'],
      email: json['email'],
      displayName: json['displayName'],
      photoURL: json['photoURL'],
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'userID': userID,
      'email': email,
      'displayName': displayName,
      'photoURL': photoURL,
    };
  }
}
