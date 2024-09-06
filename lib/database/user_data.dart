// lib/database/user_data.dart
class UserData {
  final int id;
  final String firstName;
  final String lastName;
  final String email;
  final String contactNumber;
  final String dateOfBirth;
  final String gender;
  final String country;
  final bool termsAccepted;

  UserData({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.contactNumber,
    required this.dateOfBirth,
    required this.gender,
    required this.country,
    required this.termsAccepted,
  });

  // Factory method to create a UserData instance from a map
  factory UserData.fromMap(Map<String, dynamic> map) {
    return UserData(
      id: map['id'],
      firstName: map['firstName'],
      lastName: map['lastName'],
      email: map['email'],
      contactNumber: map['contactNumber'],
      dateOfBirth: map['dateOfBirth'],
      gender: map['gender'],
      country: map['country'],
      termsAccepted: map['termsAccepted'] == 1, // Assuming termsAccepted is stored as INTEGER
    );
  }

  // Method to convert UserData to a map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'contactNumber': contactNumber,
      'dateOfBirth': dateOfBirth,
      'gender': gender,
      'country': country,
      'termsAccepted': termsAccepted ? 1 : 0,
    };
  }
}
