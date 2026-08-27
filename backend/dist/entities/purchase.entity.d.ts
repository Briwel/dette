import { Supplier } from './supplier.entity';
export declare class Purchase {
    id: number;
    user_id: number;
    supplier_id: number;
    supplier: Supplier;
    date_achat: Date;
    date_echeance: Date;
    montant_total: number;
    montant_initialement_paye: number;
    montant_restant: number;
    statut: string;
    created_at: Date;
    updated_at: Date;
}
