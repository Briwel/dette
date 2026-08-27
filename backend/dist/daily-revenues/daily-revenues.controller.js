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
exports.DailyRevenuesController = void 0;
const common_1 = require("@nestjs/common");
const daily_revenues_service_1 = require("./daily-revenues.service");
let DailyRevenuesController = class DailyRevenuesController {
    dailyRevenuesService;
    constructor(dailyRevenuesService) {
        this.dailyRevenuesService = dailyRevenuesService;
    }
    getSummary() {
        return this.dailyRevenuesService.getSummary();
    }
    findAll() {
        return this.dailyRevenuesService.findAll();
    }
    create(createRevenueDto) {
        return this.dailyRevenuesService.create(createRevenueDto);
    }
};
exports.DailyRevenuesController = DailyRevenuesController;
__decorate([
    (0, common_1.Get)('summary'),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", []),
    __metadata("design:returntype", void 0)
], DailyRevenuesController.prototype, "getSummary", null);
__decorate([
    (0, common_1.Get)(),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", []),
    __metadata("design:returntype", void 0)
], DailyRevenuesController.prototype, "findAll", null);
__decorate([
    (0, common_1.Post)(),
    __param(0, (0, common_1.Body)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [Object]),
    __metadata("design:returntype", void 0)
], DailyRevenuesController.prototype, "create", null);
exports.DailyRevenuesController = DailyRevenuesController = __decorate([
    (0, common_1.Controller)('daily-revenues'),
    __metadata("design:paramtypes", [daily_revenues_service_1.DailyRevenuesService])
], DailyRevenuesController);
//# sourceMappingURL=daily-revenues.controller.js.map