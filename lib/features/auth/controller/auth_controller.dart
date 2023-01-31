import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:appwrite/models.dart' as model;
import 'package:twitter_clone/api/api.dart';

import 'package:twitter_clone/core/core.dart';
import 'package:twitter_clone/features/auth/models/user_model.dart';
import 'package:twitter_clone/features/auth/view/login_view.dart';
import 'package:twitter_clone/features/home/view/home_view.dart';

// <StateNotifier, state>
final authControllerProvider =
    StateNotifierProvider<AuthController, IsLoading>((ref) {
  return AuthController(
    authAPI: ref.watch(authAPIProvider),
    userAPI: ref.watch(userAPIProvider),
  );
});

final userDetailsProvider = FutureProvider.family((ref, String uid) {
  final authController = ref.watch(authControllerProvider.notifier);
  return authController.getUserData(uid);
});

final currentUserAccountProvider = FutureProvider((ref) async {
  final authController = ref.watch(authControllerProvider.notifier);
  return authController.currentUser();
});

final currentUserDetailProvider = FutureProvider((ref) async {
  /// If a consumer of an [AsyncValue] does not care about the loading/error
  /// state, consider using [value] to read the state:
  final currentUserId = ref.watch(currentUserAccountProvider).value!.$id;
  final userDetails = ref.watch(
    userDetailsProvider(
      currentUserId,
      // TODO: value 대신 예외처리 해주기
    ),
  );
  return userDetails.value;
});

class AuthController extends StateNotifier<IsLoading> {
  final AuthAPI _authAPI;
  final UserAPI _userAPI;

  AuthController({
    required AuthAPI authAPI,
    required UserAPI userAPI,
  })  : _authAPI = authAPI,
        _userAPI = userAPI,
        super(false);

  Future<model.Account?> currentUser() => _authAPI.currentUserAccount();

  void signUp({
    required String email,
    required String password,
    required BuildContext context,
  }) async {
    // state is IsLoading.
    // isloading [=state] = ref.watch(authoControllerProvider)를 이용하여, signup() 비동기 처리되는 동안 loading 화면으로 이동
    state = true;
    final res = await _authAPI.signUp(
      email: email,
      password: password,
    );
    state = false;

    // save account information into database
    res.fold(
      (l) => showSnackBar(
        context,
        l.message,
      ),
      (r) async {
        UserModel userModel = UserModel(
          email: email,
          name: getNameFromEmail(email),
          followers: const [],
          following: const [],
          profilePic: '',
          bannerPic: '',
          uid: r.$id, // _authAPI.signup에서 ID.unique()로 생성된 uid임
          bio: '',
          isTwitterBlue: false,
        );

        final res2 = await _userAPI.saveUserData(userModel);
        res2.fold(
            (l) => showSnackBar(
                  context,
                  l.message,
                ), (_) {
          showSnackBar(
            context,
            'Accounted created! Please login.',
          );
          Navigator.push(
            context,
            LoginView.route(),
          );
        });
      },
    );
  }

  void login({
    required String email,
    required String password,
    required BuildContext context,
  }) async {
    // state is IsLoading.
    // isloading [=state] = ref.watch(authoControllerProvider)를 이용하여, login() 비동기 처리되는 동안 loading 화면으로 이동
    state = true;
    final res = await _authAPI.login(
      email: email,
      password: password,
    );
    state = false;
    res.fold(
      (l) => showSnackBar(
        context,
        l.message,
      ),
      (r) {
        Navigator.push(
          context,
          HomeView.route(),
        );
      },
    );
  }

  Future<UserModel> getUserData(String uid) async {
    final document = await _userAPI.getUserData(uid);
    final updatedUser = UserModel.fromMap(document.data);
    return updatedUser;
  }
}
