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
    String? colisDescription,
    List<Map<String, dynamic>>? colisList,
    String? expediteurNom,
    String? expediteurLieu,
    String? destinataireNom,
    String? destinataireLieu,
    String? descriptionColis,
    String? typeProduit,
    String? expediteurPhone,
    String? destinatairePhone,
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
          colisDescription: colisDescription,
          colisList: colisList,
          expediteurNom: expediteurNom,
          expediteurLieu: expediteurLieu,
          destinataireNom: destinataireNom,
          destinataireLieu: destinataireLieu,
          descriptionColis: descriptionColis,
          typeProduit: typeProduit,
          expediteurPhone: expediteurPhone,
          destinatairePhone: destinatairePhone,
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
      colisDescription: map['colisDescription'],
      colisList: map['colisList'] != null
          ? List<Map<String, dynamic>>.from(map['colisList'])
          : null,
      expediteurNom: map['expediteurNom'],
      expediteurLieu: map['expediteurLieu'],
      destinataireNom: map['destinataireNom'],
      destinataireLieu: map['destinataireLieu'],
      descriptionColis: map['descriptionColis'],
      typeProduit: map['typeProduit'],
      expediteurPhone: map['expediteurPhone'],
      destinatairePhone: map['destinatairePhone'],
    );
  }

  Map<String, dynamic> toMap() {
    final Map<String, dynamic> map = {
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
      'colisDescription': colisDescription,
      'colisList': colisList,
      'expediteurNom': expediteurNom,
      'expediteurLieu': expediteurLieu,
      'destinataireNom': destinataireNom,
      'destinataireLieu': destinataireLieu,
      'descriptionColis': descriptionColis,
      'typeProduit': typeProduit,
      'expediteurPhone': expediteurPhone,
      'destinatairePhone': destinatairePhone,
    };

    // S'assurer que tous les champs sont présents dans Firestore
    if (address == null) map['address'] = null;
    if (phone == null) map['phone'] = null;
    if (instructions == null) map['instructions'] = null;
    if (ville == null) map['ville'] = null;
    if (prix == null) map['prix'] = null;
    if (colisDescription == null) map['colisDescription'] = null;
    if (colisList == null) map['colisList'] = null;
    if (expediteurNom == null) map['expediteurNom'] = null;
    if (expediteurLieu == null) map['expediteurLieu'] = null;
    if (destinataireNom == null) map['destinataireNom'] = null;
    if (destinataireLieu == null) map['destinataireLieu'] = null;
    if (descriptionColis == null) map['descriptionColis'] = null;
    if (typeProduit == null) map['typeProduit'] = null;
    if (expediteurPhone == null) map['expediteurPhone'] = null;
    if (destinatairePhone == null) map['destinatairePhone'] = null;

    return map;
  }
}
