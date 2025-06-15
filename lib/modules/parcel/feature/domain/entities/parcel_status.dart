enum ParcelStatus {
  reception,
  enRoute,
  nonLivre,
  livre,
}

String parcelStatusToString(ParcelStatus status) {
  switch (status) {
    case ParcelStatus.reception:
      return 'RECEPTION';
    case ParcelStatus.enRoute:
      return 'EN ROUTE';
    case ParcelStatus.nonLivre:
      return 'NON LIVRÉ';
    case ParcelStatus.livre:
      return 'LIVRÉ';
  }
}

ParcelStatus parcelStatusFromString(String status) {
  switch (status) {
    case 'RECEPTION':
      return ParcelStatus.reception;
    case 'EN ROUTE':
      return ParcelStatus.enRoute;
    case 'NON LIVRÉ':
      return ParcelStatus.nonLivre;
    case 'LIVRÉ':
      return ParcelStatus.livre;
    default:
      return ParcelStatus.reception;
  }
}
