import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tatoolxp/models/tatool_user.dart';

abstract class BaseAuth {
  Future<String> signIn(String email, String password);

  Future<String> signUp(String email, String password);

  Future<TatoolUser> getCurrentUser();

  Future<void> sendEmailVerification();

  Future<void> signOut();

  Future<bool> isEmailVerified();
}

class Auth implements BaseAuth {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  Future<String> signIn(String email, String password) async {
    FirebaseUser user = await _firebaseAuth.signInWithEmailAndPassword(
        email: email, password: password);
    return user.uid;
  }

  Future<String> signUp(String email, String password) async {
    FirebaseUser user = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email, password: password);
    String uid = await _createTatoolUser(user);
    return uid;
  }

  Future<TatoolUser> getCurrentUser() async {
    FirebaseUser fbUser = await _firebaseAuth.currentUser();
    if (fbUser == null) {
      return null;
    }
    TatoolUser user = await _getTatoolUser(fbUser);
    return user;
  }

  Future<void> signOut() async {
    return _firebaseAuth.signOut();
  }

  Future<void> sendEmailVerification() async {
    FirebaseUser user = await _firebaseAuth.currentUser();
    user.sendEmailVerification();
  }

  Future<bool> isEmailVerified() async {
    FirebaseUser user = await _firebaseAuth.currentUser();
    return user.isEmailVerified;
  }

  Future<String> _createTatoolUser(FirebaseUser fbUser) {

    final DocumentReference userRef =
        Firestore.instance.collection('users').document(fbUser.uid);

    final DocumentReference counterRef =
        Firestore.instance.collection('counters').document('tatoolId');

    return Firestore.instance.runTransaction((Transaction tx) async {
      DocumentSnapshot snapshot = await tx.get(userRef);

      if (!snapshot.exists) {
        DocumentSnapshot counterSnapshot = await tx.get(counterRef);
        int tatoolId = counterSnapshot.data['counter'] + 1;
        await tx.update(counterRef, <String, dynamic>{'counter': tatoolId});

        Map<String, dynamic> dbUser = Map();
        dbUser.putIfAbsent('tatoolId', () => tatoolId);
        dbUser.putIfAbsent('modules', () => []);
        await tx.set(userRef, dbUser);
      }
    }).then((result) {
      return fbUser.uid;
    });
  }

  Future<TatoolUser> _getTatoolUser(FirebaseUser fbUser) async {
    final DocumentSnapshot userSnapshot =
        await Firestore.instance.collection('users').document(fbUser.uid).get();

    if (userSnapshot.exists) {
      return TatoolUser(
          userId: fbUser.uid,
          email: fbUser.email,
          displayName: fbUser.displayName,
          tatoolId: userSnapshot.data['tatoolId'].toString());
    } else {
      return null;
    }
  }
}
