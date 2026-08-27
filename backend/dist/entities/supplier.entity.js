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
exports.Supplier = void 0;
const typeorm_1 = require("typeorm");
let Supplier = class Supplier {
    id;
    user_id;
    nom;
    telephone;
    photo_uri;
    couleur;
    actif;
    date_creation;
};
exports.Supplier = Supplier;
__decorate([
    (0, typeorm_1.PrimaryGeneratedColumn)(),
    __metadata("design:type", Number)
], Supplier.prototype, "id", void 0);
__decorate([
    (0, typeorm_1.Column)({ nullable: true, default: 1 }),
    __metadata("design:type", Number)
], Supplier.prototype, "user_id", void 0);
__decorate([
    (0, typeorm_1.Column)(),
    __metadata("design:type", String)
], Supplier.prototype, "nom", void 0);
__decorate([
    (0, typeorm_1.Column)({ nullable: true }),
    __metadata("design:type", String)
], Supplier.prototype, "telephone", void 0);
__decorate([
    (0, typeorm_1.Column)({ nullable: true }),
    __metadata("design:type", String)
], Supplier.prototype, "photo_uri", void 0);
__decorate([
    (0, typeorm_1.Column)({ nullable: true, default: '#86EFAC' }),
    __metadata("design:type", String)
], Supplier.prototype, "couleur", void 0);
__decorate([
    (0, typeorm_1.Column)({ default: true }),
    __metadata("design:type", Boolean)
], Supplier.prototype, "actif", void 0);
__decorate([
    (0, typeorm_1.CreateDateColumn)(),
    __metadata("design:type", Date)
], Supplier.prototype, "date_creation", void 0);
exports.Supplier = Supplier = __decorate([
    (0, typeorm_1.Entity)('suppliers')
], Supplier);
//# sourceMappingURL=supplier.entity.js.map