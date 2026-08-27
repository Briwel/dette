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
Object.defineProperty(exports, "__esModule", { value: true });
exports.RepaymentAllocation = void 0;
const typeorm_1 = require("typeorm");
const repayment_entity_1 = require("./repayment.entity");
const purchase_entity_1 = require("./purchase.entity");
let RepaymentAllocation = class RepaymentAllocation {
    id;
    repayment_id;
    repayment;
    purchase_id;
    purchase;
    montant_affecte;
};
exports.RepaymentAllocation = RepaymentAllocation;
__decorate([
    (0, typeorm_1.PrimaryGeneratedColumn)(),
    __metadata("design:type", Number)
], RepaymentAllocation.prototype, "id", void 0);
__decorate([
    (0, typeorm_1.Column)(),
    __metadata("design:type", Number)
], RepaymentAllocation.prototype, "repayment_id", void 0);
__decorate([
    (0, typeorm_1.ManyToOne)(() => repayment_entity_1.Repayment),
    (0, typeorm_1.JoinColumn)({ name: 'repayment_id' }),
    __metadata("design:type", repayment_entity_1.Repayment)
], RepaymentAllocation.prototype, "repayment", void 0);
__decorate([
    (0, typeorm_1.Column)(),
    __metadata("design:type", Number)
], RepaymentAllocation.prototype, "purchase_id", void 0);
__decorate([
    (0, typeorm_1.ManyToOne)(() => purchase_entity_1.Purchase),
    (0, typeorm_1.JoinColumn)({ name: 'purchase_id' }),
    __metadata("design:type", purchase_entity_1.Purchase)
], RepaymentAllocation.prototype, "purchase", void 0);
__decorate([
    (0, typeorm_1.Column)('decimal', { precision: 10, scale: 2 }),
    __metadata("design:type", Number)
], RepaymentAllocation.prototype, "montant_affecte", void 0);
exports.RepaymentAllocation = RepaymentAllocation = __decorate([
    (0, typeorm_1.Entity)('repayment_allocations')
], RepaymentAllocation);
//# sourceMappingURL=repayment_allocation.entity.js.map