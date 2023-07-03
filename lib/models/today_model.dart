import 'dart:convert';

class TodayModel {
  final String quoteDay;
  final String luckyNumbers;
  final String prediction;
  final DateTime dateTime;
  TodayModel({
    required this.quoteDay,
    required this.luckyNumbers,
    required this.prediction,
    required this.dateTime,
  });

  TodayModel copyWith({
    String? quoteDay,
    String? luckyNumbers,
    String? prediction,
    DateTime? dateTime,
  }) {
    return TodayModel(
      quoteDay: quoteDay ?? this.quoteDay,
      luckyNumbers: luckyNumbers ?? this.luckyNumbers,
      prediction: prediction ?? this.prediction,
      dateTime: dateTime ?? this.dateTime,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'quoteDay': quoteDay,
      'luckyNumbers': luckyNumbers,
      'prediction': prediction,
      'dateTime': dateTime.millisecondsSinceEpoch,
    };
  }

  factory TodayModel.fromMap(Map<String, dynamic> map) {
    return TodayModel(
      quoteDay: map['quoteDay'] ?? '',
      luckyNumbers: map['luckyNumbers'] ?? '',
      prediction: map['prediction'] ?? '',
      dateTime: DateTime.fromMillisecondsSinceEpoch(map['dateTime']),
    );
  }

  String toJson() => json.encode(toMap());

  factory TodayModel.fromJson(String source) => TodayModel.fromMap(json.decode(source));

  @override
  String toString() {
    return 'TodayModel(quoteDay: $quoteDay, luckyNumbers: $luckyNumbers, prediction: $prediction, dateTime: $dateTime)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is TodayModel &&
        other.quoteDay == quoteDay &&
        other.luckyNumbers == luckyNumbers &&
        other.prediction == prediction &&
        other.dateTime == dateTime;
  }

  @override
  int get hashCode {
    return quoteDay.hashCode ^ luckyNumbers.hashCode ^ prediction.hashCode ^ dateTime.hashCode;
  }
}
