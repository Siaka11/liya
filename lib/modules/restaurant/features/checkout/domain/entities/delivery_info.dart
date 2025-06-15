class DeliveryInfo {
  final String address;
  final String city;
  final String zipCode;
  final String country;
  final String phoneNumber;
  final String deliveryInstructions;
  final DeliveryType deliveryType;
  final DeliveryTime deliveryTime;

  DeliveryInfo({
    required this.address,
    required this.city,
    required this.zipCode,
    required this.country,
    required this.phoneNumber,
    this.deliveryInstructions = '',
    required this.deliveryType,
    required this.deliveryTime,
  });
}

enum DeliveryType { standard, scheduled }

class DeliveryTime {
  final int minMinutes;
  final int maxMinutes;
  final DateTime? scheduledTime;

  DeliveryTime({
    required this.minMinutes,
    required this.maxMinutes,
    this.scheduledTime,
  });

  bool get isScheduled => scheduledTime != null;
}
