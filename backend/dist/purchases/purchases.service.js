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
exports.PurchasesService = void 0;
const common_1 = require("@nestjs/common");
const typeorm_1 = require("@nestjs/typeorm");
const typeorm_2 = require("typeorm");
const purchase_entity_1 = require("../entities/purchase.entity");
const purchase_item_entity_1 = require("../entities/purchase_item.entity");
const supplier_entity_1 = require("../entities/supplier.entity");
let PurchasesService = class PurchasesService {
    purchasesRepository;
    purchaseItemsRepository;
    suppliersRepository;
    constructor(purchasesRepository, purchaseItemsRepository, suppliersRepository) {
        this.purchasesRepository = purchasesRepository;
        this.purchaseItemsRepository = purchaseItemsRepository;
        this.suppliersRepository = suppliersRepository;
    }
    async getSummary() {
        const purchases = await this.purchasesRepository.find();
        const totalDebt = purchases.reduce((sum, p) => sum + Number(p.montant_restant || 0), 0);
        const activePurchasesCount = purchases.filter(p => Number(p.montant_restant || 0) > 0).length;
        const urgentPaymentsCount = purchases.filter(p => Number(p.montant_restant || 0) > 20000).length;
        return {
            totalDebt,
            activePurchasesCount,
            urgentPaymentsCount,
        };
    }
    async findAll() {
        const purchases = await this.purchasesRepository.find({
            relations: { supplier: true },
            order: { date_achat: 'DESC' },
        });
        return purchases;
    }
    async findBySupplier(supplierId) {
        const purchases = await this.purchasesRepository.find({
            where: { supplier_id: supplierId },
            order: { date_achat: 'DESC' },
        });
        return purchases;
    }
    async create(data) {
        let supplierId = data.supplier_id || data.supplierId;
        if (!supplierId && data.supplierNom) {
            let supplier = await this.suppliersRepository.findOne({ where: { nom: data.supplierNom } });
            if (!supplier) {
                supplier = await this.suppliersRepository.save({
                    nom: data.supplierNom,
                    user_id: 1,
                });
            }
            supplierId = supplier.id;
        }
        const items = data.items || [];
        let calculatedTotal = 0;
        for (const item of items) {
            calculatedTotal += Number(item.price || item.unitPrice || 0);
        }
        const totalAmount = data.montant_total || calculatedTotal || 0;
        const initialPayment = Number(data.deja_paye || data.initialPayment || 0);
        const remainingAmount = Math.max(0, totalAmount - initialPayment);
        const status = remainingAmount === 0 ? 'paid' : initialPayment > 0 ? 'partially_paid' : 'unpaid';
        const newPurchase = this.purchasesRepository.create({
            user_id: 1,
            supplier_id: supplierId,
            date_achat: data.date_achat ? new Date(data.date_achat) : new Date(),
            montant_total: totalAmount,
            montant_initialement_paye: initialPayment,
            montant_restant: remainingAmount,
            statut: status,
        });
        const savedPurchase = await this.purchasesRepository.save(newPurchase);
        return savedPurchase;
    }
};
exports.PurchasesService = PurchasesService;
exports.PurchasesService = PurchasesService = __decorate([
    (0, common_1.Injectable)(),
    __param(0, (0, typeorm_1.InjectRepository)(purchase_entity_1.Purchase)),
    __param(1, (0, typeorm_1.InjectRepository)(purchase_item_entity_1.PurchaseItem)),
    __param(2, (0, typeorm_1.InjectRepository)(supplier_entity_1.Supplier)),
    __metadata("design:paramtypes", [typeorm_2.Repository,
        typeorm_2.Repository,
        typeorm_2.Repository])
], PurchasesService);
//# sourceMappingURL=purchases.service.js.map