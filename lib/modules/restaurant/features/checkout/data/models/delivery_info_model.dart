import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/delivery_info.dart';

class DeliveryInfoModel extends DeliveryInfo {
  DeliveryInfoModel({
    required String address,
    required String city,
    required String zipCode,
    required String country,
    required String phoneNumber,
    String deliveryInstructions = '',
    required DeliveryType deliveryType,
    required DeliveryTime deliveryTime,
  }) : super(
          address: address,
          city: city,
          zipCode: zipCode,
          country: country,
          phoneNumber: phoneNumber,
          deliveryInstructions: deliveryInstructions,
          deliveryType: deliveryType,
          deliveryTime: deliveryTime,
        );

  factory DeliveryInfoModel.fromFirestore(Map<String, dynamic> data) {
    return DeliveryInfoModel(
      address: data['address'] ?? '',
      city: data['city'] ?? '',
      zipCode: data['zipCode'] ?? '',
      country: data['country'] ?? '',
      phoneNumber: data['phoneNumber'] ?? '',
      deliveryInstructions: data['deliveryInstructions'] ?? '',
      deliveryType: DeliveryType.values.firstWhere(
        (type) => type.name == data['deliveryType'],
        orElse: () => DeliveryType.standard,
      ),
      deliveryTime: DeliveryTime(
        minMinutes: data['deliveryTimeMin'] ?? 0,
        maxMinutes: data['deliveryTimeMax'] ?? 0,
        scheduledTime: data['scheduledTime'] != null
            ? (data['scheduledTime'] as Timestamp).toDate()
            : null,
      ),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'address': address,
      'city': city,
      'zipCode': zipCode,
      'country': country,
      'phoneNumber': phoneNumber,
      'deliveryInstructions': deliveryInstructions,
      'deliveryType': deliveryType.name,
      'deliveryTimeMin': deliveryTime.minMinutes,
      'deliveryTimeMax': deliveryTime.maxMinutes,
      'scheduledTime': deliveryTime.scheduledTime != null
          ? Timestamp.fromDate(deliveryTime.scheduledTime!)
          : null,
    };
  }
}
