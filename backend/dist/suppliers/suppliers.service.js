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
exports.SuppliersService = void 0;
const common_1 = require("@nestjs/common");
const typeorm_1 = require("@nestjs/typeorm");
const typeorm_2 = require("typeorm");
const supplier_entity_1 = require("../entities/supplier.entity");
const purchase_entity_1 = require("../entities/purchase.entity");
let SuppliersService = class SuppliersService {
    suppliersRepository;
    purchasesRepository;
    constructor(suppliersRepository, purchasesRepository) {
        this.suppliersRepository = suppliersRepository;
        this.purchasesRepository = purchasesRepository;
    }
    async findAll() {
        const suppliers = await this.suppliersRepository.find({ where: { actif: true } });
        const purchases = await this.purchasesRepository.find();
        return suppliers.map(s => {
            const supplierPurchases = purchases.filter(p => p.supplier_id === s.id);
            const detteTotale = supplierPurchases.reduce((sum, p) => sum + Number(p.montant_restant || 0), 0);
            const nbAchats = supplierPurchases.filter(p => Number(p.montant_restant || 0) > 0).length;
            return {
                ...s,
                dette: detteTotale,
                nbAchats: nbAchats,
            };
        });
    }
    async findOne(id) {
        const supplier = await this.suppliersRepository.findOne({ where: { id } });
        if (!supplier)
            return null;
        const purchases = await this.purchasesRepository.find({ where: { supplier_id: id } });
        const detteTotale = purchases.reduce((sum, p) => sum + Number(p.montant_restant || 0), 0);
        const nbAchats = purchases.filter(p => Number(p.montant_restant || 0) > 0).length;
        return {
            ...supplier,
            dette: detteTotale,
            nbAchats: nbAchats,
            purchases,
        };
    }
    async create(supplierData) {
        const newSupplier = this.suppliersRepository.create({
            user_id: 1,
            ...supplierData,
        });
        const saved = await this.suppliersRepository.save(newSupplier);
        return {
            ...saved,
            dette: 0,
            nbAchats: 0,
        };
    }
    async update(id, supplierData) {
        await this.suppliersRepository.update(id, supplierData);
        return this.findOne(id);
    }
    async remove(id) {
        await this.suppliersRepository.update(id, { actif: false });
        return { success: true };
    }
};
exports.SuppliersService = SuppliersService;
exports.SuppliersService = SuppliersService = __decorate([
    (0, common_1.Injectable)(),
    __param(0, (0, typeorm_1.InjectRepository)(supplier_entity_1.Supplier)),
    __param(1, (0, typeorm_1.InjectRepository)(purchase_entity_1.Purchase)),
    __metadata("design:paramtypes", [typeorm_2.Repository,
        typeorm_2.Repository])
], SuppliersService);
//# sourceMappingURL=suppliers.service.js.map