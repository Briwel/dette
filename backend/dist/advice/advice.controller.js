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
exports.AdviceController = void 0;
const common_1 = require("@nestjs/common");
const advice_service_1 = require("./advice.service");
let AdviceController = class AdviceController {
    adviceService;
    constructor(adviceService) {
        this.adviceService = adviceService;
    }
    getAdvice() {
        return this.adviceService.getAdvice();
    }
    getPlan() {
        return this.adviceService.getAdvice();
    }
};
exports.AdviceController = AdviceController;
__decorate([
    (0, common_1.Get)('repayment-advice'),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", []),
    __metadata("design:returntype", void 0)
], AdviceController.prototype, "getAdvice", null);
__decorate([
    (0, common_1.Get)('repayment-plan'),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", []),
    __metadata("design:returntype", void 0)
], AdviceController.prototype, "getPlan", null);
exports.AdviceController = AdviceController = __decorate([
    (0, common_1.Controller)(),
    __metadata("design:paramtypes", [advice_service_1.AdviceService])
], AdviceController);
//# sourceMappingURL=advice.controller.js.map