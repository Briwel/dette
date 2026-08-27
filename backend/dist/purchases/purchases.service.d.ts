import { Repository } from 'typeorm';
import { Purchase } from '../entities/purchase.entity';
import { PurchaseItem } from '../entities/purchase_item.entity';
import { Supplier } from '../entities/supplier.entity';
export declare class PurchasesService {
    private purchasesRepository;
    private purchaseItemsRepository;
    private suppliersRepository;
    constructor(purchasesRepository: Repository<Purchase>, purchaseItemsRepository: Repository<PurchaseItem>, suppliersRepository: Repository<Supplier>);
    getSummary(): Promise<{
        totalDebt: number;
        activePurchasesCount: number;
        urgentPaymentsCount: number;
    }>;
    findAll(): Promise<Purchase[]>;
    findBySupplier(supplierId: number): Promise<Purchase[]>;
    create(data: any): Promise<Purchase>;
}
