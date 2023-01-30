import 'package:fpdart/fpdart.dart';
import 'package:twitter_clone/core/core.dart';

// Failure (messagem, stackTrace), T (dynamic : Account, Databases, Client,)
typedef FutureEither<T> = Future<Either<Failure, T>>;
typedef FutureEitherVoid = FutureEither<void>;

typedef IsLoading = bool;
