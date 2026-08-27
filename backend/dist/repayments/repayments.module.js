"use strict";
var __decorate = (this && this.__decorate) || function (decorators, target, key, desc) {
    var c = arguments.length, r = c < 3 ? target : desc === null ? desc = Object.getOwnPropertyDescriptor(target, key) : desc, d;
    if (typeof Reflect === "object" && typeof Reflect.decorate === "function") r = Reflect.decorate(decorators, target, key, desc);
    else for (var i = decorators.length - 1; i >= 0; i--) if (d = decorators[i]) r = (c < 3 ? d(r) : c > 3 ? d(target, key, r) : d(target, key)) || r;
    return c > 3 && r && Object.defineProperty(target, key, r), r;
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.RepaymentsModule = void 0;
const common_1 = require("@nestjs/common");
const typeorm_1 = require("@nestjs/typeorm");
const repayments_controller_1 = require("./repayments.controller");
const repayments_service_1 = require("./repayments.service");
const repayment_entity_1 = require("../entities/repayment.entity");
const purchase_entity_1 = require("../entities/purchase.entity");
const supplier_entity_1 = require("../entities/supplier.entity");
let RepaymentsModule = class RepaymentsModule {
};
exports.RepaymentsModule = RepaymentsModule;
exports.RepaymentsModule = RepaymentsModule = __decorate([
    (0, common_1.Module)({
        imports: [typeorm_1.TypeOrmModule.forFeature([repayment_entity_1.Repayment, purchase_entity_1.Purchase, supplier_entity_1.Supplier])],
        controllers: [repayments_controller_1.RepaymentsController],
        providers: [repayments_service_1.RepaymentsService],
        exports: [repayments_service_1.RepaymentsService],
    })
], RepaymentsModule);
//# sourceMappingURL=repayments.module.js.map