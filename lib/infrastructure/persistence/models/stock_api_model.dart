class StockApiModel {
  final String barcode;
  final int ind;
  final String malInCinsi;
  final String stokKodu;
  final String anaBirim;
  final int depo;

  StockApiModel({
    required this.barcode,
    required this.ind,
    required this.malInCinsi,
    required this.stokKodu,
    required this.anaBirim,
    required this.depo,
  });

  factory StockApiModel.fromJson(Map<String, dynamic> json) {
    return StockApiModel(
      barcode: (json['Barcode'] ?? '') as String,
      ind: (json['Ind'] ?? 0) as int,
      malInCinsi: (json['MalInCinsi'] ?? '') as String,
      stokKodu: (json['StokKodu'] ?? '') as String,
      anaBirim: (json['AnaBirim'] ?? '') as String,
      depo: int.tryParse((json['Depo'] ?? '').toString()) ?? 0,
    );
  }
}

class StockApiResponse {
  final bool success;
  final StockApiModel? data;

  StockApiResponse({required this.success, this.data});

  factory StockApiResponse.fromJson(Map<String, dynamic> json) {
    return StockApiResponse(
      success: (json['success'] ?? false) as bool,
      data: json['data'] != null
          ? StockApiModel.fromJson(json['data'] as Map<String, dynamic>)
          : null,
    );
  }
}
