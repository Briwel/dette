import { Repository } from 'typeorm';
import { Repayment } from '../entities/repayment.entity';
import { Purchase } from '../entities/purchase.entity';
import { Supplier } from '../entities/supplier.entity';
export declare class RepaymentsService {
    private repaymentsRepository;
    private purchasesRepository;
    private suppliersRepository;
    constructor(repaymentsRepository: Repository<Repayment>, purchasesRepository: Repository<Purchase>, suppliersRepository: Repository<Supplier>);
    findAll(): Promise<Repayment[]>;
    create(data: any): Promise<Repayment>;
}
