class User {
  final String id;
  final String email;
  final String name;
  final bool isAdmin;
  final String? profileImageUrl;
  final String? bio;
  final String? location;
  final String? defaultCity;
  final String? defaultState;
  final String? defaultCountry;
  final String? defaultCountryCode;

  User({
    required this.id,
    required this.email,
    required this.name,
    this.isAdmin = false,
    this.profileImageUrl,
    this.bio,
    this.location,
    this.defaultCity,
    this.defaultState,
    this.defaultCountry,
    this.defaultCountryCode,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'isAdmin': isAdmin,
      'profileImageUrl': profileImageUrl,
      'bio': bio,
      'location': location,
      'defaultCity': defaultCity,
      'defaultState': defaultState,
      'defaultCountry': defaultCountry,
      'defaultCountryCode': defaultCountryCode,
    };
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      email: json['email'] as String,
      name: json['name'] as String,
      isAdmin: (json['isAdmin'] as bool?) ?? false,
      profileImageUrl: json['profileImageUrl'] as String?,
      bio: json['bio'] as String?,
      location: json['location'] as String?,
      defaultCity: json['defaultCity'] as String?,
      defaultState: json['defaultState'] as String?,
      defaultCountry: json['defaultCountry'] as String?,
      defaultCountryCode: json['defaultCountryCode'] as String?,
    );
  }

  User copyWith({
    String? id,
    String? email,
    String? name,
    bool? isAdmin,
    String? profileImageUrl,
    String? bio,
    String? location,
    String? defaultCity,
    String? defaultState,
    String? defaultCountry,
    String? defaultCountryCode,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      isAdmin: isAdmin ?? this.isAdmin,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      bio: bio ?? this.bio,
      location: location ?? this.location,
      defaultCity: defaultCity ?? this.defaultCity,
      defaultState: defaultState ?? this.defaultState,
      defaultCountry: defaultCountry ?? this.defaultCountry,
      defaultCountryCode: defaultCountryCode ?? this.defaultCountryCode,
    );
  }
}
