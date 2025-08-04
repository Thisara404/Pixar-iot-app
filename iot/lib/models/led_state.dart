class LedState {
  final String status;
  final bool ledState;
  final String message;

  const LedState({
    required this.status,
    required this.ledState,
    required this.message,
  });

  factory LedState.fromJson(Map<String, dynamic> json) {
    return LedState(
      status: json['status'] ?? 'unknown',
      ledState: json['led_state'] ?? false,
      message: json['message'] ?? 'No message',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'led_state': ledState,
      'message': message,
    };
  }

  @override
  String toString() {
    return 'LedState(status: $status, ledState: $ledState, message: $message)';
  }
}
