import '../../../../core/domain/entities/depo.dart';

class DepoApiModel {
  final int ind;
  final String depoAdi;
  final String depoKodu;

  DepoApiModel({
    required this.ind,
    required this.depoAdi,
    required this.depoKodu,
  });

  factory DepoApiModel.fromJson(Map<String, dynamic> json) {
    return DepoApiModel(
      ind: (json['Ind'] ?? 0) as int,
      depoAdi: (json['DepoAdi'] ?? '') as String,
      depoKodu: (json['DepoKodu'] ?? '') as String,
    );
  }

  Depo toEntity() {
    return Depo(ind: ind, name: depoAdi, code: depoKodu);
  }
}

class DepoApiResponse {
  final bool success;
  final List<DepoApiModel> data;

  DepoApiResponse({required this.success, required this.data});

  factory DepoApiResponse.fromJson(Map<String, dynamic> json) {
    return DepoApiResponse(
      success: (json['success'] ?? false) as bool,
      data: (json['data'] as List? ?? [])
          .map((e) => DepoApiModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
