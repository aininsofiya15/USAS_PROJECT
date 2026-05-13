class FacultyRegistrar {

  final int registrarId;
  final String registrarName;
  final String registrarEmail;

  FacultyRegistrar({
    required this.registrarId,
    required this.registrarName,
    required this.registrarEmail,
  });

  factory FacultyRegistrar.fromJson(Map<String, dynamic> json) {

    return FacultyRegistrar(
      registrarId: json['faculty_registrar_id'],
      registrarName: json['registrar_name'],
      registrarEmail: json['registrar_email'],
    );
  }
}