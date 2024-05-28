class User {
  int customer_id;
  String customer_name;
  String email;
  String shipping_address;
  String contact_number;
  String password;

  User(
    this.customer_id,
    this.customer_name,
    this.email,
    this.shipping_address,
    this.contact_number,
    this.password,
  );

  factory User.fromJson(Map<String, dynamic> json) => User(
        int.parse(json["customer_id"]),
        json["customer_name"],
        json["email"],
        json["shipping_address"],
        json["contact_number"],
        json["password"],
      );

  Map<String, dynamic> toJson() => {
        'customer_id': customer_id.toString(),
        'customer_name': customer_name,
        'email': email,
        'shipping_address': shipping_address,
        'contact_number': contact_number,
        'password': password,
      };
}
