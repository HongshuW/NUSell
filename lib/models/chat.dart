class Chat {
  String seller;
  String customer;

  Chat(this.seller, this.customer);

  Map<String, dynamic> toMap() {
    return {
      'sellerID': seller,
      'customerID': customer,
      'history': []
    };
  }
}