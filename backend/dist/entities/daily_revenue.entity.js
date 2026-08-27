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
exports.DailyRevenue = void 0;
const typeorm_1 = require("typeorm");
let DailyRevenue = class DailyRevenue {
    id;
    user_id;
    date_recette;
    montant;
    created_at;
};
exports.DailyRevenue = DailyRevenue;
__decorate([
    (0, typeorm_1.PrimaryGeneratedColumn)(),
    __metadata("design:type", Number)
], DailyRevenue.prototype, "id", void 0);
__decorate([
    (0, typeorm_1.Column)({ nullable: true, default: 1 }),
    __metadata("design:type", Number)
], DailyRevenue.prototype, "user_id", void 0);
__decorate([
    (0, typeorm_1.Column)(),
    __metadata("design:type", Date)
], DailyRevenue.prototype, "date_recette", void 0);
__decorate([
    (0, typeorm_1.Column)('decimal', { precision: 10, scale: 2 }),
    __metadata("design:type", Number)
], DailyRevenue.prototype, "montant", void 0);
__decorate([
    (0, typeorm_1.CreateDateColumn)(),
    __metadata("design:type", Date)
], DailyRevenue.prototype, "created_at", void 0);
exports.DailyRevenue = DailyRevenue = __decorate([
    (0, typeorm_1.Entity)('daily_revenues')
], DailyRevenue);
//# sourceMappingURL=daily_revenue.entity.js.map