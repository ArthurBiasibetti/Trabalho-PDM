import 'package:cloud_firestore/cloud_firestore.dart';

class PatientModel {
  final int? id;
  final String name;
  final int age;
  final String address;
  final List<GeoPoint> area;
  String? code;
  int? userId;

  PatientModel({
    this.id,
    this.userId,
    required this.name,
    required this.age,
    required this.address,
    required this.area,
  });

  toJson() {
    return {
      "name": name,
      "age": age,
      "address": address,
      "area": area,
      "code": code,
      "userId": userId
    };
  }
}