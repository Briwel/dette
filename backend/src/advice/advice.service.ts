import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { Purchase } from '../entities/purchase.entity';
import { DailyRevenue } from '../entities/daily_revenue.entity';

@Injectable()
export class AdviceService {
  constructor(
    @InjectRepository(Purchase)
    private purchasesRepository: Repository<Purchase>,
    @InjectRepository(DailyRevenue)
    private dailyRevenuesRepository: Repository<DailyRevenue>,
  ) {}

  async getAdvice() {
    const revenues = await this.dailyRevenuesRepository.find();
    const purchases = await this.purchasesRepository.find({ relations: { supplier: true } });

    // 13.1: Check if revenues exist
    const hasRevenues = revenues.length > 0;
    const totalRevenue = revenues.reduce((sum, r) => sum + Number(r.montant || 0), 0);
    const avgRevenue = hasRevenues ? Math.round(totalRevenue / revenues.length) : 0;

    // Open debts calculation
    const openPurchases = purchases.filter(p => Number(p.montant_restant || 0) > 0);
    const totalDebt = openPurchases.reduce((sum, p) => sum + Number(p.montant_restant || 0), 0);
    
    // Urgent payments (overdue or debt > 20000 FCFA)
    const urgentPurchases = openPurchases.filter(p => Number(p.montant_restant || 0) > 20000);
    const urgentAmount = urgentPurchases.reduce((sum, p) => sum + Number(p.montant_restant || 0), 0);

    // Suggested payment today (~20% of daily revenue if available, or minimum reasonable allocation)
    const suggestedDailyPayment = hasRevenues ? Math.min(totalDebt, Math.round(avgRevenue * 0.2)) : 0;

    // Build prioritized advice cards according to Section 13.4
    const cards: any[] = [];

    // Priority 1: Overdue or high debt
    if (urgentPurchases.length > 0) {
      const topUrgent = urgentPurchases[0];
      const supplierNom = topUrgent.supplier ? topUrgent.supplier.nom : 'Fournisseur';
      cards.push({
        priority: 1,
        type: 'overdue',
        title: 'Priorité : Dette en retard',
        subtitle: `${supplierNom} - Depuis le ${new Date(topUrgent.date_achat).toLocaleDateString('fr-FR', { day: 'numeric', month: 'long' })}`,
        buttonText: 'Rembourser',
        supplierNom: supplierNom,
        suggestedAmount: Math.min(Number(topUrgent.montant_restant), suggestedDailyPayment || 10000),
        colorHex: '#DC2626',
      });
    }

    // Priority 2: Small balance quick settlement ("Petit à petit : Solde rapide")
    const smallDebts = openPurchases.filter(p => Number(p.montant_restant || 0) <= (suggestedDailyPayment || 15000) && Number(p.montant_restant || 0) > 0);
    if (smallDebts.length > 0) {
      const topSmall = smallDebts[0];
      const supplierNom = topSmall.supplier ? topSmall.supplier.nom : 'Fournisseur';
      cards.push({
        priority: 2,
        type: 'quick_settle',
        title: 'Petit à petit : Solde rapide',
        subtitle: `${supplierNom} - ${Number(topSmall.montant_restant).toLocaleString('fr-FR')} FCFA`,
        buttonText: 'Rembourser',
        supplierNom: supplierNom,
        suggestedAmount: Number(topSmall.montant_restant),
        colorHex: '#16A34A',
      });
    }

    // Priority 3: Save for tomorrow / advice
    cards.push({
      priority: 3,
      type: 'prepare_tomorrow',
      title: 'Conseil : Prépare demain',
      subtitle: 'Garde un peu de ta recette pour l\'achat de demain.',
      colorHex: '#0284C7',
    });

    // Priority 4: Upcoming date
    cards.push({
      priority: 4,
      type: 'upcoming_date',
      title: 'Astuce : Date proche',
      subtitle: 'Un paiement important est à anticiper prochainement.',
      colorHex: '#475569',
    });

    return {
      hasRevenues,
      noticeMessage: hasRevenues ? null : '« Enregistre tes recettes pour recevoir un conseil plus précis. »',
      avgRevenue,
      totalDebt,
      urgentAmount,
      suggestedDailyPayment,
      cards,
    };
  }
}
