class Fournisseur {
  final String id;
  final String nom;
  final String? telephone;
  final String? photoUri;
  final bool actif;
  final DateTime dateCreation;

  Fournisseur({
    required this.id,
    required this.nom,
    this.telephone,
    this.photoUri,
    this.actif = true,
    required this.dateCreation,
  });
}
