import { Supplier } from './supplier.entity';
export declare class Repayment {
    id: number;
    user_id: number;
    supplier_id: number;
    supplier: Supplier;
    date_remboursement: Date;
    montant_total: number;
    type_remboursement: string;
    mode_paiement: string;
    created_at: Date;
}
