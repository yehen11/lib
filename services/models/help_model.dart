class HelpModel {
  final String phone;
  final String email;
  final String supportHours;
  final List<FaqItem> faqs;

  HelpModel({
    required this.phone,
    required this.email,
    required this.supportHours,
    required this.faqs,
  });

  factory HelpModel.fromJson(Map<String, dynamic> json) {
    return HelpModel(
      phone: json['phone'] as String? ?? '',
      email: json['email'] as String? ?? '',
      supportHours: json['supportHours'] as String? ?? '',
      faqs: (json['faqs'] as List<dynamic>?)
              ?.map((e) => FaqItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  
}

class FaqItem {
  final String question;
  final String answer;

  FaqItem({
    required this.question,
    required this.answer,
  });

  factory FaqItem.fromJson(Map<String, dynamic> json) {
    return FaqItem(
      question: json['question'] as String? ?? '',
      answer: json['answer'] as String? ?? '',
    );
  }

  
}