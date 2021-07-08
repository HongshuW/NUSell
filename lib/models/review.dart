class Review {
  String reviewForUser;
  String reviewFromUser;
  double rating;
  String description;
  String productId;

  Review(this.reviewFromUser, this.rating, this.description, this.productId);

  Map<String, dynamic> toMap() {
    return {
      'reviewFromUser': reviewFromUser,
      'rating': rating,
      'description': description,
      'productId': productId
    };
  }
}
