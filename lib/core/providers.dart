import 'package:appwrite/appwrite.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:twitter_clone/constants/constants.dart';

final appwriteClientProvider = Provider((ref) {
  Client client = Client();

  return client
      .setEndpoint(AppwriteConstants.endpoint)
      .setProject(AppwriteConstants.projectId)
      .setSelfSigned(status: true);
});

final appwriteAccountProivder = Provider((ref) {
  final client = ref.watch(appwriteClientProvider);
  return Account(client);
});
