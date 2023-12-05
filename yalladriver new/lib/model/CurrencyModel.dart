class CurrencyModel {

  String symbol;
  String code;
  bool symbolatright;
  String name;
  int decimal;
  String id;
  bool isactive;
  int rounding;

  CurrencyModel({
    this.code = '',
    this.decimal = 0,
    this.isactive = false,
    this.id = '',
    this.name = '',
    this.rounding = 0,
    this.symbol = '',
    this.symbolatright = false,
  });

  factory CurrencyModel.fromJson(Map<String, dynamic> parsedJson) {
    return CurrencyModel(
      code: parsedJson['code']  != null ? parsedJson['code'] : "",
      decimal: parsedJson['decimal_degits'] != null ? parsedJson['decimal_degits'] : 0,
      isactive: parsedJson['isActive'] != null ? parsedJson['isActive'] : false,
      id: parsedJson['id'] != null ? parsedJson['id'] : '',
      name: parsedJson['name'] != null ? parsedJson['name'] : '',
      rounding: parsedJson['rounding'] != null ? parsedJson['rounding'] : 0,
      symbol: parsedJson['symbol'] != null ? parsedJson['symbol'] : '',
      symbolatright: parsedJson['symbolAtRight'] != null ? parsedJson['symbolAtRight'] : false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'code': this.code,
      'decimal_degits': this.decimal,
      'isActive': this.isactive,
      'rounding': this.rounding,
      'id': this.id,
      'name': this.name,
      'symbol': this.symbol,
      'symbolAtRight': this.symbolatright,
    };
  }
}
