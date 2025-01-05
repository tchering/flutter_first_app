class User {
  final int id;
  final String firstName;
  final String lastName;
  final String email;
  final String? companyName;
  final String? position;
  final String? logo;
  final String? street;
  final String? areaCode;
  final String? city;
  final DateTime createdAt;

  User({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.createdAt,
    this.companyName,
    this.position,
    this.logo,
    this.street,
    this.areaCode,
    this.city,
  });

  // Provide safe getters with default values
  String get displayCompanyName => companyName ?? 'Company Name';
  String get displayPosition => position ?? 'Contractor';
  
  // Enhanced logo handling
  String get displayLogo {
    // Check if logo is a valid URL or file path
    if (logo != null && (logo!.startsWith('http') || logo!.startsWith('/'))) {
      return logo!;
    }
    // Fallback to default logo
    return 'assets/images/default_logo.png';
  }

  String get displayStreet => street ?? '';
  String get displayAreaCode => areaCode ?? '';
  String get displayCity => city ?? '';

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? 0,
      firstName: json['first_name'] ?? '',
      lastName: json['last_name'] ?? '',
      email: json['email'] ?? '',
      companyName: json['company_name'],
      position: json['position'],
      logo: json['logo'],  // Keep original logo value
      street: json['street'],
      areaCode: json['area_code'],
      city: json['city'],
      createdAt: json['created_at'] != null 
        ? DateTime.parse(json['created_at']) 
        : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'first_name': firstName,
      'last_name': lastName,
      'email': email,
      'company_name': companyName,
      'position': position,
      'logo': logo,
      'street': street,
      'area_code': areaCode,
      'city': city,
      'created_at': createdAt.toIso8601String(),
    };
  }
} 