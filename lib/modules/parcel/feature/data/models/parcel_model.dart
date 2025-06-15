import '../../domain/entities/parcel.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ParcelModel extends Parcel {
  ParcelModel({
    required String id,
    required String senderName,
    required String receiverName,
    required String status,
    required DateTime createdAt,
    String? address,
    String? phone,
    String? phoneNumber,
    String? instructions,
    String? ville,
    double? prix,
  }) : super(
          id: id,
          senderName: senderName,
          receiverName: receiverName,
          status: status,
          createdAt: createdAt,
          address: address,
          phone: phone,
          phoneNumber: phoneNumber,
          instructions: instructions,
          ville: ville,
          prix: prix,
        );

  factory ParcelModel.fromMap(Map<String, dynamic> map, String id) {
    return ParcelModel(
      id: id.isNotEmpty ? id : map['id'] ?? '',
      senderName: map['senderName'] ?? '',
      receiverName: map['receiverName'] ?? '',
      status: map['status'] ?? '',
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      address: map['address'],
      phone: map['phone'],
      phoneNumber: map['phoneNumber'],
      instructions: map['instructions'],
      ville: map['ville'],
      prix: map['prix'] != null ? (map['prix'] as num).toDouble() : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'senderName': senderName,
      'receiverName': receiverName,
      'status': status,
      'createdAt': createdAt,
      'address': address,
      'phone': phone,
      'phoneNumber': phoneNumber ?? '',
      'instructions': instructions,
      'ville': ville ?? '',
      'prix': prix,
    };
  }
}
