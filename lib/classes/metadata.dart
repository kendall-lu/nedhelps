class Metadata {
  late String name;
  late String value;
  late String label;
  late String placeholder;
  late String tooltip;

  Metadata.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    value = json['value'];
    label = json['label'];
    placeholder = json['placeholder'];
    tooltip = json['tooltip'];
  }
}
