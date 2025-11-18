class DistrictPaddyVarieties {
  static const List<Map<String, dynamic>> districtPaddyList = [
    {'district': 'Colombo', 'paddyVarieties': ['Bg 250', 'Bg 360', 'Ld 365']},
    {'district': 'Gampaha', 'paddyVarieties': ['Bg 300', 'At 362', 'Bg 94-1']},
    {'district': 'Kalutara', 'paddyVarieties': ['Bg 450', 'Bg 380', 'Suwandal']},
    {'district': 'Kandy', 'paddyVarieties': ['Bg 352', 'Bg 357', 'Pachchaperumal']},
    {'district': 'Matale', 'paddyVarieties': ['Bg 358', 'Bg 300', 'Hondarawalu']},
    {'district': 'Nuwara Eliya', 'paddyVarieties': ['Bg 352', 'Bg 379-2', 'Kuruwee']},
    {'district': 'Galle', 'paddyVarieties': ['Bg 450', 'Bg 94-1', 'Maa-Wee']},
    {'district': 'Matara', 'paddyVarieties': ['Bg 450', 'Bg 360', 'Rathel']},
    {'district': 'Hambantota', 'paddyVarieties': ['Bg 250', 'Bg 300', 'Ld 365']},
    {'district': 'Jaffna', 'paddyVarieties': ['Bg 250', 'Bg 360', 'Ponni']},
    {'district': 'Kilinochchi', 'paddyVarieties': ['Bg 352', 'Bg 450', 'At 362']},
    {'district': 'Mannar', 'paddyVarieties': ['Bg 250', 'Ld 365', 'Bg 94-1']},
    {'district': 'Mullaitivu', 'paddyVarieties': ['Bg 352', 'Bg 300', 'Hondarawalu']},
    {'district': 'Vavuniya', 'paddyVarieties': ['Bg 450', 'Bg 358', 'Suvandhal']},
    {'district': 'Ampara', 'paddyVarieties': ['Bg 250', 'Bg 94-1', 'Bg 352']},
    {'district': 'Batticaloa', 'paddyVarieties': ['Bg 250', 'Bg 450', 'Ptb 21']},
    {'district': 'Trincomalee', 'paddyVarieties': ['Bg 250', 'Ld 365', 'Bg 352']},
    {'district': 'Kurunegala', 'paddyVarieties': ['Bg 250', 'Bg 352', 'Bg 407']},
    {'district': 'Puttalam', 'paddyVarieties': ['Bg 250', 'Ld 365', 'Bg 94-1']},
    {'district': 'Anuradhapura', 'paddyVarieties': ['Bg 250', 'Bg 352', 'Bg 94-1']},
    {'district': 'Polonnaruwa', 'paddyVarieties': ['Bg 250', 'Bg 352', 'Bg 450']},
    {'district': 'Kegalle', 'paddyVarieties': ['Bg 352', 'Bg 450', 'Pachchaperumal']},
    {'district': 'Ratnapura', 'paddyVarieties': ['Bg 450', 'Bg 94-1', 'Kalu Heenati']},
    {'district': 'Badulla', 'paddyVarieties': ['Bg 352', 'Bg 379-2', 'Madathawalu']},
    {'district': 'Monaragala', 'paddyVarieties': ['Bg 250', 'Bg 352', 'Bg 94-1']},
  ];

  static List<String> getVarietiesFor(String? district) {
    if (district == null) return [];
    final match = districtPaddyList.firstWhere(
      (e) => e['district'] == district,
      orElse: () => {'paddyVarieties': <String>[]},
    );
    final List<dynamic> list = match['paddyVarieties'] as List<dynamic>;
    return list.map((e) => e.toString()).toList();
  }
}


