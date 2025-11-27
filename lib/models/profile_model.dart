import 'package:hive/hive.dart';

part 'profile_model.g.dart';

@HiveType(typeId: 1)
class ProfileModel extends HiveObject {
  @HiveField(0)
  String name;

  @HiveField(1)
  String nim;

  @HiveField(2)
  String username;

  @HiveField(3)
  String? photoPath;

  ProfileModel({
    required this.name,
    required this.nim,
    required this.username,
    this.photoPath,
  });
}
