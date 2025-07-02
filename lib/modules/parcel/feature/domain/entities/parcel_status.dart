enum ParcelStatus {
  reception,
  enRoute,
  nonLivre,
  livre,
}

String parcelStatusToString(ParcelStatus status) {
  switch (status) {
    case ParcelStatus.reception:
      return 'reception';
    case ParcelStatus.enRoute:
      return 'enRoute';
    case ParcelStatus.nonLivre:
      return 'nonLivre';
    case ParcelStatus.livre:
      return 'livre';
  }
}

ParcelStatus parcelStatusFromString(String status) {
  switch (status) {
    case 'reception':
      return ParcelStatus.reception;
    case 'enRoute':
      return ParcelStatus.enRoute;
    case 'nonLivre':
      return ParcelStatus.nonLivre;
    case 'livre':
      return ParcelStatus.livre;
    default:
      return ParcelStatus.reception;
  }
}
