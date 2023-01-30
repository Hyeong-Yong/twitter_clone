import 'package:flutter/material.dart' show BuildContext;
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:twitter_clone/api/auth_api.dart';
import 'package:twitter_clone/core/core.dart';

// <StateNotifier, state>
final authControllerProvider =
    StateNotifierProvider<AuthController, IsLoading>((ref) {
  return AuthController(
    authAPI: ref.watch(authAPIProvider),
  );
});

class AuthController extends StateNotifier<IsLoading> {
  AuthController({required authAPI})
      : _authAPI = authAPI,
        super(false);
  final AuthAPI _authAPI;

  void signUp({
    required String email,
    required String password,
    required BuildContext context,
  }) async {
    // state is IsLoading
    state = true;
    final res = await _authAPI.signUp(
      email: email,
      password: password,
    );

    res.fold(
        (l) => showSnackBar(
              context,
              l.message,
            ),
        (r) => print(r.name));
  }
}
