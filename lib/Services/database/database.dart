import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseService {
  final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;

  Future<void> postDetailsToFirestore(String uid, String email, String role, Map<String, dynamic> additionalData) async {
    Map<String, dynamic> userData = {
      'email': email,
      'role': role,
    };

    if (role == 'User') {
      userData['FirstName'] = additionalData['FirstName'];
      userData['LastName'] = additionalData['LastName'];
      userData['Contact'] = additionalData['Contact'];
      userData['gender'] = additionalData['gender'];
    } else if (role == 'Organization') {
      userData['Name'] = additionalData['Name'];
      userData['OrgRepName'] = additionalData['OrgRepName'];
      userData['OrgRepPosition'] = additionalData['OrgRepPosition'];
      userData['Designation'] = additionalData['Designation'];
      userData['Location'] = additionalData['Location'];
      userData['Type'] = additionalData['Type'];
      userData['Contact'] = additionalData['Contact'];
    }
    
    String collection = role == 'Organization' ? 'Organizations' : 'Users';
    await _firebaseFirestore.collection(collection).doc(uid).set(userData);
  }
}

