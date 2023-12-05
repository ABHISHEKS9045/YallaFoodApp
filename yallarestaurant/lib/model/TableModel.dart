class TableModel {
  String tableId;
  String tableName;

  TableModel({
    this.tableId = '',
    this.tableName = '',
  });

  factory TableModel.fromJson(Map<String, dynamic> parsedJson) {
    return TableModel(
      tableId: parsedJson['tableId'] ?? '',
      tableName: parsedJson['tableName'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "tableId": tableId,
      "tableName": tableName,
    };
  }
}
