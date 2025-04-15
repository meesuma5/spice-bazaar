class Ingredient{
	final String item;
	final String quantity;
	Ingredient({
		required this.item,
		required this.quantity,
	});
	factory Ingredient.fromJson(Map<String, dynamic> json) {
		return Ingredient(
			item: json['item'] ?? '',
			quantity: json['quantity'] ?? '',
		);
	}
	Map<String, dynamic> toJson() {
		return {
			'item': item,
			'quantity': quantity,
		};
	}
}