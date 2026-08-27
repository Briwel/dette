enum StatutAchat { nonPaye, partiellementPaye, paye, enRetard, annule, archive }

class AchatItem {
  final String produitId;
  final int quantite;
  final double prixUnitaire;
  final double montant;

  AchatItem({
    required this.produitId,
    required this.quantite,
    required this.prixUnitaire,
    required this.montant,
  });
}

class Achat {
  final String id;
  final String fournisseurId;
  final DateTime dateAchat;
  final DateTime? dateEcheance;
  final double montantTotal;
  final double montantInitialementPaye;
  final double montantRestant;
  final StatutAchat statut;
  final List<AchatItem> items;

  Achat({
    required this.id,
    required this.fournisseurId,
    required this.dateAchat,
    this.dateEcheance,
    required this.montantTotal,
    required this.montantInitialementPaye,
    required this.montantRestant,
    required this.statut,
    required this.items,
  });
}
