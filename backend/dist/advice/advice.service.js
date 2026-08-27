"use strict";
var __decorate = (this && this.__decorate) || function (decorators, target, key, desc) {
    var c = arguments.length, r = c < 3 ? target : desc === null ? desc = Object.getOwnPropertyDescriptor(target, key) : desc, d;
    if (typeof Reflect === "object" && typeof Reflect.decorate === "function") r = Reflect.decorate(decorators, target, key, desc);
    else for (var i = decorators.length - 1; i >= 0; i--) if (d = decorators[i]) r = (c < 3 ? d(r) : c > 3 ? d(target, key, r) : d(target, key)) || r;
    return c > 3 && r && Object.defineProperty(target, key, r), r;
};
var __metadata = (this && this.__metadata) || function (k, v) {
    if (typeof Reflect === "object" && typeof Reflect.metadata === "function") return Reflect.metadata(k, v);
};
var __param = (this && this.__param) || function (paramIndex, decorator) {
    return function (target, key) { decorator(target, key, paramIndex); }
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.AdviceService = void 0;
const common_1 = require("@nestjs/common");
const typeorm_1 = require("@nestjs/typeorm");
const typeorm_2 = require("typeorm");
const purchase_entity_1 = require("../entities/purchase.entity");
const daily_revenue_entity_1 = require("../entities/daily_revenue.entity");
let AdviceService = class AdviceService {
    purchasesRepository;
    dailyRevenuesRepository;
    constructor(purchasesRepository, dailyRevenuesRepository) {
        this.purchasesRepository = purchasesRepository;
        this.dailyRevenuesRepository = dailyRevenuesRepository;
    }
    async getAdvice() {
        const revenues = await this.dailyRevenuesRepository.find();
        const purchases = await this.purchasesRepository.find({ relations: { supplier: true } });
        const hasRevenues = revenues.length > 0;
        const totalRevenue = revenues.reduce((sum, r) => sum + Number(r.montant || 0), 0);
        const avgRevenue = hasRevenues ? Math.round(totalRevenue / revenues.length) : 0;
        const openPurchases = purchases.filter(p => Number(p.montant_restant || 0) > 0);
        const totalDebt = openPurchases.reduce((sum, p) => sum + Number(p.montant_restant || 0), 0);
        const urgentPurchases = openPurchases.filter(p => Number(p.montant_restant || 0) > 20000);
        const urgentAmount = urgentPurchases.reduce((sum, p) => sum + Number(p.montant_restant || 0), 0);
        const suggestedDailyPayment = hasRevenues ? Math.min(totalDebt, Math.round(avgRevenue * 0.2)) : 0;
        const cards = [];
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
        cards.push({
            priority: 3,
            type: 'prepare_tomorrow',
            title: 'Conseil : Prépare demain',
            subtitle: 'Garde un peu de ta recette pour l\'achat de demain.',
            colorHex: '#0284C7',
        });
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
};
exports.AdviceService = AdviceService;
exports.AdviceService = AdviceService = __decorate([
    (0, common_1.Injectable)(),
    __param(0, (0, typeorm_1.InjectRepository)(purchase_entity_1.Purchase)),
    __param(1, (0, typeorm_1.InjectRepository)(daily_revenue_entity_1.DailyRevenue)),
    __metadata("design:paramtypes", [typeorm_2.Repository,
        typeorm_2.Repository])
], AdviceService);
//# sourceMappingURL=advice.service.js.map