import { Repayment } from './repayment.entity';
import { Purchase } from './purchase.entity';
export declare class RepaymentAllocation {
    id: number;
    repayment_id: number;
    repayment: Repayment;
    purchase_id: number;
    purchase: Purchase;
    montant_affecte: number;
}
