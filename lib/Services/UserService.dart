import 'package:Flutter_CRUD/Model/User.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserService {
  final String collectionName = 'Users';

  getUsers() {
    return FirebaseFirestore.instance.collection(collectionName).snapshots();
  }

  addUser(String newName) {
    User user = User(name: newName);
    try {
      FirebaseFirestore.instance.runTransaction(
        (Transaction transection) async {
          await FirebaseFirestore.instance
              .collection(collectionName)
              .doc()
              .set(user.toJson());
        },
      );
    } catch (e) {
      print(e.toString());
    }
  }

  update(User user, String newName) {
    try {
      FirebaseFirestore.instance.runTransaction((transection) async {
        // ignore: await_only_futures
        await transection.update(user.reference, {'name': newName});
      });
    } catch (e) {
      print(e.toString());
    }
  }

  delete(User user) {
    FirebaseFirestore.instance.runTransaction(
      (Transaction transection) async {
        await transection.delete(user.reference);
      },
    );
  }
}
