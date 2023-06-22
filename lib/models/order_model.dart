import 'package:cloud_firestore/cloud_firestore.dart';

class OrderModel {
  final String orderID;
  final String userID;
  final String restID;
  final double deliveryFee;
  final double total;
  final String address;
  final DateTime dateTime;
  String? riderID;
  String? status;
  double? rating;

  OrderModel({
    required this.orderID,
    required this.userID,
    required this.restID,
    required this.deliveryFee,
    required this.total,
    required this.address,
    required this.dateTime,
    this.riderID,
    required this.status,
    this.rating
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is OrderModel &&
              runtimeType == other.runtimeType &&
              orderID == other.orderID;

  @override
  int get hashCode => orderID.hashCode;

  Map<String, dynamic> toJson() => {
    'orderID': orderID,
    'userID': userID,
    'restID': restID,
    'deliveryFee': deliveryFee,
    'total': total,
    'address': address,
    'dateTime': dateTime,
    'riderID': riderID,
    'status': status,
    'rating': rating
  };

  static OrderModel fromJson(Map<String, dynamic> data) {
    return OrderModel(
      orderID: data['orderID'],
      userID: data['userID'],
      restID: data['restID'],
      deliveryFee: data['deliveryFee'],
      total: data['total'],
      address: data['address'],
      dateTime: (data['dateTime'] as Timestamp).toDate(),
      riderID: data['riderID'],
      status: data['status'],
      rating: data['rating']
    );
  }
}
