class Produit {
  final String id;
  final String nom;
  final String? photoUri;
  final String unite;
  final bool actif;
  final DateTime dateCreation;

  Produit({
    required this.id,
    required this.nom,
    this.photoUri,
    required this.unite,
    this.actif = true,
    required this.dateCreation,
  });
}
