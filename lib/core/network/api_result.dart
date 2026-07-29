import 'package:dartz/dartz.dart';
import '../errors/failures.dart';

typedef ApiResult<T> = Future<Either<Failure, T>>;
