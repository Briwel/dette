import { PurchasesService } from './purchases.service';
export declare class PurchasesController {
    private readonly purchasesService;
    constructor(purchasesService: PurchasesService);
    getSummary(): Promise<{
        totalDebt: number;
        activePurchasesCount: number;
        urgentPaymentsCount: number;
    }>;
    findAll(supplierId?: string): Promise<import("../entities/purchase.entity").Purchase[]>;
    create(createPurchaseDto: any): Promise<import("../entities/purchase.entity").Purchase>;
}
