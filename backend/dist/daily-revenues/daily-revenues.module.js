"use strict";
var __decorate = (this && this.__decorate) || function (decorators, target, key, desc) {
    var c = arguments.length, r = c < 3 ? target : desc === null ? desc = Object.getOwnPropertyDescriptor(target, key) : desc, d;
    if (typeof Reflect === "object" && typeof Reflect.decorate === "function") r = Reflect.decorate(decorators, target, key, desc);
    else for (var i = decorators.length - 1; i >= 0; i--) if (d = decorators[i]) r = (c < 3 ? d(r) : c > 3 ? d(target, key, r) : d(target, key)) || r;
    return c > 3 && r && Object.defineProperty(target, key, r), r;
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.DailyRevenuesModule = void 0;
const common_1 = require("@nestjs/common");
const typeorm_1 = require("@nestjs/typeorm");
const daily_revenues_controller_1 = require("./daily-revenues.controller");
const daily_revenues_service_1 = require("./daily-revenues.service");
const daily_revenue_entity_1 = require("../entities/daily_revenue.entity");
let DailyRevenuesModule = class DailyRevenuesModule {
};
exports.DailyRevenuesModule = DailyRevenuesModule;
exports.DailyRevenuesModule = DailyRevenuesModule = __decorate([
    (0, common_1.Module)({
        imports: [typeorm_1.TypeOrmModule.forFeature([daily_revenue_entity_1.DailyRevenue])],
        controllers: [daily_revenues_controller_1.DailyRevenuesController],
        providers: [daily_revenues_service_1.DailyRevenuesService],
    })
], DailyRevenuesModule);
//# sourceMappingURL=daily-revenues.module.js.map