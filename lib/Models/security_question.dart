class securityQuestion {
  String id;
  String question;

  securityQuestion({required this.id, required this.question});

  factory securityQuestion.fromJson(Map<String, dynamic> json) {
    return securityQuestion(
      id: json['_id'],
      question: json['question'],
    );
  }
}