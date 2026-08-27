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
exports.PurchaseItem = void 0;
const typeorm_1 = require("typeorm");
const purchase_entity_1 = require("./purchase.entity");
const product_entity_1 = require("./product.entity");
let PurchaseItem = class PurchaseItem {
    id;
    purchase_id;
    purchase;
    product_id;
    product;
    quantite;
    prix_unitaire;
    montant;
};
exports.PurchaseItem = PurchaseItem;
__decorate([
    (0, typeorm_1.PrimaryGeneratedColumn)(),
    __metadata("design:type", Number)
], PurchaseItem.prototype, "id", void 0);
__decorate([
    (0, typeorm_1.Column)(),
    __metadata("design:type", Number)
], PurchaseItem.prototype, "purchase_id", void 0);
__decorate([
    (0, typeorm_1.ManyToOne)(() => purchase_entity_1.Purchase),
    (0, typeorm_1.JoinColumn)({ name: 'purchase_id' }),
    __metadata("design:type", purchase_entity_1.Purchase)
], PurchaseItem.prototype, "purchase", void 0);
__decorate([
    (0, typeorm_1.Column)(),
    __metadata("design:type", Number)
], PurchaseItem.prototype, "product_id", void 0);
__decorate([
    (0, typeorm_1.ManyToOne)(() => product_entity_1.Product),
    (0, typeorm_1.JoinColumn)({ name: 'product_id' }),
    __metadata("design:type", product_entity_1.Product)
], PurchaseItem.prototype, "product", void 0);
__decorate([
    (0, typeorm_1.Column)(),
    __metadata("design:type", Number)
], PurchaseItem.prototype, "quantite", void 0);
__decorate([
    (0, typeorm_1.Column)('decimal', { precision: 10, scale: 2 }),
    __metadata("design:type", Number)
], PurchaseItem.prototype, "prix_unitaire", void 0);
__decorate([
    (0, typeorm_1.Column)('decimal', { precision: 10, scale: 2 }),
    __metadata("design:type", Number)
], PurchaseItem.prototype, "montant", void 0);
exports.PurchaseItem = PurchaseItem = __decorate([
    (0, typeorm_1.Entity)('purchase_items')
], PurchaseItem);
//# sourceMappingURL=purchase_item.entity.js.map