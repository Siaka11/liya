class Parcel {
  final String id;
  final String senderName;
  final String receiverName;
  final String status;
  final DateTime createdAt;
  final String? address;
  final String? phone;
  final String? phoneNumber;
  final String? instructions;
  final String? ville;
  final String? expediteurPhone;
  final String? destinatairePhone;
  final double? prix;
  final String? colisDescription;
  final List<Map<String, dynamic>>? colisList;

  // Nouveaux champs pour les informations complètes
  final String? expediteurNom;
  final String? expediteurLieu;
  final String? destinataireNom;
  final String? destinataireLieu;
  final String? descriptionColis;
  final String? typeProduit;

  Parcel({
    required this.id,
    required this.senderName,
    required this.receiverName,
    required this.status,
    required this.createdAt,
    this.address,
    this.phone,
    this.phoneNumber,
    this.instructions,
    this.ville,
    this.prix,
    this.colisDescription,
    this.colisList,
    this.expediteurNom,
    this.expediteurLieu,
    this.destinataireNom,
    this.destinataireLieu,
    this.descriptionColis,
    this.typeProduit,
    this.expediteurPhone,
    this.destinatairePhone,
  });
}
