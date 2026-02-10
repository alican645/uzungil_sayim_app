import 'package:equatable/equatable.dart';

class Depo extends Equatable {
  final int ind;
  final String name;
  final String code;

  const Depo({required this.ind, required this.name, required this.code});

  @override
  List<Object?> get props => [ind, name, code];
}
