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
exports.RepaymentsService = void 0;
const common_1 = require("@nestjs/common");
const typeorm_1 = require("@nestjs/typeorm");
const typeorm_2 = require("typeorm");
const repayment_entity_1 = require("../entities/repayment.entity");
const purchase_entity_1 = require("../entities/purchase.entity");
const supplier_entity_1 = require("../entities/supplier.entity");
let RepaymentsService = class RepaymentsService {
    repaymentsRepository;
    purchasesRepository;
    suppliersRepository;
    constructor(repaymentsRepository, purchasesRepository, suppliersRepository) {
        this.repaymentsRepository = repaymentsRepository;
        this.purchasesRepository = purchasesRepository;
        this.suppliersRepository = suppliersRepository;
    }
    async findAll() {
        return this.repaymentsRepository.find({ relations: { supplier: true } });
    }
    async create(data) {
        let supplierId = data.supplier_id || data.supplierId;
        if (!supplierId && data.fournisseurNom) {
            const supplier = await this.suppliersRepository.findOne({ where: { nom: data.fournisseurNom } });
            if (supplier) {
                supplierId = supplier.id;
            }
        }
        const amount = Number(data.montant_total || data.amount || 0);
        const paymentMethod = data.mode_paiement || data.paymentMethod || 'Espèces';
        if (supplierId && amount > 0) {
            const purchases = await this.purchasesRepository.find({
                where: { supplier_id: supplierId },
                order: { date_achat: 'ASC' },
            });
            let remainingPaymentToAllocate = amount;
            for (const purchase of purchases) {
                const currentRestant = Number(purchase.montant_restant || 0);
                if (currentRestant > 0 && remainingPaymentToAllocate > 0) {
                    const deduction = Math.min(currentRestant, remainingPaymentToAllocate);
                    purchase.montant_restant = currentRestant - deduction;
                    remainingPaymentToAllocate -= deduction;
                    if (purchase.montant_restant === 0) {
                        purchase.statut = 'paid';
                    }
                    else {
                        purchase.statut = 'partially_paid';
                    }
                    await this.purchasesRepository.save(purchase);
                }
            }
        }
        const newRepayment = this.repaymentsRepository.create({
            user_id: 1,
            supplier_id: supplierId || 1,
            date_remboursement: data.date ? new Date(data.date) : new Date(),
            montant_total: amount,
            type_remboursement: 'global',
            mode_paiement: paymentMethod,
        });
        return this.repaymentsRepository.save(newRepayment);
    }
};
exports.RepaymentsService = RepaymentsService;
exports.RepaymentsService = RepaymentsService = __decorate([
    (0, common_1.Injectable)(),
    __param(0, (0, typeorm_1.InjectRepository)(repayment_entity_1.Repayment)),
    __param(1, (0, typeorm_1.InjectRepository)(purchase_entity_1.Purchase)),
    __param(2, (0, typeorm_1.InjectRepository)(supplier_entity_1.Supplier)),
    __metadata("design:paramtypes", [typeorm_2.Repository,
        typeorm_2.Repository,
        typeorm_2.Repository])
], RepaymentsService);
//# sourceMappingURL=repayments.service.js.map