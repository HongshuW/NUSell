class Offer {
  String offerForUser;
  String offerFromUser;
  num price;
  String productId;

  Offer(this.offerFromUser, this.price, this.productId);

  Map<String, dynamic> toMap() {
    return {
      'reviewFromUser': offerFromUser,
      'rating': price,
      'productId': productId
    };
  }
}
