class Order {
  final int orderId;
  final String barcode;
  final int runsheetId;
  final int idx;
  final int runsheetOrderId;
  final String clientName;
  final String tel1;
  final String? tel2;
  final String price;
  final String status;
  final String createdAt;
  final String address;
  final String designation;
  final String type;
  final int clientId;
  final Agency agency;
  final Client client;
  final int orderEventId;
  final String? qualificationName;
  final List<ReturnHistory> returnHistory;

  Order({
    required this.orderId,
    required this.barcode,
    required this.runsheetId,
    required this.idx,
    required this.runsheetOrderId,
    required this.clientName,
    required this.tel1,
    this.tel2,
    required this.price,
    required this.status,
    required this.createdAt,
    required this.address,
    required this.designation,
    required this.type,
    required this.clientId,
    required this.agency,
    required this.client,
    required this.orderEventId,
    this.qualificationName,
    required this.returnHistory,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      orderId: json['order_id'] ?? 0,
      barcode: json['barcode'] ?? "",
      runsheetId: json['runsheet_id'] ?? 0,
      idx: json['idx'] ?? 0,
      runsheetOrderId: json['runsheet_order_id'] ?? 0,
      clientName: json['client_name'] ?? "",
      tel1: json['tel1'] ?? "",
      tel2: json['tel2'],
      price: json['price']?.toString() ?? "0",
      status: json['status'] ?? "",
      createdAt: json['created_at'] ?? "",
      address: json['address'] ?? "",
      designation: json['designation'] ?? "",
      type: json['type'] ?? "",
      clientId: json['client_id'] ?? 0,
      agency: Agency.fromJson(json['agency'] ?? {}),
      client: Client.fromJson(json['client'] ?? {}),
      orderEventId: json['order_event_id'] ?? 0,
      qualificationName: json['qualification_name'],
      returnHistory: (json['return_history'] as List? ?? [])
          .map((e) => ReturnHistory.fromJson(e))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'order_id': orderId,
      'barcode': barcode,
      'runsheet_id': runsheetId,
      'idx': idx,
      'runsheet_order_id': runsheetOrderId,
      'client_name': clientName,
      'tel1': tel1,
      'tel2': tel2,
      'price': price,
      'status': status,
      'created_at': createdAt,
      'address': address,
      'designation': designation,
      'type': type,
      'client_id': clientId,
      'agency': agency.toJson(),
      'client': client.toJson(),
      'order_event_id': orderEventId,
      'qualification_name': qualificationName,
      'return_history': returnHistory.map((e) => e.toJson()).toList(),
    };
  }

  @override
  String toString() {
    return "Order(id: $orderId, barcode: $barcode, client: $clientName, price: $price, status: $status, address: $address)";
  }
}

class Agency {
  final String name;

  Agency({required this.name});

  factory Agency.fromJson(Map<String, dynamic> json) {
    return Agency(name: json['name'] ?? "");
  }

  Map<String, dynamic> toJson() => {'name': name};
}

class Client {
  final String fullName;
  final String phoneNumber;
  final UserFields userFields;

  Client({
    required this.fullName,
    required this.phoneNumber,
    required this.userFields,
  });

  factory Client.fromJson(Map<String, dynamic> json) {
    return Client(
      fullName: json['full_name'] ?? "",
      phoneNumber: json['phone_number'] ?? "",
      userFields: UserFields.fromJson(json['user_fields'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() => {
        'full_name': fullName,
        'phone_number': phoneNumber,
        'user_fields': userFields.toJson(),
      };
}

class UserFields {
  final String? rib;
  final String? city;
  final int? type;
  final String? brand;
  final String? token;
  final String? mfCin;
  final bool? allowRs;
  final String? companyName;
  final dynamic pickupPrice;
  final dynamic returnPrice;
  final dynamic deliveryPrice;
  final dynamic exchangePrice;
  final dynamic paymentMethod;

  UserFields({
    this.rib,
    this.city,
    this.type,
    this.brand,
    this.token,
    this.mfCin,
    this.allowRs,
    this.companyName,
    this.pickupPrice,
    this.returnPrice,
    this.deliveryPrice,
    this.exchangePrice,
    this.paymentMethod,
  });

  factory UserFields.fromJson(Map<String, dynamic> json) {
    return UserFields(
      rib: json['rib']?.toString(),
      city: json['City']?.toString(),
      type: json['type'],
      brand: json['brand']?.toString(),
      token: json['token']?.toString(),
      mfCin: json['mf_cin']?.toString(),
      allowRs: json['allow_rs'],
      companyName: json['company_name']?.toString(),
      pickupPrice: json['pickup_price'],
      returnPrice: json['return_price'],
      deliveryPrice: json['delivery_price'],
      exchangePrice: json['exchange_price'],
      paymentMethod: json['payment_method'],
    );
  }

  Map<String, dynamic> toJson() => {
        'rib': rib,
        'City': city,
        'type': type,
        'brand': brand,
        'token': token,
        'mf_cin': mfCin,
        'allow_rs': allowRs,
        'company_name': companyName,
        'pickup_price': pickupPrice,
        'return_price': returnPrice,
        'delivery_price': deliveryPrice,
        'exchange_price': exchangePrice,
        'payment_method': paymentMethod,
      };
}

class ReturnHistory {
  final String motif;
  final String createdAt;
  final int orderEventId;

  ReturnHistory({
    required this.motif,
    required this.createdAt,
    required this.orderEventId,
  });

  factory ReturnHistory.fromJson(Map<String, dynamic> json) {
    return ReturnHistory(
      motif: json['motif'] ?? "",
      createdAt: json['created_at'] ?? "",
      orderEventId: json['order_event_id'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'motif': motif,
        'created_at': createdAt,
        'order_event_id': orderEventId,
      };
}


// class Order {
//   final int orderId;
//   final String? barcode;
//   final String? recipientName;
//   final String? recipientPhone;
//   final String? address;
//   final String? status;
//   final String? createdAt;
//   final String? scheduledDate;
//   final String? price;
//   final String? notes;

//   Order({
//     required this.orderId,
//     this.barcode,
//     this.recipientName,
//     this.recipientPhone,
//     this.address,
//     this.status,
//     this.createdAt,
//     this.scheduledDate,
//     this.price,
//     this.notes,
//   });

//   factory Order.fromJson(Map<String, dynamic> json) {
//     return Order(
//       orderId: json['order_id'] ?? 0,
//       barcode: json['barcode']?.toString(),
//       recipientName: json['recipient_name']?.toString(),
//       recipientPhone: json['recipient_phone']?.toString(),
//       address: json['address']?.toString(),
//       status: json['status']?.toString(),
//       createdAt: json['created_at']?.toString(),
//       scheduledDate: json['scheduled_date']?.toString(),
//       price: json['price']?.toString(),
//       notes: json['notes']?.toString(),
//     );
//   }

//   Map<String, dynamic> toJson() {
//     return {
//       'order_id': orderId,
//       'barcode': barcode,
//       'recipient_name': recipientName,
//       'recipient_phone': recipientPhone,
//       'address': address,
//       'status': status,
//       'created_at': createdAt,
//       'scheduled_date': scheduledDate,
//       'price': price,
//       'notes': notes,
//     };
//   }

//   @override
//   String toString() {
//     return '''
// Order(
//   orderId: $orderId,
//   barcode: $barcode,
//   recipientName: $recipientName,
//   recipientPhone: $recipientPhone,
//   address: $address,
//   status: $status,
//   createdAt: $createdAt,
//   scheduledDate: $scheduledDate,
//   price: $price,
//   notes: $notes
// )
// ''';
//   }
// }