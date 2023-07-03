import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:fortunenow/models/today_model.dart';
import 'package:fortunenow/res/app_constants.dart';
import 'package:fortunenow/screens/tabview/tab_iew_screen.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import '../res/platform_dialogue.dart';
import '../screens/auth/login/login_screen.dart';
import 'base_provider.dart';

class FirebaseProvider extends BaseProvider {
  late FirebaseStorage firebaseStorage;
  FirebaseProvider() {
    _auth = FirebaseAuth.instance;
    firebaseStorage = FirebaseStorage.instance;
    firebaseStorage.setMaxUploadRetryTime(const Duration(seconds: 3));
    Timer(
      const Duration(seconds: 2),
      () async {
        _user = _auth.currentUser;
        if (_user != null) {
          await getUserData(_user!);
          await getTodayModel();
          userDataStream(_user!);
          navigateToTabsPage(_user);
        } else {
          Get.offAll(() => const LoginScreen());
        }
      },
    );
  }

  late FirebaseAuth _auth;
  auth.User? _user;
  auth.User? get firebaseUser => _user;
  UserModel? user;
  TodayModel? todayModel;
  Random random = Random();

  getTodayModel() async {
    final prefs = await SharedPreferences.getInstance();
    String? jsonString = prefs.getString('Today');
    if (jsonString == null) {
      await generateTodayModelForUser();
      return;
    }
    TodayModel newModel = TodayModel.fromJson(jsonString);
    if ((newModel.dateTime.day == DateTime.now().day) && (newModel.dateTime.month == DateTime.now().month)) {
      todayModel = newModel;
      return;
    } else {
      await generateTodayModelForUser();
    }
  }

  generateTodayModelForUser() async {
    String luckyNumbers = generateLuckyNumbers();
    String prediction = generatePredictionNumbers();
    String quote = generateQuoteNumbers();
    todayModel = TodayModel(
      quoteDay: quote,
      luckyNumbers: luckyNumbers,
      prediction: prediction,
      dateTime: DateTime.now(),
    );
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('Today', todayModel!.toJson());
    notifyListeners();
  }

  String generateLuckyNumbers() {
    List<String> numbers = [];
    for (var i = 0; i < 6; i++) {
      int randomNumber = random.nextInt(100);
      NumberFormat formatter = NumberFormat("00");
      String formattedNumber = formatter.format(randomNumber);
      numbers.add(formattedNumber);
    }
    return numbers.toString().replaceAll('[', '').replaceAll(']', '').replaceAll(',', '-').replaceAll(' ', '');
  }

  String generatePredictionNumbers() {
    return preddictions[random.nextInt(preddictions.length)];
  }

  String generateQuoteNumbers() {
    return quotes[random.nextInt(quotes.length)];
  }

  Future<void> usersignIn({required String email, required String password}) async {
    try {
      setLoadingState(true);
      final authResult = await _auth.signInWithEmailAndPassword(email: email, password: password);
      _user = authResult.user;
      await getUserData(_user!);
      await getTodayModel();
      userDataStream(_user!);
      setLoadingState(false);
      navigateToTabsPage(_user);
    } on SocketException catch (_) {
      showPlatformDialogue(title: "Network Connection Error");
    } on FirebaseAuthException catch (e) {
      setLoadingState(false);
      if (e.code == "wrong-password") {
        showPlatformDialogue(title: "Wrong Password");
      } else if (e.code == "user-not-found") {
        await showPlatformDialogue(
          title: "Check your email or password",
        );
      } else {
        showPlatformDialogue(title: e.code);
      }
    }
    setLoadingState(false);
  }

  Future<void> usersignUp({
    required String email,
    required String password,
    required String name,
    required String phone,
    required String username,
  }) async {
    try {
      setLoadingState(true);
      final authResult = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      _user = authResult.user;
      await getTodayModel();
      await addUserDataToFirebase(email, name, phone, username);
    } on SocketException catch (_) {
      setLoadingState(false);
      showPlatformDialogue(title: "Network Connection Error");
    } on FirebaseAuthException catch (e) {
      setLoadingState(false);
      if (e.code == "email-already-in-use") {
        showPlatformDialogue(title: "Email is already registered");
      } else {
        showPlatformDialogue(title: e.code);
      }
    }
    setLoadingState(false);
  }

  Future<void> addUserDataToFirebase(
    String email,
    String name,
    String phone,
    String username,
  ) async {
    user = UserModel(
      fullName: name,
      email: email,
      userId: _user!.uid,
      username: username,
      photos: [],
      phone: phone,
      friends: [],
    );
    await FirebaseFirestore.instance.collection("users").doc(_user!.uid).set(
          user!.toMap(),
        );
    userDataStream(_user!);
    setLoadingState(false);
    navigateToTabsPage(_user);
  }

  Future<void> navigateToTabsPage(auth.User? firebaseUser) async {
    if (firebaseUser != null) {
      Get.offAll(() => const TabViewScreen());
    }
  }

  Future<bool> getUserData(User firebaseUser) async {
    final document = await FirebaseFirestore.instance.collection("users").doc(firebaseUser.uid).get();
    if (document.exists) {
      user = UserModel.fromMap(document.data()!);
      return true;
    }
    user = null;
    return false;
  }

  void userDataStream(auth.User firebaseUser) {
    FirebaseFirestore.instance.collection("users").doc(firebaseUser.uid).snapshots().listen(
      (document) {
        if (document.exists) {
          user = UserModel.fromMap(document.data()!);
          notifyListeners();
        }
      },
    );
  }

  addRemoveFriend(String userid) async {
    try {
      setLoadingState(true);
      if (user!.friends.contains(userid)) {
        await FirebaseFirestore.instance.collection('users').doc(user!.userId).update(
          {
            'friends': FieldValue.arrayRemove(
              [userid],
            ),
          },
        );
        await FirebaseFirestore.instance.collection('users').doc(userid).update(
          {
            'friends': FieldValue.arrayRemove(
              [user!.userId],
            ),
          },
        );
      } else {
        await FirebaseFirestore.instance.collection('users').doc(user!.userId).update(
          {
            'friends': FieldValue.arrayUnion(
              [
                userid,
              ],
            ),
          },
        );
        await FirebaseFirestore.instance.collection('users').doc(userid).update(
          {
            'friends': FieldValue.arrayUnion(
              [
                user!.userId,
              ],
            ),
          },
        );
      }
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
    setLoadingState(false);
  }

  updateUser(UserModel userModel) async {
    try {
      setLoadingState(true);
      await FirebaseFirestore.instance.collection('users').doc(user!.userId).update(userModel.toMap());
      await showPlatformDialogue(title: 'Profile Updated');
      Get.back();
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
    setLoadingState(false);
  }

  deleteAccount() async {
    try {
      setLoadingState(true);
      await FirebaseFirestore.instance.collection('users').doc(user!.userId).delete();
      await firebaseUser!.delete();
      await showPlatformDialogue(title: 'Account deleted');
      Get.offAll(() => const LoginScreen());
      _user = null;
      user = null;
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
    setLoadingState(false);
  }

  PickedFile? image;
  uploadProfilePicture(ImageSource source) async {
    try {
      // ignore: deprecated_member_use
      image = await ImagePicker().getImage(source: source);
      if (kDebugMode) {
        print(image!.path);
      }
      if (image == null) return;
      setLoadingState(true);
      // image = PickedFile(imageNew.path);
      final filename = image!.path.split("/").last;
      Directory tempDir = await getTemporaryDirectory();
      final compressedImage = await (FlutterImageCompress.compressAndGetFile(image!.path, "${tempDir.path}.jpg"));
      final storageReference = firebaseStorage.ref().child("profile_pictures").child(filename);
      await storageReference.putFile(File(compressedImage!.path));
      final imageUrl = await FirebaseStorage.instance
          .ref(
            firebaseStorage.ref().child("profile_pictures").child(filename).fullPath,
          )
          .getDownloadURL();
      await updateProfilePicture(imageUrl);
      if (kDebugMode) {
        print("DOWNLOAD URL $imageUrl");
      }
      setLoadingState(false);
    } on SocketException catch (_) {
      image = null;
      setLoadingState(false);
      showPlatformDialogue(title: "Network Connection Error");
      return false;
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
      image = null;
      setLoadingState(false);
    }
  }

  Future<void> updateProfilePicture(String imageUrl) async {
    await FirebaseFirestore.instance.collection("users").doc(user!.userId).update({"profilePic": imageUrl});
  }

  forgetPassword(String mail) async {
    try {
      setLoadingState(true);
      await _auth.sendPasswordResetEmail(email: mail);
      await showPlatformDialogue(title: 'Please check your Email inbox or spam to reset password.');
      Get.back();
    } on FirebaseAuthException catch (e) {
      showPlatformDialogue(title: e.message ?? 'Email not found');
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
    setLoadingState(false);
  }

  Future<String?> uploadPostPhoto(XFile? file) async {
    if (file == null) {
      return null;
    }
    try {
      final filename = file.path.split("/").last;
      Directory tempDir = await getTemporaryDirectory();
      final compressedImage = await (FlutterImageCompress.compressAndGetFile(file.path, "${tempDir.path}.jpg"));
      String dateChild = DateTime.now().toIso8601String();
      final storageReference = firebaseStorage.ref().child("gallery_images").child(dateChild).child(filename);
      Uint8List imageData = await compressedImage!.readAsBytes();
      await storageReference.putData(imageData);
      final imageUrl = await FirebaseStorage.instance
          .ref(
            firebaseStorage.ref().child("gallery_images").child(dateChild).child(filename).fullPath,
          )
          .getDownloadURL();
      return imageUrl;
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
    return null;
  }

  deletePost(
    PhotoModel photoModel,
  ) async {
    try {
      setLoadingState(true);
      await FirebaseFirestore.instance.collection('users').doc(user!.userId).update(
        {
          'photos': FieldValue.arrayRemove(
            [
              photoModel.toMap(),
            ],
          ),
        },
      );
      await showPlatformDialogue(
        title: 'Posted',
      );
      Get.back();
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
    setLoadingState(false);
  }

  addPost(PhotoModel photoModel, XFile file) async {
    try {
      String? photoUrl;
      setLoadingState(true);
      List<String> imageUrls = [];
      photoUrl = await uploadPostPhoto(file);
      if (photoUrl != null) {
        imageUrls.add(photoUrl);
      }
      photoModel.photoUrls = imageUrls;
      await FirebaseFirestore.instance.collection('users').doc(user!.userId).update(
        {
          'photos': FieldValue.arrayUnion(
            [
              photoModel.toMap(),
            ],
          ),
        },
      );
      await showPlatformDialogue(
        title: 'Posted',
      );
      Get.back();
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
    setLoadingState(false);
  }

  signOut() async {
    _user = null;
    _auth.signOut();
    Get.offAll(() => const LoginScreen());
    user = null;
    notifyListeners();
  }
}
