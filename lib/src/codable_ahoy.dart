mixin EncodableMixin {
  Map<String, dynamic> toJson();
}

class AnyEncodable implements EncodableMixin {
  final dynamic wrapped;

  AnyEncodable(this.wrapped);

  @override
  Map<String, dynamic> toJson() {
    if (wrapped is EncodableMixin) {
      return (wrapped as EncodableMixin).toJson();
    } else {
      // Handle other types as needed
      return {'value': wrapped};
    }
  }
}

Map<String, dynamic> encodeDictionary(Map<String, dynamic> json) {
  return json.map((key, value) {
    if (value is EncodableMixin) {
      return MapEntry(key, (value).toJson());
    } else {
      // Handle other types as needed
      return MapEntry(key, {'value': value});
    }
  });
}
