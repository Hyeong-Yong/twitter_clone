import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart';
import 'package:fpdart/fpdart.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:twitter_clone/constants/constants.dart';
import 'package:twitter_clone/core/core.dart';
import 'package:twitter_clone/features/tweet/models/tweet_model.dart';

final tweetAPIProvider = Provider(
  (ref) {
    return TweetAPI(
      db: ref.watch(
        appwriteDatabaseProvider,
      ),
    );
  },
);

abstract class ITweetAPI {
  FutureEither<Document> shareTweet(Tweet tweet);
}

class TweetAPI implements ITweetAPI {
  final Databases _db;
  TweetAPI({
    required Databases db,
  }) : _db = db;

  @override
  FutureEither<Document> shareTweet(tweet) async {
    try {
      final document = await _db.createDocument(
        databaseId: AppwriteConstants.databaseId,
        collectionId: AppwriteConstants.tweetCollectionId,
        documentId: ID.unique(),
        data: tweet.toMap(),
      );
      return right(document);
    } on AppwriteException catch (e, strackTrace) {
      return left(
        Failure(
          e.message ?? 'some unexpected error ocurred',
          strackTrace,
        ),
      );
    }
  }
}
